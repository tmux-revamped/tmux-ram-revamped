#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/ram_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/ram_helpers.bash"

shown() {
  lib_run ram 'ram_revamped_load; ram_revamped_show '"$1"
}

each() {
  lib_run ram 'ram_revamped_load; for metric in '"$1"'; do ram_revamped_show "${metric}"; done'
}

status_of() {
  lib_run ram 'ram_revamped_status '"$1"
}

@test "ram - the percentages print the stored sample in their formats" {
  # Arrange
  sampled 42 58 25
  option pressure 17
  option commit 63

  # Act
  each "percentage available swap pressure commit"

  # Assert
  [[ "${lines[*]}" == "42% 58% 25% 17% 63%" ]]
}

@test "ram - a format the person sets shapes its value" {
  # Arrange
  sampled 42 58 25
  option pressure 17
  option commit 63
  option reclaimable 3.9G
  option percentage_format 'mem %s'
  option available_format '%s free'
  option swap_format 'swp %s'
  option pressure_format 'psi %s'
  option commit_format 'cmt %s'
  option reclaimable_format 'rec %s'

  # Act
  each "percentage available swap pressure commit reclaimable"

  # Assert
  [[ "${lines[0]}" == "mem 42" ]]
  [[ "${lines[1]}" == "58 free" ]]
  [[ "${lines[2]}" == "swp 25" ]]
  [[ "${lines[3]}" == "psi 17" ]]
  [[ "${lines[4]}" == "cmt 63" ]]
  [[ "${lines[5]}" == "rec 3.9G" ]]
}

@test "ram - with no sample stored every placeholder prints nothing" {
  # Arrange
  option low_fg_color '#[fg=green]'
  option swap_active_icon '!'
  option icons nerd

  # Act
  each "percentage icon fg_color bg_color available swap swap_icon swap_color pressure pressure_fg_color breakdown absolute commit reclaimable top_process graph trend text"

  # Assert
  [[ -z "${output}" ]]
}

@test "ram - the icon is one, two or three bars as the used memory crosses 50 and 85 percent" {
  # Arrange
  local script='ram_revamped_load; for percent in 49 50 84 85; do RAM_REVAMPED_S_percent="${percent}"; ram_revamped_show icon; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[0]}" == $'\xe2\x96\xb0\xe2\x96\xb1\xe2\x96\xb1' ]]
  [[ "${lines[1]}" == $'\xe2\x96\xb0\xe2\x96\xb0\xe2\x96\xb1' ]]
  [[ "${lines[2]}" == $'\xe2\x96\xb0\xe2\x96\xb0\xe2\x96\xb1' ]]
  [[ "${lines[3]}" == $'\xe2\x96\xb0\xe2\x96\xb0\xe2\x96\xb0' ]]
}

@test "ram - the icons and the colours of each tier are the person's to set" {
  # Arrange
  option low_icon L
  option medium_icon M
  option high_icon H
  option low_fg_color '#[fg=green]'
  option medium_fg_color '#[fg=yellow]'
  option high_fg_color '#[fg=red]'
  option low_bg_color '#[bg=black]'
  option medium_bg_color '#[bg=blue]'
  option high_bg_color '#[bg=white]'
  local script='ram_revamped_load; for percent in 10 60 90; do RAM_REVAMPED_S_percent="${percent}"; ram_revamped_show icon; ram_revamped_show fg_color; ram_revamped_show bg_color; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[*]}" == "L #[fg=green] #[bg=black] M #[fg=yellow] #[bg=blue] H #[fg=red] #[bg=white]" ]]
}

@test "ram - the tiers start where their options say, and junk there means 50 and 85 percent" {
  # Arrange
  option low_fg_color low
  option medium_fg_color medium
  option high_fg_color high
  option medium_thresh 10
  option high_thresh 20
  local script='ram_revamped_load; for percent in 9 10 20; do RAM_REVAMPED_S_percent="${percent}"; ram_revamped_show fg_color; done; RAM_REVAMPED_S_medium_thresh=x; RAM_REVAMPED_S_high_thresh=y; for percent in 20 50 85; do RAM_REVAMPED_S_percent="${percent}"; ram_revamped_show fg_color; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[*]}" == "low medium high low medium high" ]]
}

@test "ram - the pressure colour is the foreground style of the tier the pressure falls in" {
  # Arrange
  sampled 10
  option low_fg_color low
  option medium_fg_color medium
  option high_fg_color high
  local script='ram_revamped_load; for pressure in 3 55 90; do RAM_REVAMPED_S_pressure="${pressure}"; ram_revamped_show pressure_fg_color; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[*]}" == "low medium high" ]]
}

