#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  harness_setup
  for name in $(compgen -v RAM_REVAMPED_); do
    unset "${name}"
  done
  FAKE="${BATS_TEST_TMPDIR}/fake"
  export HOME="${BATS_TEST_TMPDIR}/home" FAKE
  mkdir -p "${HOME}" "${FAKE}" "${BATS_TEST_TMPDIR}/stubs"
  UNTRACED='{ set +x; } 2>/dev/null'
  printf '3.6\n' >"${FAKE}/version"
  : >"${FAKE}/vars"
  : >"${FAKE}/log"
  : >"${FAKE}/asked"
  now 1000000
  fake_tmux
  fake_date
  linux
  harness_hide vm_stat sysctl ps btop htop free
}

quiet() {
  printf '#!/bin/sh\n%s\n%s\n' "${UNTRACED}" "$2" >"${BATS_TEST_TMPDIR}/stubs/$1"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/$1"
}

var() {
  local kept
  kept=$(grep -v "^$1	" "${FAKE}/vars" || :)
  printf '%s\n%s\t%s\n' "${kept}" "$1" "$2" | grep -v '^$' >"${FAKE}/vars.tmp"
  mv -f "${FAKE}/vars.tmp" "${FAKE}/vars"
}

value() {
  awk -F '\t' -v want="$1" '$1 == want { print $2 }' "${FAKE}/vars"
}

option() {
  var "@ram_revamped_$1" "$2"
}

held() {
  value "@ram_revamped_$1"
}

now() {
  printf '%s\n' "$1" >"${FAKE}/now"
}

fake_date() {
  quiet date 'cat "'"${FAKE}"'/now"'
}

macos() {
  export REVAMPED_TEST_UNAME_S=Darwin
}

linux() {
  export REVAMPED_TEST_UNAME_S=Linux
}

says() {
  printf '%s\n' "$2" >"${FAKE}/$1.out"
  quiet "$1" 'printf "%s %s\n" "'"$1"'" "$*" >>"'"${FAKE}"'/asked"; cat "'"${FAKE}/$1"'.out"'
}

pages() {
  says vm_stat "${1:-Mach Virtual Memory Statistics: (page size of 16384 bytes)}
Pages free:                               100000.
Pages active:                             300000.
Pages inactive:                           100000.
Pages speculative:                             0.
Pages throttled:                               0.
Pages wired down:                         100000.
Pages purgeable:                           20000.
\"Translation faults\":                  123456789.
File-backed pages:                         60000.
Pages stored in compressor:               250000.
Pages occupied by compressor:              50000."
}

sysctl_says() {
  printf '%s\n' "$1" >"${FAKE}/sysctl.swap"
  printf '%s\n' "${2:-}" >"${FAKE}/sysctl.page"
  quiet sysctl 'printf "sysctl %s\n" "$*" >>"'"${FAKE}"'/asked"
case "$*" in
"-n hw.pagesize") cat "'"${FAKE}"'/sysctl.page" ;;
*) cat "'"${FAKE}"'/sysctl.swap" ;;
esac'
}

swapping() {
  sysctl_says "vm.swapusage: total = 2048.00M  used = 512.00M  free = 1536.00M  (encrypted)" "${1:-}"
}

proc_file() {
  printf '%s\n' "$2" >"${FAKE}/proc.$1"
  quiet cat 'case "$1" in
/proc/meminfo) name=meminfo ;;
/proc/pressure/memory) name=pressure ;;
*) exec "'"${BATS_TEST_TMPDIR}"'/farm/cat" "$@" ;;
esac
printf "cat %s\n" "$1" >>"'"${FAKE}"'/asked"
[ -f "'"${FAKE}"'/proc.${name}" ] || exit 1
exec "'"${BATS_TEST_TMPDIR}"'/farm/cat" "'"${FAKE}"'/proc.${name}"'
}

meminfo() {
  proc_file meminfo "${1:-MemTotal:       16000000 kB
MemFree:         2000000 kB
MemAvailable:    4000000 kB
Buffers:          500000 kB
Cached:          3000000 kB
SwapCached:        10000 kB
SwapTotal:       2048000 kB
SwapFree:        1536000 kB
SReclaimable:     596000 kB
CommitLimit:    10000000 kB
Committed_AS:    6300000 kB}"
}

