#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RAM_LOADED _RAM_REVAMPED_RENDER_LOADED
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/ram.sh"
  read_ram_percentage() { echo "60"; }
  read_available() { echo "40"; }
  read_swap() { echo "25"; }
  read_pressure() { echo "12"; }
  read_breakdown() { echo "2048 1024 3072 4096"; }
  read_absolute() { echo "8388608 33554432"; }
  read_commit() { echo "42"; }
  read_reclaimable() { echo "4194304"; }
  read_top_process() { echo "firefox 1234567"; }
}

teardown() {
  cleanup_test_environment
}

@test "ram.sh dispatcher - functions are defined" {
  function_exists main
  function_exists ram_refresh
  function_exists ram_tick
  function_exists ram_max_age
}

@test "ram.sh dispatcher - ram_max_age default is 5" {
  [[ "$(ram_max_age)" == "5" ]]
}

@test "ram.sh dispatcher - ram_max_age honors the interval option" {
  set_tmux_option "@ram_revamped_interval" "8"
  [[ "$(ram_max_age)" == "8" ]]
}

@test "ram.sh dispatcher - ram_refresh caches every metric" {
  ram_refresh
  [[ "$(cache_get percent)" == "60" ]]
  [[ "$(cache_get available)" == "40" ]]
  [[ "$(cache_get swap)" == "25" ]]
  [[ "$(cache_get pressure)" == "12" ]]
}

@test "ram.sh dispatcher - available and swap subcommands render the cache" {
  run main available
  [[ "${output}" == "40%" ]]
  run main swap
  [[ "${output}" == "25%" ]]
}

@test "ram.sh dispatcher - pressure subcommand renders the cache" {
  run main pressure
  [[ "${output}" == "12%" ]]
}

@test "ram.sh dispatcher - breakdown subcommand renders the cache" {
  run main breakdown
  [[ "${output}" == "W 2.0G C 1.0G I 3.0G F 4.0G" ]]
}

@test "ram.sh dispatcher - refresh subcommand caches the percentage" {
  main refresh
  [[ "$(cache_get percent)" == "60" ]]
}

@test "ram.sh dispatcher - percentage subcommand renders the cached value" {
  run main percentage
  [[ "${output}" == "60%" ]]
}

@test "ram.sh dispatcher - icon subcommand maps the cached value" {
  run main icon
  [[ "${output}" == "▰▰▱" ]]
}

@test "ram.sh dispatcher - unknown subcommand produces no output" {
  run main bogus
  [[ -z "${output}" ]]
}

@test "ram.sh dispatcher - every subcommand dispatches via a direct call" {
  local out
  out=$(main percentage); [[ "${out}" == "60%" ]]
  out=$(main icon); [[ -n "${out}" ]]
  out=$(main fg_color)
  out=$(main bg_color)
  out=$(main available); [[ "${out}" == "40%" ]]
  out=$(main swap); [[ "${out}" == "25%" ]]
  out=$(main pressure); [[ "${out}" == "12%" ]]
  out=$(main breakdown); [[ "${out}" == "W 2.0G C 1.0G I 3.0G F 4.0G" ]]
  out=$(main bogus); [[ -z "${out}" ]]
  main refresh
  [[ "$(cache_get percent)" == "60" ]]
}

@test "ram.sh dispatcher - ram_refresh caches the new metrics and history" {
  ram_refresh
  [[ "$(cache_get absolute)" == "8388608 33554432" ]]
  [[ "$(cache_get commit)" == "42" ]]
  [[ "$(cache_get reclaimable)" == "4194304" ]]
  [[ "$(cache_get top_process)" == "firefox 1234567" ]]
  [[ "$(get_tmux_option "@ram_revamped_history" "")" == "60" ]]
}

@test "ram.sh dispatcher - absolute subcommand renders the cache" {
  ram_refresh
  run main absolute
  [[ "${output}" == "8G / 32G" ]]
}

@test "ram.sh dispatcher - commit subcommand renders the cache" {
  ram_refresh
  run main commit
  [[ "${output}" == "42%" ]]
}

@test "ram.sh dispatcher - reclaimable subcommand renders the cache" {
  ram_refresh
  run main reclaimable
  [[ "${output}" == "4G" ]]
}