@test "ram - the swap icon and colour show only while the swap in use reaches the warning level" {
  # Arrange
  option swap_active_icon '!'
  option swap_active_color '#[fg=red]'
  local script='ram_revamped_load; for swap in 0 1 40; do RAM_REVAMPED_S_swap="${swap}"; printf "[%s]" "${swap}"; ram_revamped_show swap_icon; ram_revamped_show swap_color; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[*]}" == "[0][1]! #[fg=red] [40]! #[fg=red]" ]]
}

@test "ram - the warning level comes from its option, and junk there means one percent" {
  # Arrange
  sampled 42 58 25
  option swap_active_icon '!'
  option swap_warn_thresh 30
  shown swap_icon
  [[ -z "${output}" ]]
  option swap_warn_thresh soon

  # Act
  shown swap_icon

  # Assert
  [[ "${output}" == "!" ]]
}

@test "ram - the breakdown and the used of total print their sizes in their formats" {
  # Arrange
  option breakdown "1.5 0.8 1.5 1.5"
  option absolute "6.9G 9.9G"
  each "breakdown absolute"
  [[ "${lines[0]}" == "W 1.5G C 0.8G I 1.5G F 1.5G" ]]
  [[ "${lines[1]}" == "6.9G / 9.9G" ]]
  option breakdown_format '%s|%s|%s|%s'
  option absolute_format '%s of %s'

  # Act
  each "breakdown absolute"

  # Assert
  [[ "${lines[0]}" == "1.5|0.8|1.5|1.5" ]]
  [[ "${lines[1]}" == "6.9G of 9.9G" ]]
}

@test "ram - the top process prints its name, with each hash doubled, then its size" {
  # Arrange
  option top_process "200M /Applications/My #1 App"
  shown top_process
  [[ "${output}" == "/Applications/My ##1 App 200M" ]]
  option top_process_format '%s (%s)'

  # Act
  shown top_process

  # Assert
  [[ "${output}" == "/Applications/My ##1 App (200M)" ]]
}

@test "ram - the graph draws one bar per sample, eight heights from empty to full, and skips what is not a number" {
  # Arrange
  option history "0 13 25 38 x 50 63 75 88 100"

  # Act
  shown graph

  # Assert
  [[ "${output}" == $'\xe2\x96\x81\xe2\x96\x82\xe2\x96\x83\xe2\x96\x84\xe2\x96\x85\xe2\x96\x86\xe2\x96\x87\xe2\x96\x88\xe2\x96\x88' ]]
}

@test "ram - a history with no number draws no graph and no trend" {
  # Arrange
  option history "x y"

  # Act
  each "graph trend"

  # Assert
  [[ -z "${output}" ]]
}

@test "ram - the trend compares the newest sample with the oldest: three points or more move it off steady" {
  # Arrange
  local script='ram_revamped_load; for ram_test_samples in "40 41 43" "40 60 42" "43 41 40" "40" "x 40 y 50"; do RAM_REVAMPED_S_history="${ram_test_samples}"; ram_revamped_show trend; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[0]}" == $'\xe2\x86\x91' ]]
  [[ "${lines[1]}" == $'\xe2\x86\x92' ]]
  [[ "${lines[2]}" == $'\xe2\x86\x93' ]]
  [[ "${lines[3]}" == $'\xe2\x86\x92' ]]
  [[ "${lines[4]}" == $'\xe2\x86\x91' ]]
}

@test "ram - the trend's threshold and its three signs are the person's to set, and junk in the threshold means three" {
  # Arrange
  option trend_up up
  option trend_down down
  option trend_flat flat
  option trend_threshold 10
  local script='ram_revamped_load; for ram_test_samples in "40 49" "40 50" "50 40"; do RAM_REVAMPED_S_history="${ram_test_samples}"; ram_revamped_show trend; done; RAM_REVAMPED_S_trend_threshold=x; RAM_REVAMPED_S_history="40 43"; ram_revamped_show trend'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[*]}" == "flat up down up" ]]
}

@test "ram - the text reads the sample aloud, leaving out what it does not have" {
  # Arrange
  sampled 42 58 25
  shown text
  [[ "${output}" == "RAM 42% used, 58% available, swap 25%" ]]
  option swap ""
  shown text
  [[ "${output}" == "RAM 42% used, 58% available" ]]
  option available ""

  # Act
  shown text

  # Assert
  [[ "${output}" == "RAM 42% used" ]]
}

