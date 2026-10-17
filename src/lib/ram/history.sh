#!/usr/bin/env bash

[[ -n "${_RAM_REVAMPED_HISTORY_LOADED:-}" ]] && return 0
_RAM_REVAMPED_HISTORY_LOADED=1

_RAM_HISTORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_HISTORY_DIR}/../tmux/tmux-ops.sh"

history_push() {
  local max="${3:-30}"
  [[ "${max}" =~ ^[0-9]+$ && "${max}" -gt 0 ]] || max=30
  # shellcheck disable=SC2086  # word splitting the buffer is intentional
  set -- ${1} ${2}
  local n=$#
  if (( n > max )); then
    shift $(( n - max ))
  fi
  printf '%s' "$*"
}

ram_history_push() {
  local val="${1}"
  [[ "${val}" =~ ^[0-9]+$ ]] || return 0
  local max buf
  max=$(get_tmux_option "@ram_revamped_history_size" "30")
  buf=$(get_tmux_option "@ram_revamped_history" "")
  set_tmux_option "@ram_revamped_history" "$(history_push "${buf}" "${val}" "${max}")"
}

export -f history_push
export -f ram_history_push
