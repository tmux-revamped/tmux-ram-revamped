#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_POPUP_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/popup.sh"
}

teardown() {
  cleanup_test_environment
}

@test "popup.sh - _tmux_version_number extracts the numeric token" {
  [[ "$(_tmux_version_number "tmux 3.3a")" == "3.3" ]]
  [[ "$(_tmux_version_number "tmux next-3.4")" == "3.4" ]]
}

@test "popup.sh - _version_ge compares major and minor" {
  run _version_ge "3.3" "3.2"
  [[ "${status}" -eq 0 ]]
  run _version_ge "3.2" "3.2"
  [[ "${status}" -eq 0 ]]
  run _version_ge "3.10" "3.2"
  [[ "${status}" -eq 0 ]]
  run _version_ge "2.9" "3.2"
  [[ "${status}" -ne 0 ]]
}

@test "popup.sh - ram_supports_popup reads the tmux version seam" {
  _read_tmux_version() { echo "tmux 3.3"; }
  run ram_supports_popup
  [[ "${status}" -eq 0 ]]
  _read_tmux_version() { echo "tmux 2.8"; }
  run ram_supports_popup
  [[ "${status}" -ne 0 ]]
}

@test "popup.sh - ram_popup_command prefers btop" {
  has_command() { [[ "$1" == "btop" ]]; }
  [[ "$(ram_popup_command)" == "btop" ]]
}

@test "popup.sh - ram_popup_command falls back to htop" {
  has_command() { [[ "$1" == "htop" ]]; }
  [[ "$(ram_popup_command)" == "htop" ]]
}

@test "popup.sh - ram_popup_command uses vm_stat on macOS" {
  has_command() { return 1; }
  _PLATFORM_OS_CACHE="Darwin"
  [[ "$(ram_popup_command)" == "vm_stat 1" ]]
}

@test "popup.sh - ram_popup_command uses free on Linux" {
  has_command() { [[ "$1" == "free" ]]; }
  _PLATFORM_OS_CACHE="Linux"
  [[ "$(ram_popup_command)" == "free -h -s 1" ]]
}

@test "popup.sh - ram_popup_command falls back to meminfo, and waits so the popup stays open" {
  # Arrange
  has_command() { return 1; }
  _PLATFORM_OS_CACHE="Linux"

  # Act
  run ram_popup_command

  # Assert
  [[ "${output}" == "cat /proc/meminfo; read -r ram_revamped_wait" ]]
}

@test "popup.sh - ram_popup opens a popup on a supported tmux" {
  has_command() { return 0; }
  _read_tmux_version() { echo "tmux 3.3"; }
  _tmux() { echo "SEAM:$*"; }
  run ram_popup
  [[ "${output}" == *"display-popup"* ]]
  [[ "${output}" == *"btop"* ]]
  [[ "${output}" == *"80%"* ]]
}

@test "popup.sh - ram_popup honors custom popup size" {
  has_command() { return 0; }
  _read_tmux_version() { echo "tmux 3.3"; }
  _tmux() { echo "SEAM:$*"; }
  set_tmux_option "@ram_revamped_popup_width" "50%"
  set_tmux_option "@ram_revamped_popup_height" "30%"
  run ram_popup
  [[ "${output}" == *"50%"* ]]
  [[ "${output}" == *"30%"* ]]
}

@test "popup.sh - ram_popup falls back to a window on old tmux" {
  has_command() { return 1; }
  _PLATFORM_OS_CACHE="Linux"
  _read_tmux_version() { echo "tmux 2.9"; }
  _tmux() { echo "SEAM:$*"; }
  run ram_popup
  [[ "${output}" == *"new-window"* ]]
  [[ "${output}" != *"display-popup"* ]]
}

@test "popup.sh - the _tmux seam delegates to tmux" {
  run _tmux set-option -gq @probe value
  [[ "${status}" -eq 0 ]]
}

@test "popup.sh - _read_tmux_version is callable through the seam" {
  run _read_tmux_version
  [[ "${status}" -eq 0 ]]
}
