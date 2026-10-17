#!/usr/bin/env bash

[[ -n "${_RAM_REVAMPED_POPUP_LOADED:-}" ]] && return 0
_RAM_REVAMPED_POPUP_LOADED=1

_RAM_POPUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_POPUP_DIR}/../utils/has-command.sh"
# shellcheck source=/dev/null
source "${_RAM_POPUP_DIR}/../utils/platform.sh"
# shellcheck source=/dev/null
source "${_RAM_POPUP_DIR}/../tmux/tmux-ops.sh"

_tmux() { tmux "$@"; }

_read_tmux_version() { _tmux -V 2>/dev/null; }

_tmux_version_number() {
  printf '%s\n' "${1}" | awk '{for(i=1;i<=NF;i++) if($i ~ /[0-9]/){gsub(/[^0-9.]/,"",$i); print $i; exit}}'
}

_version_ge() {
  awk -v a="${1:-0}" -v b="${2:-0}" 'BEGIN{split(a,A,".");split(b,B,".");for(i=1;i<=2;i++){x=A[i]+0;y=B[i]+0;if(x>y)exit 0;if(x<y)exit 1}exit 0}'
}

ram_supports_popup() {
  local v
  v=$(_tmux_version_number "$(_read_tmux_version)")
  _version_ge "${v}" "3.2"
}

ram_popup_command() {
  if has_command btop; then echo "btop"; return 0; fi
  if has_command htop; then echo "htop"; return 0; fi
  if is_macos; then echo "vm_stat 1"; return 0; fi
  if has_command free; then echo "free -h -s 1"; return 0; fi
  echo "cat /proc/meminfo"
}

ram_popup() {
  local cmd width height
  cmd=$(ram_popup_command)
  width=$(get_tmux_option "@ram_revamped_popup_width" "80%")
  height=$(get_tmux_option "@ram_revamped_popup_height" "60%")
  if ram_supports_popup; then
    _tmux display-popup -E -w "${width}" -h "${height}" "${cmd}"
  else
    _tmux new-window -n "ram" "${cmd}"
  fi
}

export -f _tmux
export -f _read_tmux_version
export -f _tmux_version_number
export -f _version_ge
export -f ram_supports_popup
export -f ram_popup_command
export -f ram_popup
