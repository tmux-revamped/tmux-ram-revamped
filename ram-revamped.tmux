#!/usr/bin/env bash
#
# ram-revamped.tmux: TPM entry point.
#
# Replaces the #{ram_*} placeholders in status-left and status-right with calls
# to the dispatcher, which reads cached values and never blocks the render.
# Also binds a key to open the detail popup.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAM_CMD="${PLUGIN_DIR}/src/ram.sh"

placeholders=(
  "\#{ram_percentage}"
  "\#{ram_icon}"
  "\#{ram_fg_color}"
  "\#{ram_bg_color}"
  "\#{ram_available}"
  "\#{ram_swap}"
  "\#{ram_swap_icon}"
  "\#{ram_swap_color}"
  "\#{ram_pressure}"
  "\#{ram_breakdown}"
  "\#{ram_absolute}"
  "\#{ram_commit}"
  "\#{ram_reclaimable}"
  "\#{ram_top_process}"
  "\#{ram_graph}"
  "\#{ram_trend}"
  "\#{ram_text}"
)

commands=(
  "#(${RAM_CMD} percentage)"
  "#(${RAM_CMD} icon)"
  "#(${RAM_CMD} fg_color)"
  "#(${RAM_CMD} bg_color)"
  "#(${RAM_CMD} available)"
  "#(${RAM_CMD} swap)"
  "#(${RAM_CMD} swap_icon)"
  "#(${RAM_CMD} swap_color)"
  "#(${RAM_CMD} pressure)"
  "#(${RAM_CMD} breakdown)"
  "#(${RAM_CMD} absolute)"
  "#(${RAM_CMD} commit)"
  "#(${RAM_CMD} reclaimable)"
  "#(${RAM_CMD} top_process)"
  "#(${RAM_CMD} graph)"
  "#(${RAM_CMD} trend)"
  "#(${RAM_CMD} text)"
)

render_mode="$(tmux show-option -gqv "@ram_revamped_render")"

target_for() {
  local command="${1}" metric
  metric="${command##* }"
  metric="${metric%)}"
  if [[ "${render_mode}" == "options" ]]; then
    printf '#{E:@ram_revamped_out_%s}' "${metric}"
  else
    printf '%s' "${command}"
  fi
}

interpolate() {
  local value="${1}"
  local i
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    value="${value//${placeholders[i]}/$(target_for "${commands[i]}")}"
  done
  echo "${value}"
}

used_metrics() {
  local text="${1}" used="" i metric
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    if [[ "${text}" == *${placeholders[i]}* ]]; then
      metric="${commands[i]##* }"
      used="${used:+${used} }${metric%)}"
    fi
  done
  echo "${used}"
}

update_option() {
  local option="${1}"
  local current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

bind_popup() {
  local key
  key=$(tmux show-option -gqv "@ram_revamped_popup_key")
  [[ -z "${key}" ]] && key="M"
  tmux bind-key "${key}" run-shell "${RAM_CMD} popup"
}

chmod +x "${RAM_CMD}" 2>/dev/null || true

status_text="$(tmux show-option -gqv status-left) $(tmux show-option -gqv status-right)"
tmux set-option -gq "@ram_revamped_published" "$(used_metrics "${status_text}")"

update_option "status-left"
update_option "status-right"

if [[ "${render_mode}" == "options" ]]; then
  "${RAM_CMD}" start 2>/dev/null || true
fi
bind_popup
