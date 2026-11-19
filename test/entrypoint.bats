#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

everything() {
  local options
  options=$(tmux show-options -g)
  grep -vE '@ram_revamped_(percent|available|swap|pressure|breakdown|absolute|commit|reclaimable|top_process|history|[a-z_]+_ts|percent_lock) ' <<<"${options}"
  tmux list-keys
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local modes

  # Act
  modes=$(git -C "${ROOT}" ls-files --stage -- ram-revamped.tmux bin/ram-revamped)

  # Assert
  run awk '$1 != "100755" { bad++ } END { print NR ":" bad + 0 }' <<<"${modes}"
  [[ "${output}" == "2:0" ]]
}

@test "entrypoint - loading binds the popup on M-r and turns the placeholder into its job, which shows the memory in use" {
  # Arrange
  local keys
  tmux set-option -g status-right '#{ram_percentage} #{ram_available} #{ram_swap} end'

  # Act
  load_plugin

  # Assert
  keys=$(prefix_keys)
  run grep -c -x 'M-r' <<<"${keys}"
  [[ "${output}" == "1" ]]
  run tmux show-option -gqv status-right
  [[ "${output}" == "#('${ROOT}/bin/ram-revamped' status percentage) #('${ROOT}/bin/ram-revamped' status available) #('${ROOT}/bin/ram-revamped' status swap) end" ]]
  wait_for host_shows "69% 31% 25% end"
}

@test "entrypoint - loading twice changes nothing" {
  # Arrange
  local before after
  tmux set-option -g status-right '#{ram_percentage} end'
  load_plugin
  before=$(everything)

  # Act
  load_plugin

  # Assert
  after=$(everything)
  [[ "${before}" == "${after}" ]]
}

@test "entrypoint - a process name that holds a tmux format is shown as text" {
  # Arrange
  tmux set-option -g status-right '#{ram_top_process} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "My #S app 200M end"
}

@test "entrypoint - the pressure, the text, the graph and the trend reach the status line" {
  # Arrange
  tmux set-option -g status-right '#{ram_pressure} #{ram_text} #{ram_graph}#{ram_trend} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "23% RAM 69% used, 31% available, swap 25%"
  wait_for host_shows $'\xe2\x96\x86\xe2\x86\x92 end'
}

@test "entrypoint - in the nerd set a label set to nothing on a real server means the default, so every metric keeps its glyph" {
  # Arrange
  tmux set-option -g @ram_revamped_icons nerd
  tmux set-option -g @ram_revamped_swap_label ''
  tmux set-option -g status-right '#{ram_percentage} #{ram_swap} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows $'\xf3\xb0\x8a\x9a 69% \xf3\xb0\xbe\xb4 25% end'
}

@test "entrypoint - a format given in the environment reaches the status job with its percent signs whole" {
  # Arrange
  tmux set-environment -g RAM_REVAMPED_PERCENTAGE_FORMAT 'mem %s%%'
  tmux set-option -g status-right '#{ram_percentage} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "mem 69% end"
}

@test "entrypoint - a checkout whose path holds a space, a quote, a hash and a percent sign loads, shows the memory and takes its key" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 50% plug in"
  mkdir -p "${copy}"
  cp -R "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/ram-revamped.tmux" "${copy}/"
  monitor btop
  tmux set-option -g status-right '#{ram_percentage} end'
  load_plugin "${copy}"
  wait_for host_shows "69% end"

  # Act
  press C-b M-r

  # Assert
  wait_for host_shows "monitor: btop"
}

@test "entrypoint - a default key someone else holds is left alone, and one the person names is bound" {
  # Arrange
  local table
  tmux bind-key -T prefix M-r display-message taken
  load_plugin
  table=$(tmux list-keys -T prefix)
  run grep -c 'M-r  *display-message taken' <<<"${table}"
  [[ "${output}" == "1" ]]
  run grep -c 'ram-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
  tmux bind-key -T prefix x display-message taken-too
  setting popup_key x

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'ram-revamped. popup' <<<"${table}"
  [[ "${output}" == "1" ]]
}

@test "entrypoint - a key set to off binds nothing" {
  # Arrange
  local table
  setting popup_key off

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'ram-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
}
