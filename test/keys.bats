#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

loaded_with_status() {
  tmux set-option -g status-right '#{ram_percentage} end'
  load_plugin
  wait_for host_shows "69% end"
}

pane_is_plain() {
  local mode
  mode=$(tmux display-message -p -t test:0.0 '#{pane_in_mode}')
  [[ "${mode}" == "0" ]]
}

@test "keys - prefix M-r opens btop in a popup when it is installed" {
  # Arrange
  monitor btop
  monitor htop
  loaded_with_status

  # Act
  press C-b M-r

  # Assert
  wait_for host_shows "monitor: btop"
}

@test "keys - without btop the popup opens htop, and leaving it closes the popup and keeps the status line running" {
  # Arrange
  monitor htop
  loaded_with_status
  press C-b M-r
  wait_for host_shows "monitor: htop"

  # Act
  press Enter

  # Assert
  wait_for host_lacks "monitor: htop"
  wait_for host_shows "69% end"
  pane_is_plain
}

@test "keys - with neither the popup follows the system's own figures until Ctrl-C, which leaves no error" {
  # Arrange
  loaded_with_status
  press C-b M-r
  wait_for host_shows "monitor: following"

  # Act
  press C-c

  # Assert
  wait_for host_lacks "monitor: following"
  pane_is_plain
  run tmux show-messages
  [[ "${output}" != *"returned"* ]]
}

@test "keys - a key the person names opens the popup, and the default one then does nothing" {
  # Arrange
  monitor btop
  setting popup_key F8
  loaded_with_status
  press C-b M-r
  host_lacks "monitor: btop"

  # Act
  press C-b F8

  # Assert
  wait_for host_shows "monitor: btop"
}

@test "keys - the popup takes the size the options give" {
  # Arrange
  stand_in btop 'stty size; read -r monitor_wait'
  setting popup_width 50
  setting popup_height 10
  loaded_with_status

  # Act
  press C-b M-r

  # Assert
  wait_for host_shows "8 48"
}

@test "keys - in options mode the status line reads options a daemon fills" {
  # Arrange
  setting render options
  tmux set-option -g status-right '#{ram_percentage} | #{ram_top_process} end'

  # Act
  load_plugin

  # Assert
  run tmux show-option -gqv status-right
  [[ "${output}" == "#{E:@ram_revamped_out_percentage} | #{E:@ram_revamped_out_top_process} end" ]]
  wait_for host_shows "69% | My #S app 200M end"
  run tmux show-option -gqv @ram_revamped_ticker_pid
  [[ "${output}" =~ ^[0-9]+$ ]]
}

@test "keys - in options mode the popup key still opens the monitor" {
  # Arrange
  monitor btop
  setting render options
  tmux set-option -g status-right '#{ram_percentage} end'
  load_plugin
  wait_for host_shows "69% end"

  # Act
  press C-b M-r

  # Assert
  wait_for host_shows "monitor: btop"
}
