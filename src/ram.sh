#!/usr/bin/env bash
#
# ram.sh: command dispatcher for tmux-ram-revamped.
#
# Usage:
#   ram.sh percentage | icon | fg_color | bg_color
#   ram.sh refresh

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CACHE_PREFIX="ram_revamped"
export PLUGIN_LOG_NS="ram-revamped"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/platform.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/cache.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/ram.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/render.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/history.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/popup.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/ram/doctor.sh"

ram_max_age() {
  get_tmux_option "@ram_revamped_interval" "5"
}

ram_refresh() {
  cache_set percent "$(read_ram_percentage)"
  cache_set available "$(read_available)"
  cache_set swap "$(read_swap)"
  cache_set pressure "$(read_pressure)"
  cache_set breakdown "$(read_breakdown)"
  cache_set absolute "$(read_absolute)"
  cache_set commit "$(read_commit)"
  cache_set reclaimable "$(read_reclaimable)"
  cache_set top_process "$(read_top_process)"
  ram_history_push "$(cache_get percent)"
}

ram_tick() {
  cache_refresh_if_stale percent "$(ram_max_age)" ram_refresh
}

ram_render_metric() {
  local cmd="${1}"
  case "${cmd}" in
    percentage)  ram_render_percentage "$(cache_get percent)" ;;
    icon)        ram_render_icon "$(cache_get percent)" ;;
    fg_color)    ram_render_fg "$(cache_get percent)" ;;
    bg_color)    ram_render_bg "$(cache_get percent)" ;;
    available)   ram_render_available "$(cache_get available)" ;;
    swap)        ram_render_swap "$(cache_get swap)" ;;
    swap_icon)   ram_render_swap_icon "$(cache_get swap)" ;;
    swap_color)  ram_render_swap_color "$(cache_get swap)" ;;
    pressure)    ram_render_pressure "$(cache_get pressure)" ;;
    breakdown)   ram_render_breakdown "$(cache_get breakdown)" ;;
    absolute)    ram_render_absolute "$(cache_get absolute)" ;;
    commit)      ram_render_commit "$(cache_get commit)" ;;
    reclaimable) ram_render_reclaimable "$(cache_get reclaimable)" ;;
    top_process) ram_render_top_process "$(cache_get top_process)" ;;
    graph)       ram_render_graph "$(get_tmux_option "@ram_revamped_history" "")" ;;
    trend)       ram_render_trend "$(get_tmux_option "@ram_revamped_history" "")" ;;
    text)        ram_render_text "$(cache_get percent)" "$(cache_get available)" "$(cache_get swap)" ;;
    *)           return 0 ;;
  esac
}

ram_is_labelled() {
  case "${1}" in
    percentage | available | swap | pressure | breakdown | absolute | commit | reclaimable | top_process | graph | trend) return 0 ;;
    *) return 1 ;;
  esac
}

ram_nerd_label() {
  case "${1}" in
    percentage) printf '\xf3\xb0\x8a\x9a' ;;
    available) printf '\xf3\xb0\x8d\x9b' ;;
    swap) printf '\xf3\xb0\x93\xa2' ;;
    pressure) printf '\xf3\xb0\xa5\x9b' ;;
    breakdown) printf '\xf3\xb0\x9e\xaf' ;;
    absolute) printf '\xf3\xb0\x86\xbc' ;;
    commit) printf '\xf3\xb0\x92\xa0' ;;
    reclaimable) printf '\xf3\xb0\x91\x8c' ;;
    top_process) printf '\xf3\xb0\xa3\x86' ;;
    graph) printf '\xf3\xb0\x9e\xb1' ;;
    trend) printf '\xf3\xb0\x94\xb5' ;;
    *) printf '' ;;
  esac
}

ram_option_exists() {
  [[ -n "$(tmux show-option -gq "${1}" 2>/dev/null)" ]]
}

ram_label() {
  local option="@ram_revamped_${1}_label"
  if ram_option_exists "${option}"; then
    tmux show-option -gqv "${option}" 2>/dev/null
  elif [[ "$(get_tmux_option "@ram_revamped_icons" "ascii")" == "nerd" ]]; then
    ram_nerd_label "${1}"
  fi
}

ram_labelled() {
  local metric="${1}" value="${2}" label
  [[ -n "${value}" ]] || return 0
  label="$(ram_label "${metric}")"
  if [[ -n "${label}" ]]; then
    printf '%s %s\n' "${label}" "${value}"
  else
    printf '%s\n' "${value}"
  fi
}

main() {
  local cmd="${1:-}"

  case "${cmd}" in
    refresh) ram_refresh; return 0 ;;
    popup)   ram_popup; return 0 ;;
    doctor)  ram_doctor; return 0 ;;
  esac

  ram_tick

  local out
  out="$(ram_render_metric "${cmd}")"
  if ram_is_labelled "${cmd}"; then
    ram_labelled "${cmd}" "${out}"
  elif [[ -n "${out}" ]]; then
    printf '%s\n' "${out}"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
