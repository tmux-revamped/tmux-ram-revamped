#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/ram_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/ram_helpers.bash"

everything() {
  meminfo
  stalled
  processes
  option history "60 70"
}

@test "commands - status prints one placeholder from the stored sample" {
  # Arrange
  sampled 42 58 25 1000000

  # Act
  tool status text

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "RAM 42% used, 58% available, swap 25%" ]]
}

@test "commands - status without a name is a usage error, and an unknown name a bad value" {
  # Arrange
  tool status
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: no placeholder given. run 'ram-revamped help' for usage." ]]

  # Act
  tool status free

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: status must be percentage, icon, fg_color, bg_color, available, swap, swap_icon, swap_color, pressure, pressure_fg_color, breakdown, absolute, commit, reclaimable, top_process, graph, trend or text, got: free" ]]
}

@test "commands - refresh samples the memory now and says how much is in use" {
  # Arrange
  meminfo

  # Act
  tool refresh

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "Refreshed. 75% of the memory is in use." ]]
  holds percent 75
}

@test "commands - refresh reads the pressure and the top process only when the status line shows them" {
  # Arrange
  everything
  tool refresh
  run asked
  [[ "${output}" == "cat /proc/meminfo" ]]
  : >"${FAKE}/asked"
  option published "pressure top_process"

  # Act
  tool refresh

  # Assert
  run asked
  [[ "${output}" == $'cat /proc/meminfo\ncat /proc/pressure/memory\nps axo rss=,comm=' ]]
}

@test "commands - refresh says when no figures were found, and fails when no tmux server takes the sample" {
  # Arrange
  proc_file other ""
  tool refresh
  [[ "${output}" == "Refreshed. No memory figures were found." ]]
  meminfo
  printf 'refused\n' >"${FAKE}/refused"

  # Act
  tool refresh

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: no tmux server is running, so the sample has nowhere to go" ]]
}

@test "commands - card reads everything now and prints one row per figure" {
  # Arrange
  everything

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == "Used               75%" ]]
  [[ "${lines[1]}" == "Available          25%" ]]
  [[ "${lines[2]}" == "Swap               25%" ]]
  [[ "${lines[3]}" == "Pressure           2%" ]]
  [[ "${lines[4]}" == "Used of total      11.4G of 15.3G" ]]
  [[ "${lines[5]}" == "Breakdown          W 0.5G C 0.0G I 2.9G F 1.9G" ]]
  [[ "${lines[6]}" == "Commit             63%" ]]
  [[ "${lines[7]}" == "Reclaimable        3.9G" ]]
  [[ "${lines[8]}" == "Top process        /Applications/My App.app/Contents/MacOS/My App, 200M" ]]
  [[ "${lines[9]}" == $'History            \xe2\x96\x85\xe2\x96\x86\xe2\x96\x87' ]]
  [[ "${lines[10]}" == $'Trend              \xe2\x86\x91' ]]
  [[ "${lines[11]}" == "Read. 75% of the memory is in use." ]]
  [[ "${#lines[@]}" -eq 12 ]]
}

@test "commands - with no figures the card has a dash in every row and says so" {
  # Arrange
  proc_file other ""

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == "Used               -" ]]
  [[ "${lines[5]}" == "Breakdown          -" ]]
  [[ "${lines[8]}" == "Top process        -" ]]
  [[ "${lines[10]}" == "Trend              -" ]]
  [[ "${lines[11]}" == "Read. No memory figures were found." ]]
}

@test "commands - where gum draws the card is a table and a closing sentence" {
  # Arrange
  everything
  export REVAMPED_TEST_GUM=1

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Figure"*"Value"* ]]
  [[ "${output}" == *"Used of total"*"11.4G of 15.3G"* ]]
  [[ "${output}" == *"Read. 75% of the memory is in use."* ]]
}

@test "commands - apply binds the popup key and prints nothing" {
  # Arrange
  local started='^bind-key -N Memory details M-r run-shell'

  # Act
  tool apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  run sent "${started}"
  [[ "${output}" == "1" ]]
}

