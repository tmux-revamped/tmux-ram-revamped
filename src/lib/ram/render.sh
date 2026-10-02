#!/usr/bin/env bash
#
# render.sh: map cached RAM values to icons, colors, and formatted text.

[[ -n "${_RAM_REVAMPED_RENDER_LOADED:-}" ]] && return 0
_RAM_REVAMPED_RENDER_LOADED=1

_RAM_RENDER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_RENDER_DIR}/../tmux/tmux-ops.sh"

# _ram_level VALUE MEDIUM HIGH -> low|medium|high by integer thresholds.
_ram_level() {
  local v="${1%%.*}" med="${2}" high="${3}"
  [[ "${v}" =~ ^-?[0-9]+$ ]] || v=0
  if (( v >= high )); then
    echo "high"
  elif (( v >= med )); then
    echo "medium"
  else
    echo "low"
  fi
}

_ram_value_level() {
  _ram_level "${1:-0}" "$(get_tmux_option "@ram_revamped_medium_thresh" "50")" \
    "$(get_tmux_option "@ram_revamped_high_thresh" "85")"
}

ram_render_percentage() {
  local raw="${1}"
  [[ -z "${raw}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_percentage_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${raw}"
}

ram_render_icon() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  case "$(_ram_value_level "${1}")" in
    high)   get_tmux_option "@ram_revamped_high_icon" "▰▰▰" ;;
    medium) get_tmux_option "@ram_revamped_medium_icon" "▰▰▱" ;;
    *)      get_tmux_option "@ram_revamped_low_icon" "▰▱▱" ;;
  esac
}

ram_render_fg() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  get_tmux_option "@ram_revamped_$(_ram_value_level "${1}")_fg_color" ""
}

ram_render_bg() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  get_tmux_option "@ram_revamped_$(_ram_value_level "${1}")_bg_color" ""
}

ram_render_swap() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_swap_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

ram_render_available() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_available_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

ram_render_pressure() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_pressure_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

_ram_mb_to_gb() {
  LC_ALL=C awk -v m="${1:-0}" 'BEGIN { printf "%.1f", m / 1024 }'
}

ram_render_breakdown() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local w c i f fmt
  read -r w c i f <<< "${1}"
  fmt=$(get_tmux_option "@ram_revamped_breakdown_format" "W %sG C %sG I %sG F %sG")
  # shellcheck disable=SC2059
  printf "${fmt}" "$(_ram_mb_to_gb "${w}")" "$(_ram_mb_to_gb "${c}")" "$(_ram_mb_to_gb "${i}")" "$(_ram_mb_to_gb "${f}")"
}

export -f _ram_level
export -f _ram_value_level
export -f ram_render_percentage
export -f ram_render_icon
export -f ram_render_fg
export -f ram_render_bg
export -f ram_render_swap
export -f ram_render_available
export -f ram_render_pressure
export -f _ram_mb_to_gb
export -f ram_render_breakdown

# --- Absolute, commit, reclaimable, top-process, graph, trend, text ----------

# _ram_kb_human KB -> a compact human size, auto-scaled to K/M/G.
_ram_kb_human() {
  LC_ALL=C awk -v k="${1:-0}" 'BEGIN{if(k>=1048576){v=k/1048576;u="G"}else if(k>=1024){v=k/1024;u="M"}else{v=k;u="K"} if(v==int(v)) printf "%d%s",v,u; else printf "%.1f%s",v,u}'
}

ram_render_absolute() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local u t fmt
  read -r u t <<< "${1}"
  [[ -z "${t}" || "${t}" == "0" ]] && { echo ""; return 0; }
  fmt=$(get_tmux_option "@ram_revamped_absolute_format" "%s / %s")
  # shellcheck disable=SC2059
  printf "${fmt}" "$(_ram_kb_human "${u}")" "$(_ram_kb_human "${t}")"
}

ram_render_commit() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_commit_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

ram_render_reclaimable() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@ram_revamped_reclaimable_format" "%s")
  # shellcheck disable=SC2059
  printf "${fmt}" "$(_ram_kb_human "${1}")"
}

ram_render_top_process() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local rss name fmt
  rss="${1##* }"
  name="${1% *}"
  fmt=$(get_tmux_option "@ram_revamped_top_process_format" "%s %s")
  # shellcheck disable=SC2059
  printf "${fmt}" "${name}" "$(_ram_kb_human "${rss}")"
}

ram_render_graph() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local chars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
  local out="" v idx
  # shellcheck disable=SC2086  # word splitting the buffer is intentional
  for v in ${1}; do
    [[ "${v}" =~ ^[0-9]+$ ]] || continue
    idx=$(( v * 8 / 100 ))
    (( idx > 7 )) && idx=7
    out="${out}${chars[idx]}"
  done
  [[ -z "${out}" ]] && { echo ""; return 0; }
  printf '%s' "${out}"
}

ram_render_trend() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local first="" last="" v thresh up down flat delta
  thresh=$(get_tmux_option "@ram_revamped_trend_threshold" "3")
  up=$(get_tmux_option "@ram_revamped_trend_up" "↑")
  down=$(get_tmux_option "@ram_revamped_trend_down" "↓")
  flat=$(get_tmux_option "@ram_revamped_trend_flat" "→")
  # shellcheck disable=SC2086  # word splitting the buffer is intentional
  for v in ${1}; do
    [[ "${v}" =~ ^[0-9]+$ ]] || continue
    [[ -z "${first}" ]] && first="${v}"
    last="${v}"
  done
  [[ -z "${first}" ]] && { echo ""; return 0; }
  delta=$(( last - first ))
  if (( delta >= thresh )); then
    printf '%s' "${up}"
  elif (( delta <= -thresh )); then
    printf '%s' "${down}"
  else
    printf '%s' "${flat}"
  fi
}

ram_render_text() {
  local pct="${1}" avail="${2}" swap="${3}" out
  [[ -z "${pct}" ]] && { echo ""; return 0; }
  out="RAM ${pct}% used"
  [[ -n "${avail}" ]] && out="${out}, ${avail}% available"
  [[ -n "${swap}" ]] && out="${out}, swap ${swap}%"
  printf '%s' "${out}"
}

# _ram_swap_active VALUE -> 0 when swap usage is at or above the warn threshold.
_ram_swap_active() {
  local v="${1%%.*}" thresh
  [[ "${v}" =~ ^[0-9]+$ ]] || v=0
  thresh=$(get_tmux_option "@ram_revamped_swap_warn_thresh" "1")
  (( v >= thresh ))
}

ram_render_swap_icon() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  if _ram_swap_active "${1}"; then
    get_tmux_option "@ram_revamped_swap_active_icon" ""
  else
    echo ""
  fi
}

ram_render_swap_color() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  if _ram_swap_active "${1}"; then
    get_tmux_option "@ram_revamped_swap_active_color" ""
  else
    echo ""
  fi
}

export -f _ram_kb_human
export -f ram_render_absolute
export -f ram_render_commit
export -f ram_render_reclaimable
export -f ram_render_top_process
export -f ram_render_graph
export -f ram_render_trend
export -f ram_render_text
export -f _ram_swap_active
export -f ram_render_swap_icon
export -f ram_render_swap_color