@test "ram - a metric's label is printed before its value, and never alone" {
  # Arrange
  sampled
  option percentage_label 'M:'
  option pressure_label 'P:'
  shown pressure
  [[ -z "${output}" ]]

  # Act
  shown percentage

  # Assert
  [[ "${output}" == "M: 42%" ]]
}

@test "ram - the nerd set puts its glyph before every labelled metric" {
  # Arrange
  sampled
  option icons nerd
  option pressure 17
  option breakdown "1.5 0.8 1.5 1.5"
  option absolute "6.9G 9.9G"
  option commit 63
  option reclaimable 3.9G
  option top_process "200M tmux"
  option history "40 50"

  # Act
  each "percentage available swap pressure breakdown absolute commit reclaimable top_process graph trend"

  # Assert
  [[ "${lines[0]}" == $'\xf3\xb0\x8a\x9a 42%' ]]
  [[ "${lines[1]}" == $'\xf3\xb0\x8d\x9b 58%' ]]
  [[ "${lines[2]}" == $'\xf3\xb0\xbe\xb4 25%' ]]
  [[ "${lines[3]}" == $'\xf3\xb0\xbe\x86 17%' ]]
  [[ "${lines[4]}" == $'\xf3\xb0\x9e\xaf W 1.5G C 0.8G I 1.5G F 1.5G' ]]
  [[ "${lines[5]}" == $'\xf3\xb0\x86\xbc 6.9G / 9.9G' ]]
  [[ "${lines[6]}" == $'\xf3\xb0\x92\xa0 63%' ]]
  [[ "${lines[7]}" == $'\xf3\xb0\x91\x8c 3.9G' ]]
  [[ "${lines[8]}" == $'\xf3\xb0\xa3\x86 tmux 200M' ]]
  [[ "${lines[9]}" == $'\xf3\xb0\x9e\xb1 \xe2\x96\x84\xe2\x96\x85' ]]
  [[ "${lines[10]}" == $'\xf3\xb0\x94\xb5 \xe2\x86\x91' ]]
}

@test "ram - in the nerd set the icon, the colours and the text take no glyph" {
  # Arrange
  sampled
  option icons nerd
  option low_fg_color '#[fg=green]'
  option swap_active_icon '!'

  # Act
  each "icon fg_color swap_icon text"

  # Assert
  [[ "${lines[0]}" == $'\xe2\x96\xb0\xe2\x96\xb1\xe2\x96\xb1' ]]
  [[ "${lines[1]}" == "#[fg=green]" ]]
  [[ "${lines[2]}" == "!" ]]
  [[ "${lines[3]}" == "RAM 42% used, 58% available, swap 25%" ]]
}

@test "ram - in the nerd set a metric's own label wins, and a label set to nothing means the default, so its glyph stays" {
  # Arrange
  sampled
  option icons nerd
  option percentage_label 'M:'
  option swap_label ''

  # Act
  each "percentage swap"

  # Assert
  [[ "${lines[0]}" == "M: 42%" ]]
  [[ "${lines[1]}" == $'\xf3\xb0\xbe\xb4 25%' ]]
}

@test "ram - the plain set labels nothing" {
  # Arrange
  sampled

  # Act
  each "percentage available swap"

  # Assert
  [[ "${lines[*]}" == "42% 58% 25%" ]]
}

@test "ram - fixed width pads the three percentages on the left to four characters and leaves the rest alone" {
  # Arrange
  sampled 9 58 100
  option reclaimable 3.9G
  option fixed_width on

  # Act
  each "percentage available swap reclaimable"

  # Assert
  [[ "${lines[0]}" == "  9%" ]]
  [[ "${lines[1]}" == " 58%" ]]
  [[ "${lines[2]}" == "100%" ]]
  [[ "${lines[3]}" == "3.9G" ]]
}

@test "ram - a metric's own width wins over the fixed width, counts characters and never cuts" {
  # Arrange
  sampled 9
  option fixed_width on
  option percentage_width 6
  option top_process "200M $(printf 'caf\303\251')"
  option top_process_width 11
  option reclaimable 3.9G
  option reclaimable_width 2
  option available_width wide
  shown percentage
  [[ "${output}" == "    9%" ]]
  shown top_process
  [[ "${output}" == "  $(printf 'caf\303\251') 200M" ]]
  shown reclaimable
  [[ "${output}" == "3.9G" ]]

  # Act
  shown available

  # Assert
  [[ "${output}" == " 58%" ]]
}