@test "commands - popup opens a monitor in a tmux popup and prints nothing" {
  # Arrange
  quiet htop ':'
  local opened='^display-popup -E -w 80% -h 60% htop$'

  # Act
  tool popup

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  run sent "${opened}"
  [[ "${output}" == "1" ]]
}

@test "commands - list prints what apply would send, and --json the same plan as one object" {
  # Arrange
  local path
  path=$(bin_path)
  option popup_key 'C-"'
  tool list
  [[ "${output}" == "bind-key -N Memory details C-\" run-shell ${path} popup" ]]

  # Act
  tool list --json

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == '{"bindings":[["bind-key","-N","Memory details","C-\"","run-shell","'*' popup"]]}' ]]
  run sends
  [[ -z "${output}" ]]
}

@test "commands - --json with any command but list is a usage error" {
  # Arrange
  sampled

  # Act
  tool --json card

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: option '--json' works only with list. run 'ram-revamped help' for usage." ]]
}

@test "commands - the command line wins over the environment, and the environment over the tmux option" {
  # Arrange
  sampled 42 58 25 1000000
  option percentage_format 'option %s'
  tool status percentage
  [[ "${output}" == "option 42" ]]
  export RAM_REVAMPED_PERCENTAGE_FORMAT='environment %s'
  tool status percentage
  [[ "${output}" == "environment 42" ]]

  # Act
  tool --percentage-format 'line %s' status percentage

  # Assert
  [[ "${output}" == "line 42" ]]
}

@test "commands - an option takes its value after a space or an equals sign, and an empty label leaves the nerd glyph" {
  # Arrange
  sampled 42 58 25 1000000
  option icons nerd
  tool --percentage-label=M: status percentage
  [[ "${output}" == "M: 42%" ]]

  # Act
  tool --percentage-label '' status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == $'\xf3\xb0\x8a\x9a 42%' ]]
}

@test "commands - an unknown option, one without its value and a word after a double dash are usage errors" {
  # Arrange
  tool --colour red status text
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: unknown option '--colour'. run 'ram-revamped help' for usage." ]]
  tool --colour=red status text
  [[ "${output}" == "ram-revamped: unknown option '--colour'. run 'ram-revamped help' for usage." ]]
  tool -x
  [[ "${output}" == "ram-revamped: unknown option '-x'. run 'ram-revamped help' for usage." ]]
  tool status --interval
  [[ "${output}" == "ram-revamped: option '--interval' needs a value. run 'ram-revamped help' for usage." ]]

  # Act
  tool -- --interval

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: unknown command '--interval'. run 'ram-revamped help' for usage." ]]
}

@test "commands - a bad number is reported alone, since the reader of the environment reads it to the end" {
  # Arrange
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  cat >"${BATS_TEST_TMPDIR}/stubs/env" <<'STUB'
#!/bin/sh
{ set +x; } 2>/dev/null
trap '' PIPE
printf 'RAM_REVAMPED_INTERVAL=soon\n'
count=0
while [ "${count}" -lt 4000 ]; do
  printf 'FILLER_%s=%0100d\n' "${count}" 0 || exit 1
  count=$((count + 1))
done
STUB
  chmod +x "${BATS_TEST_TMPDIR}/stubs/env"

  # Act
  tool status text

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: --interval must be a whole number, got: soon" ]]
}

@test "commands - a number is checked before anything runs, whichever setting carries it" {
  # Arrange
  tool --interval soon status text
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: --interval must be a whole number, got: soon" ]]
  tool --detail-interval often status text
  [[ "${output}" == "ram-revamped: --detail-interval must be a whole number, got: often" ]]
  tool --history-size long status text
  [[ "${output}" == "ram-revamped: --history-size must be a whole number, got: long" ]]
  tool --trend-threshold 1.5 status text
  [[ "${output}" == "ram-revamped: --trend-threshold must be a whole number, got: 1.5" ]]
  tool --swap-warn-thresh some status text
  [[ "${output}" == "ram-revamped: --swap-warn-thresh must be a whole number, got: some" ]]
  tool --top-process-width wide status text
  [[ "${output}" == "ram-revamped: --top-process-width must be a whole number, got: wide" ]]

  # Act
  tool --high-thresh most status text

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: --high-thresh must be a whole number, got: most" ]]
}