@test "ram.sh dispatcher - top_process subcommand renders the cache" {
  ram_refresh
  run main top_process
  [[ "${output}" == "firefox 1.2G" ]]
}

@test "ram.sh dispatcher - swap_icon and swap_color render the cache" {
  ram_refresh
  set_tmux_option "@ram_revamped_swap_active_icon" "!"
  set_tmux_option "@ram_revamped_swap_active_color" "#[fg=red]"
  run main swap_icon
  [[ "${output}" == "!" ]]
  run main swap_color
  [[ "${output}" == "#[fg=red]" ]]
}

@test "ram.sh dispatcher - graph subcommand renders the history option" {
  ram_refresh
  set_tmux_option "@ram_revamped_history" "0 50 100"
  run main graph
  [[ "${output}" == "▁▅█" ]]
}

@test "ram.sh dispatcher - trend subcommand renders the history option" {
  ram_refresh
  set_tmux_option "@ram_revamped_history" "10 20 90"
  run main trend
  [[ "${output}" == "↑" ]]
}

@test "ram.sh dispatcher - text subcommand composes from the cache" {
  ram_refresh
  run main text
  [[ "${output}" == "RAM 60% used, 40% available, swap 25%" ]]
}

@test "ram.sh dispatcher - popup subcommand routes through the _tmux seam" {
  _tmux() { echo "TMUX:$*"; }
  has_command() { return 0; }
  _read_tmux_version() { echo "tmux 3.3"; }
  run main popup
  [[ "${output}" == *"display-popup"* ]]
  [[ "${output}" == *"btop"* ]]
}

@test "ram.sh dispatcher - popup never launches a monitor on old tmux" {
  _tmux() { echo "TMUX:$*"; }
  has_command() { return 1; }
  _read_tmux_version() { echo "tmux 2.9"; }
  _PLATFORM_OS_CACHE="Linux"
  run main popup
  [[ "${output}" == *"new-window"* ]]
  [[ "${output}" != *"display-popup"* ]]
}

@test "ram.sh dispatcher - doctor subcommand prints a report" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { return 0; }
  run main doctor
  [[ "${output}" == *"tmux-ram-revamped doctor"* ]]
  [[ "${output}" == *"/proc/meminfo"* ]]
}

@test "ram.sh dispatcher - a metric renders without a label by default" {
  run ram_labelled percentage "42%"

  [[ "${output}" == "42%" ]]
}

@test "ram.sh dispatcher - the nerd icon set labels a metric" {
  set_tmux_option "@ram_revamped_icons" "nerd"

  run ram_labelled percentage "42%"

  [[ "${output}" == $'\xf3\xb0\x8a\x9a'" 42%" ]]
}

@test "ram.sh dispatcher - a set label beats the icon set" {
  set_tmux_option "@ram_revamped_icons" "nerd"
  set_tmux_option "@ram_revamped_percentage_label" "USE"

  run ram_labelled percentage "42%"

  [[ "${output}" == "USE 42%" ]]
}

@test "ram.sh dispatcher - an empty label removes the icon set's label" {
  set_tmux_option "@ram_revamped_icons" "nerd"
  ram_option_exists() { [[ "${1}" == "@ram_revamped_percentage_label" ]]; }

  run ram_labelled percentage "42%"

  [[ "${output}" == "42%" ]]
}

@test "ram.sh dispatcher - an empty value renders nothing even with a label" {
  set_tmux_option "@ram_revamped_icons" "nerd"

  run ram_labelled percentage ""

  [ -z "${output}" ]
}

@test "ram.sh dispatcher - only value metrics carry a label" {
  run ram_is_labelled fg_color

  [ "${status}" -eq 1 ]
}

@test "ram.sh dispatcher - main labels the rendered percentage" {
  set_tmux_option "@ram_revamped_icons" "nerd"
  ram_render_metric() { echo "42%"; }

  run main percentage

  [[ "${output}" == $'\xf3\xb0\x8a\x9a'" 42%" ]]
}

@test "ram.sh dispatcher - main leaves a color unlabelled" {
  set_tmux_option "@ram_revamped_icons" "nerd"
  ram_render_metric() { echo "#[fg=red]"; }

  run main fg_color

  [[ "${output}" == "#[fg=red]" ]]
}