@test "ram - a label goes before the padded value" {
  # Arrange
  sampled 9
  option percentage_label 'M:'
  option percentage_width 5

  # Act
  shown percentage

  # Assert
  [[ "${output}" == "M:    9%" ]]
}

@test "ram - a fresh sample is printed with one tmux read and no write" {
  # Arrange
  sampled 42 58 25 999999

  # Act
  status_of percentage

  # Assert
  [[ "${output}" == "42%" ]]
  run sends
  [[ -z "${output}" ]]
  run sent '^display-message -p'
  [[ "${output}" == "1" ]]
}

@test "ram - a sample older than the interval is printed at once while the memory is read behind it" {
  # Arrange
  meminfo
  sampled 42 58 25 999990

  # Act
  status_of percentage

  # Assert
  [[ "${output}" == "42%" ]]
  eventually holds percent 75
  eventually holds percent_lock 0
  holds percent_ts 1000000
}

@test "ram - with nothing stored yet the placeholder is empty and the first sample starts" {
  # Arrange
  meminfo

  # Act
  status_of text

  # Assert
  [[ -z "${output}" ]]
  eventually holds percent 75
}

@test "ram - a sample under way is left to finish, and one whose lock is old or has no time is started again" {
  # Arrange
  meminfo
  sampled 42 58 25 999900
  option percent_lock 1
  option percent_lock_ts 999997
  status_of percentage
  run sends
  [[ -z "${output}" ]]
  option percent_lock_ts 999970
  status_of percentage
  eventually holds percent 75
  eventually holds percent_lock 0
  sampled 42 58 25 999900
  option percent_lock 1
  option percent_lock_ts ""

  # Act
  status_of percentage

  # Assert
  eventually holds percent 75
}

@test "ram - the interval comes from its setting, and junk there means five seconds" {
  # Arrange
  meminfo
  sampled 42 58 25 999990
  option interval 60
  status_of percentage
  run sends
  [[ -z "${output}" ]]
  option interval soon

  # Act
  status_of percentage

  # Assert
  eventually holds percent 75
}

@test "ram - a placeholder asked for by hand has its figure read even when the status line does not use it" {
  # Arrange
  meminfo
  processes
  sampled 42 58 25 999990
  option published percentage

  # Act
  status_of top_process

  # Assert
  [[ -z "${output}" ]]
  eventually holds top_process "200M /Applications/My App.app/Contents/MacOS/My App"
}

@test "ram - a tick samples the memory and publishes every metric the status line uses in one tmux call" {
  # Arrange
  meminfo
  processes "  900 init
204800 My #1"
  option published "percentage top_process"
  printf 'client-a\n' >"${FAKE}/clients"

  # Act
  lib_run ram 'ram_revamped_tick'

  # Assert
  [[ "${status}" -eq 0 ]]
  holds out_percentage "75%%"
  holds out_top_process "My ##1 200M"
  run sent 'set-option -gq @ram_revamped_out_percentage 75%% ; set-option -gq @ram_revamped_out_top_process My ##1 200M ; refresh-client -S -t client-a'
  [[ "${output}" == "1" ]]
}

@test "ram - a tick skips a doubled space in the list of metrics" {
  # Arrange
  meminfo
  option published "percentage  available"

  # Act
  lib_run ram 'ram_revamped_tick'

  # Assert
  holds out_percentage "75%%"
  holds out_available "25%%"
  run sent '@ram_revamped_out_ '
  [[ "${output}" == "0" ]]
}

@test "ram - a tick publishes nothing when the status line uses no metric, or when tmux takes no write" {
  # Arrange
  meminfo
  lib_run ram 'ram_revamped_tick'
  run sent '@ram_revamped_out_'
  [[ "${output}" == "0" ]]
  option published "percentage"
  : >"${FAKE}/refused"

  # Act
  lib_run ram 'ram_revamped_tick'

  # Assert
  [[ "${status}" -eq 0 ]]
  run sent '@ram_revamped_out_'
  [[ "${output}" == "0" ]]
}

@test "ram - a tmux version is read out of its banner and compared part by part" {
  # Arrange
  local script='for banner in "tmux 3.6a" "tmux next-3.7" "nonsense"; do printf "[%s]" "$(ram_revamped_parse_version "${banner}")"; done; for pair in "3.6 3.2" "3.2 3.2" "3.1 3.2" "4.0 3.2" "2.9 3.2" " 3.2" "x 3.2"; do if ram_revamped_version_ge ${pair}; then printf y; else printf n; fi; done'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${output}" == "[3.6][3.7][]yynynnn" ]]
}