@test "commands - a width given as nothing is no width, and the fixed and the popup widths are not numbers" {
  # Arrange
  sampled 9 58 25 1000000

  # Act
  tool --percentage-width '' --fixed-width on --popup-width 90% status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "  9%" ]]
}

@test "commands - each choice is checked before anything runs" {
  # Arrange
  tool --icons emoji status text
  [[ "${output}" == "ram-revamped: --icons must be ascii or nerd, got: emoji" ]]
  tool --fixed-width yes status text
  [[ "${output}" == "ram-revamped: --fixed-width must be on or off, got: yes" ]]

  # Act
  tool --render both status text

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "ram-revamped: --render must be jobs or options, got: both" ]]
}

@test "commands - on Linux doctor names the two files it reads, ps and a default key someone else holds" {
  # Arrange
  local figures='meminfo +ok +/proc/meminfo, holds every figure but the pressure' stall='pressure +ok +/proc/pressure/memory, holds the pressure' top='ps +ok +.*/ps, names the process that holds the most memory' taken='keys +warn +already bound and left alone: M-r'
  meminfo
  stalled
  processes
  printf 'bind-key    -T prefix M-r     display-message mine\n' >"${FAKE}/keys"

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${figures} ]]
  [[ "${output}" =~ ${stall} ]]
  [[ "${output}" =~ ${top} ]]
  [[ "${output}" =~ ${taken} ]]
}

@test "commands - on Linux doctor warns about each source that is missing and exits 0" {
  # Arrange
  local figures='meminfo +warn +/proc/meminfo cannot be read, so every figure stays empty' stall='pressure +warn +/proc/pressure/memory cannot be read, so the pressure stays empty' top='ps +warn +without it the top process stays empty' free='keys +ok +every key it binds is free or its own'
  proc_file other ""

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${figures} ]]
  [[ "${output}" =~ ${stall} ]]
  [[ "${output}" =~ ${top} ]]
  [[ "${output}" =~ ${free} ]]
}

@test "commands - on macOS doctor names vm_stat and sysctl, and says the commit ratio has no source" {
  # Arrange
  local memory='vm_stat +ok +.*/vm_stat, reads the memory, the pressure and the breakdown' swap='sysctl +ok +.*/sysctl, reads the swap' commit='commit +warn +macOS keeps no commit limit, so the commit ratio stays empty'
  macos
  pages
  swapping

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${memory} ]]
  [[ "${output}" =~ ${swap} ]]
  [[ "${output}" =~ ${commit} ]]
}

@test "commands - on macOS doctor warns about each system tool that is missing" {
  # Arrange
  local memory='vm_stat +warn +without it every figure stays empty' swap='sysctl +warn +without it the swap stays empty'
  macos

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${memory} ]]
  [[ "${output}" =~ ${swap} ]]
}

@test "commands - doctor names the monitor the popup opens: btop, then htop, then what the system has" {
  # Arrange
  local first='monitor +ok +.*/btop, opens in the popup' second='monitor +ok +.*/htop, opens in the popup' pages='monitor +warn +neither btop nor htop is installed, so the popup runs vm_stat 1' free='monitor +warn +neither btop nor htop is installed, so the popup runs free -h -s 1' file='monitor +warn +neither btop, htop nor free is installed, so the popup prints /proc/meminfo'
  tool doctor
  [[ "${output}" =~ ${file} ]]
  quiet free ':'
  tool doctor
  [[ "${output}" =~ ${free} ]]
  macos
  tool doctor
  [[ "${output}" =~ ${pages} ]]
  quiet htop ':'
  tool doctor
  [[ "${output}" =~ ${second} ]]
  quiet btop ':'

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${first} ]]
}

@test "commands - doctor names a tmux option whose value it does not know" {
  # Arrange
  option render both
  option history_size lots

  # Act
  tool doctor

  # Assert
  run grep '^settings' <<<"${output}"
  [[ "${output}" == "settings           warn     unknown values: render=both history_size=lots" ]]
}
