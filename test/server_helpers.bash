#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

screens() {
  printf 'host screen:\n'
  command tmux -S "${HOST}" capture-pane -p -t host || :
  printf 'options:\n'
  tmux show-options -g | grep ram_revamped || :
  printf 'messages:\n'
  tmux show-messages | tail -n 5 || :
}

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  screens
  return 1
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

holds() {
  local now
  now=$(tmux show-option -gqv "@ram_revamped_$1")
  [[ "${now}" == "$2" ]]
}

host_shows() {
  local screen
  screen=$(command tmux -S "${HOST}" capture-pane -p -t host)
  [[ "${screen}" == *"$1"* ]]
}

host_lacks() {
  ! host_shows "$1"
}

said() {
  local messages
  messages=$(tmux show-messages)
  [[ "${messages}" == *"ram-revamped: $1"* ]]
}

stand_in() {
  printf '#!/bin/sh\n%s\n' "$2" >"${STUBS}/$1"
  chmod +x "${STUBS}/$1"
}

memory() {
  stand_in vm_stat 'if [ "${1:-}" = 1 ]; then
  while :; do
    printf "monitor: following\n"
    sleep 1
  done
fi
printf "Mach Virtual Memory Statistics: (page size of 16384 bytes)\nPages free:                               100000.\nPages active:                             300000.\nPages inactive:                           100000.\nPages speculative:                             0.\nPages wired down:                         100000.\nPages purgeable:                           20000.\nFile-backed pages:                         60000.\nPages occupied by compressor:              50000.\n"'
  stand_in sysctl 'printf "vm.swapusage: total = 2048.00M  used = 512.00M  free = 1536.00M  (encrypted)\n"'
  stand_in cat 'case "${1:-}" in
/proc/meminfo) printf "MemTotal:       1000000 kB\nMemFree:         100000 kB\nMemAvailable:    310000 kB\nBuffers:          50000 kB\nCached:          150000 kB\nSwapTotal:       2048000 kB\nSwapFree:        1536000 kB\nSReclaimable:     10000 kB\nCommitLimit:    1000000 kB\nCommitted_AS:    630000 kB\n" ;;
/proc/pressure/memory) printf "some avg10=23.00 avg60=1.10 avg300=0.50 total=12345\n" ;;
*) exec "'"${BATS_TEST_TMPDIR}"'/farm/cat" "$@" ;;
esac'
  stand_in ps 'printf "  1024 /sbin/launchd\n204800 My #S app\n  2048 tmux\n"'
  stand_in free 'while :; do
  printf "monitor: following\n"
  sleep 1
done'
}

monitor() {
  stand_in "$1" 'printf "monitor: '"$1"'\n"; read -r monitor_wait'
}

without_tools() {
  local farm="${BATS_TEST_TMPDIR}/farm" folder name
  mkdir -p "${farm}"
  local IFS=:
  for folder in ${PATH}; do
    [[ -d "${folder}" ]] || continue
    ln -s "${folder}"/* "${farm}/" 2>/dev/null || :
  done
  unset IFS
  for name in vm_stat sysctl ps btop htop free; do
    rm -f "${farm:?}/${name}"
  done
  PATH="${STUBS}:${farm}"
}

setup() {
  unset BASH_ENV
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  STUBS="${BATS_TEST_TMPDIR}/stubs"
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}" "${STUBS}"
  without_tools
  memory
  setup_tmux_server
  HOST="${TMUX_SOCKET}-host"
  tmux set-option -g default-command "env PS1='$ ' sh"
  tmux respawn-pane -k -t test:0.0 "env PS1='$ ' sh"
  tmux set-option -g status-interval 1
  tmux set-option -g status-left ''
  tmux set-option -g status-right-length 120
  tmux set-option -g @ram_revamped_interval 1
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 30 \
    "env -u TMUX TERM=xterm-256color tmux -u -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
}

teardown() {
  local daemon
  daemon=$(tmux show-option -gqv @ram_revamped_ticker_pid 2>/dev/null) || daemon=""
  if [[ "${daemon}" =~ ^[0-9]+$ ]]; then
    pkill -P "${daemon}" 2>/dev/null || :
    kill "${daemon}" 2>/dev/null || :
  fi
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

load_plugin() {
  local quoted
  quoted=$(printf '%s' "${1:-${ROOT}}" | sed "s/'/'\\\\''/g")
  tmux run-shell "'${quoted}/ram-revamped.tmux'"
}

setting() {
  set_option "@ram_revamped_$1" "$2"
}

press() {
  local key
  for key in "$@"; do
    command tmux -S "${HOST}" send-keys -t host "${key}"
  done
}

prefix_keys() {
  local table
  table=$(tmux list-keys -T prefix)
  awk '{ for (i = 1; i < NF; i++) { if ($i == "-T") { print $(i + 2); break } } }' <<<"${table}"
}