stalled() {
  proc_file pressure "some avg10=${1:-2.34} avg60=1.10 avg300=0.50 total=12345
full avg10=1.00 avg60=0.50 avg300=0.20 total=6789"
}

processes() {
  says ps "${1:-  1024 /sbin/launchd
204800 /Applications/My App.app/Contents/MacOS/My App
  2048 tmux}"
}

sampled() {
  option percent "${1:-42}"
  option available "${2:-58}"
  option swap "${3:-25}"
  option percent_ts "${4:-1000000}"
}

asked() {
  cat "${FAKE}/asked"
}

fake_tmux() {
  cat >"${BATS_TEST_TMPDIR}/stubs/tmux" <<EOF
#!/bin/sh
${UNTRACED}
printf '%s\n' "\$*" >>"${FAKE}/log"
expanded() {
  printf '%s\n' "\$1" | awk -v vars="${FAKE}/vars" '
    BEGIN { while ((getline row < vars) > 0) { at = index(row, "\t"); value[substr(row, 1, at - 1)] = substr(row, at + 1) } }
    {
      line = \$0
      out = ""
      while ((at = index(line, "#{")) > 0) {
        stop = index(substr(line, at), "}")
        name = substr(line, at + 2, stop - 3)
        out = out substr(line, 1, at - 1) value[name]
        line = substr(line, at + stop)
      }
      print out line
    }
  '
}
looked() {
  awk -F '\t' -v want="\$1" '\$1 == want { print \$2 }' "${FAKE}/vars"
}
put() {
  kept=\$(grep -v "^\$1	" "${FAKE}/vars" || :)
  printf '%s\n%s\t%s\n' "\${kept}" "\$1" "\$2" | grep -v '^\$' >"${FAKE}/vars.tmp"
  mv -f "${FAKE}/vars.tmp" "${FAKE}/vars"
}
written() {
  while [ "\$#" -gt 0 ]; do
    if [ "\$1" = set-option ] && [ "\${2:-}" = -gq ] && [ "\$#" -ge 4 ]; then
      put "\$3" "\$4"
      shift 4
      continue
    fi
    shift
  done
}
case "\$1" in
-V)
  IFS= read -r version <"${FAKE}/version"
  printf 'tmux %s\n' "\${version}"
  ;;
display-message)
  [ "\$2" != -p ] || expanded "\$3"
  ;;
show-option)
  looked "\$3"
  ;;
list-keys)
  [ ! -f "${FAKE}/keys" ] || cat "${FAKE}/keys"
  ;;
list-clients)
  [ ! -f "${FAKE}/clients" ] || cat "${FAKE}/clients"
  ;;
*)
  case "\$*" in
  *" ; "*) [ ! -f "${FAKE}/refused" ] || exit 1 ;;
  *) [ ! -f "${FAKE}/refused" ] || ! grep -qF -- "\$*" "${FAKE}/refused" || exit 1 ;;
  esac
  written "\$@"
  ;;
esac
exit 0
EOF
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
}

tmux_is() {
  printf '%s\n' "$1" >"${FAKE}/version"
}

planned() {
  lib_run ram "${1:-}"'ram_revamped_plan; ram_revamped_lines'
}

sends() {
  grep -v -e '^display-message -p' -e '^-V' -e '^list-' -e '^show-option' "${FAKE}/log" || :
}

sent() {
  grep -c -- "$1" "${FAKE}/log" || :
}

tool() {
  # shellcheck disable=SC2086
  run ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/ram-revamped" "$@"
}

tool_path() {
  printf "'%s'" "${REVAMPED_TESTS_DIR}/../bin/ram-revamped"
}

bin_path() {
  printf "'%s'" "${REVAMPED_TESTS_DIR%/test}/bin/ram-revamped"
}

has_line() {
  local line
  for line in "${lines[@]}"; do
    [[ "${line}" == "$1" ]] && return 0
  done
  return 1
}

answers() {
  export REVAMPED_TEST_GUM_ANSWERS="${BATS_TEST_TMPDIR}/answers"
  printf '%s\n' "$@" >"${REVAMPED_TEST_GUM_ANSWERS}"
}

eventually() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@"
}

holds() {
  local now
  now=$(held "$1")
  [[ "${now}" == "$2" ]]
}
