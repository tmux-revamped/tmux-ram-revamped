#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RENDER_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/render.sh"
}

teardown() {
  cleanup_test_environment
}

@test "render.sh - _ram_level classifies by thresholds" {
  [[ "$(_ram_level 10 50 85)" == "low" ]]
  [[ "$(_ram_level 60 50 85)" == "medium" ]]
  [[ "$(_ram_level 90 50 85)" == "high" ]]
}

@test "render.sh - _ram_level treats non-numeric as zero" {
  [[ "$(_ram_level xx 50 85)" == "low" ]]
}

@test "render.sh - ram_render_percentage is empty on cold start" {
  [[ -z "$(ram_render_percentage "")" ]]
}

@test "render.sh - ram_render_percentage uses the default format" {
  [[ "$(ram_render_percentage 73)" == "73%" ]]
}

@test "render.sh - ram_render_percentage honors a custom format" {
  set_tmux_option "@ram_revamped_percentage_format" "RAM %s%%"
  [[ "$(ram_render_percentage 73)" == "RAM 73%" ]]
}

@test "render.sh - ram_render_icon is empty on cold start" {
  [[ -z "$(ram_render_icon "")" ]]
}

@test "render.sh - ram_render_icon maps levels with default thresholds" {
  [[ "$(ram_render_icon 90)" == "▰▰▰" ]]
  [[ "$(ram_render_icon 60)" == "▰▰▱" ]]
  [[ "$(ram_render_icon 10)" == "▰▱▱" ]]
}

@test "render.sh - ram_render_icon honors a custom icon" {
  set_tmux_option "@ram_revamped_high_icon" "FULL"
  [[ "$(ram_render_icon 95)" == "FULL" ]]
}

@test "render.sh - ram_render_fg is empty by default" {
  [[ -z "$(ram_render_fg 95)" ]]
}

@test "render.sh - ram_render_fg returns the configured color" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=red]"
  [[ "$(ram_render_fg 95)" == "#[fg=red]" ]]
}

@test "render.sh - ram_render_bg returns the configured color" {
  set_tmux_option "@ram_revamped_low_bg_color" "#[bg=green]"
  [[ "$(ram_render_bg 10)" == "#[bg=green]" ]]
}

@test "render.sh - ram_render_bg is empty on cold start" {
  [[ -z "$(ram_render_bg "")" ]]
}

@test "render.sh - ram_render_fg passes a named color through verbatim" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=red]"
  [[ "$(ram_render_fg 95)" == "#[fg=red]" ]]
}

@test "render.sh - ram_render_fg passes a 256 color through verbatim" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=colour203]"
  [[ "$(ram_render_fg 95)" == "#[fg=colour203]" ]]
}

@test "render.sh - ram_render_fg passes a hex color through verbatim" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=#f38ba8]"
  [[ "$(ram_render_fg 95)" == "#[fg=#f38ba8]" ]]
}

@test "render.sh - ram_render_fg passes a hex fg and bg pair through verbatim" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=#f38ba8,bg=#1e1e2e]"
  [[ "$(ram_render_fg 95)" == "#[fg=#f38ba8,bg=#1e1e2e]" ]]
}

@test "render.sh - ram_render_fg passes a bright color through verbatim" {
  set_tmux_option "@ram_revamped_high_fg_color" "#[fg=brightred]"
  [[ "$(ram_render_fg 95)" == "#[fg=brightred]" ]]
}

@test "render.sh - ram_render_bg passes a named color through verbatim" {
  set_tmux_option "@ram_revamped_high_bg_color" "#[bg=red]"
  [[ "$(ram_render_bg 95)" == "#[bg=red]" ]]
}

@test "render.sh - ram_render_bg passes a 256 color through verbatim" {
  set_tmux_option "@ram_revamped_high_bg_color" "#[bg=colour203]"
  [[ "$(ram_render_bg 95)" == "#[bg=colour203]" ]]
}

@test "render.sh - ram_render_bg passes a hex color through verbatim" {
  set_tmux_option "@ram_revamped_high_bg_color" "#[bg=#f38ba8]"
  [[ "$(ram_render_bg 95)" == "#[bg=#f38ba8]" ]]
}

@test "render.sh - ram_render_bg passes a hex fg and bg pair through verbatim" {
  set_tmux_option "@ram_revamped_high_bg_color" "#[fg=#f38ba8,bg=#1e1e2e]"
  [[ "$(ram_render_bg 95)" == "#[fg=#f38ba8,bg=#1e1e2e]" ]]
}

@test "render.sh - ram_render_bg passes a bright color through verbatim" {
  set_tmux_option "@ram_revamped_high_bg_color" "#[bg=brightred]"
  [[ "$(ram_render_bg 95)" == "#[bg=brightred]" ]]
}

@test "render.sh - ram_render_swap formats with default and custom" {
  [[ -z "$(ram_render_swap "")" ]]
  [[ "$(ram_render_swap 25)" == "25%" ]]
  set_tmux_option "@ram_revamped_swap_format" "swap %s%%"
  [[ "$(ram_render_swap 25)" == "swap 25%" ]]
}

@test "render.sh - ram_render_available formats with default and custom" {
  [[ -z "$(ram_render_available "")" ]]
  [[ "$(ram_render_available 40)" == "40%" ]]
  set_tmux_option "@ram_revamped_available_format" "free %s%%"
  [[ "$(ram_render_available 40)" == "free 40%" ]]
}

@test "render.sh - ram_render_pressure formats with default and custom" {
  [[ -z "$(ram_render_pressure "")" ]]
  [[ "$(ram_render_pressure 12)" == "12%" ]]
  set_tmux_option "@ram_revamped_pressure_format" "stall %s%%"
  [[ "$(ram_render_pressure 12)" == "stall 12%" ]]
}

@test "render.sh - _ram_mb_to_gb converts megabytes" {
  [[ "$(_ram_mb_to_gb 2048)" == "2.0" ]]
  [[ "$(_ram_mb_to_gb 512)" == "0.5" ]]
}

@test "render.sh - ram_render_breakdown formats the composition" {
  [[ -z "$(ram_render_breakdown "")" ]]
  [[ "$(ram_render_breakdown "2048 1024 3072 4096")" == "W 2.0G C 1.0G I 3.0G F 4.0G" ]]
}

@test "ram - a comma-decimal locale still formats with a dot" {
  locale -a 2>/dev/null | grep -qiE '^pt_BR\.utf-?8$' || skip "the pt_BR.UTF-8 locale is not installed"
  LC_ALL=pt_BR.UTF-8 LC_NUMERIC=pt_BR.UTF-8 run _ram_mb_to_gb 1536

  [[ "${output}" == "1.5" ]]
}
