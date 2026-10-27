#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAM_CMD="${PLUGIN_DIR}/src/ram.sh"
RAM_CMD_ARG="$(printf '%q' "${RAM_CMD}")"
hash="#"
RAM_CMD_ARG=${RAM_CMD_ARG//"${hash}"/"${hash}${hash}"}

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
  "\#{ram_pressure_fg_color}"
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
  "#(${RAM_CMD_ARG} percentage)"
  "#(${RAM_CMD_ARG} icon)"
  "#(${RAM_CMD_ARG} fg_color)"
  "#(${RAM_CMD_ARG} bg_color)"
  "#(${RAM_CMD_ARG} available)"
  "#(${RAM_CMD_ARG} swap)"
  "#(${RAM_CMD_ARG} swap_icon)"
  "#(${RAM_CMD_ARG} swap_color)"
  "#(${RAM_CMD_ARG} pressure)"
  "#(${RAM_CMD_ARG} pressure_fg_color)"
  "#(${RAM_CMD_ARG} breakdown)"
  "#(${RAM_CMD_ARG} absolute)"
  "#(${RAM_CMD_ARG} commit)"
  "#(${RAM_CMD_ARG} reclaimable)"
  "#(${RAM_CMD_ARG} top_process)"
  "#(${RAM_CMD_ARG} graph)"
  "#(${RAM_CMD_ARG} trend)"
  "#(${RAM_CMD_ARG} text)"
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
  local i target
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    target="$(target_for "${commands[i]}")"
    value=${value//${placeholders[i]}/"${target}"}
  done
  echo "${value}"
}

used_metrics() {
  local text="${1}" used="" i metric
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    metric="${commands[i]##* }"
    metric="${metric%)}"
    if [[ "${text}" == *${placeholders[i]}* || "${text}" == *"@ram_revamped_out_${metric}}"* ]]; then
      used="${used:+${used} }${metric}"
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
  [[ -z "${key}" ]] && key="M-r"
  [[ "${key}" == "off" ]] && return 0
  tmux bind-key "${key}" run-shell "${RAM_CMD_ARG} popup"
}

chmod +x "${RAM_CMD}" 2>/dev/null || true

status_text="$(tmux show-option -gqv status-left) $(tmux show-option -gqv status-right)"
tmux set-option -gq "@ram_revamped_published" "$(used_metrics "${status_text}")"

update_option "status-left"
update_option "status-right"

if [[ "${render_mode}" == "options" ]]; then
  "${RAM_CMD}" start 2>/dev/null || true
else
  tmux set-option -gqu "@ram_revamped_ticker_pid"
fi
bind_popup
