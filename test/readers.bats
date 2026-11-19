#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/ram_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/ram_helpers.bash"

sample() {
  lib_run ram 'RAM_REVAMPED_WANT="'"${1:-}"'"; ram_revamped_load; ram_revamped_refresh; printf "stored=%s\n" "${RAM_REVAMPED_STORED}"'
}

@test "readers - on macOS a sample turns the pages of vm_stat into every figure" {
  # Arrange
  macos
  pages
  swapping

  # Act
  sample

  # Assert
  [[ "${output}" == "stored=1" ]]
  holds percent 69
  holds available 31
  holds breakdown "1.5 0.8 1.5 1.5"
  holds absolute "6.9G 9.9G"
  holds reclaimable 1.2G
  holds commit ""
  holds percent_ts 1000000
}

@test "readers - on macOS the swap comes from sysctl, and no swap leaves it empty" {
  # Arrange
  macos
  pages
  swapping
  sample
  holds swap 25
  sysctl_says "vm.swapusage: total = 0.00M  used = 0.00M  free = 0.00M  (encrypted)"

  # Act
  sample

  # Assert
  holds swap ""
}

@test "readers - on macOS a header without the page size asks sysctl for it, and falls back to 4096 bytes" {
  # Arrange
  macos
  pages "Mach Virtual Memory Statistics:"
  swapping 8192
  sample
  holds absolute "3.4G 5.0G"
  swapping

  # Act
  sample

  # Assert
  holds absolute "1.7G 2.5G"
  run asked
  [[ "${output}" == *"sysctl -n hw.pagesize"* ]]
}

@test "readers - on macOS a header with the page size asks sysctl only for the swap" {
  # Arrange
  macos
  pages
  swapping

  # Act
  sample

  # Assert
  run asked
  [[ "${output}" == $'vm_stat \nsysctl vm.swapusage' ]]
}

@test "readers - on macOS without vm_stat every figure is stored empty and sysctl is not asked" {
  # Arrange
  macos
  swapping
  option percent 40
  option history "40"

  # Act
  sample

  # Assert
  [[ "${output}" == "stored=1" ]]
  holds percent ""
  holds available ""
  holds swap ""
  holds history "40"
  holds percent_ts 1000000
  run asked
  [[ -z "${output}" ]]
}

@test "readers - on macOS the pressure is the wired and compressed share, read only for a placeholder that shows it" {
  # Arrange
  macos
  pages
  swapping
  sample percentage
  holds pressure ""
  holds pressure_ts ""

  # Act
  sample pressure_fg_color

  # Assert
  holds pressure 23
  holds pressure_ts 1000000
}

@test "readers - on Linux a sample turns /proc/meminfo into every figure" {
  # Arrange
  meminfo

  # Act
  sample

  # Assert
  [[ "${output}" == "stored=1" ]]
  holds percent 75
  holds available 25
  holds swap 25
  holds breakdown "0.5 0.0 2.9 1.9"
  holds absolute "11.4G 15.3G"
  holds commit 63
  holds reclaimable 3.9G
  holds percent_ts 1000000
}

@test "readers - on Linux no swap and no commit limit leave both empty, and sizes below a gigabyte keep their unit" {
  # Arrange
  meminfo "MemTotal: 2048 kB
MemFree: 512 kB
MemAvailable: 512 kB
Buffers: 0 kB
Cached: 512 kB
SwapTotal: 0 kB
SwapFree: 0 kB
SReclaimable: 0 kB
CommitLimit: 0 kB
Committed_AS: 100 kB"

  # Act
  sample

  # Assert
  holds percent 75
  holds swap ""
  holds commit ""
  holds absolute "1.5M 2M"
  holds reclaimable 512K
}

@test "readers - on Linux more available than total counts as nothing used" {
  # Arrange
  meminfo "MemTotal: 1000 kB
MemAvailable: 1200 kB"

  # Act
  sample

  # Assert
  holds percent 0
  holds absolute "0K 1000K"
}

@test "readers - on Linux a meminfo that cannot be read stores every figure empty" {
  # Arrange
  proc_file other ""
  option percent 40

  # Act
  sample

  # Assert
  [[ "${output}" == "stored=1" ]]
  holds percent ""
  holds absolute ""
  holds reclaimable ""
}

@test "readers - on Linux a meminfo without its total stores every figure empty" {
  # Arrange
  meminfo "MemFree: 512 kB
Cached: 512 kB"

  # Act
  sample

  # Assert
  holds percent ""
  holds breakdown ""
}

@test "readers - on Linux the pressure is the ten second average of /proc/pressure/memory, rounded" {
  # Arrange
  meminfo
  stalled 2.34
  sample pressure
  holds pressure 2
  now 1000061
  stalled 12.5

  # Act
  sample pressure

  # Assert
  holds pressure 12
  holds pressure_ts 1000061
}

@test "readers - on Linux a kernel without the pressure file stores the pressure empty" {
  # Arrange
  meminfo
  option pressure 9

  # Act
  sample pressure

  # Assert
  holds pressure ""
  holds pressure_ts 1000000
}

@test "readers - the pressure and the top process are read again only after the detail interval" {
  # Arrange
  meminfo
  stalled 2.34
  processes
  option pressure 7
  option pressure_ts 999940
  option top_process "1M old"
  option top_process_ts 999940

  # Act
  sample "pressure top_process"

  # Assert
  holds pressure 7
  holds top_process "1M old"
  run asked
  [[ "${output}" == "cat /proc/meminfo" ]]
}

@test "readers - a detail interval the person sets decides when they are read again" {
  # Arrange
  meminfo
  stalled 2.34
  processes
  option detail_interval 30
  option pressure 7
  option pressure_ts 999969
  option top_process_ts 999969

  # Act
  sample "pressure top_process"

  # Assert
  holds pressure 2
  holds top_process "200M /Applications/My App.app/Contents/MacOS/My App"
  holds top_process_ts 1000000
}

@test "readers - the top process is the one with the most resident memory, with its whole name" {
  # Arrange
  meminfo
  processes

  # Act
  sample top_process

  # Assert
  holds top_process "200M /Applications/My App.app/Contents/MacOS/My App"
  run asked
  [[ "${output}" == *"ps axo rss=,comm="* ]]
}

@test "readers - a ps that writes sizes with a unit, as BusyBox does, is read in kilobytes" {
  # Arrange
  meminfo
  processes "  900 init
  12m sshd
 1.5g java -jar
  20m tmux"

  # Act
  sample top_process

  # Assert
  holds top_process "1.5G java -jar"
}

@test "readers - a ps that prints nothing leaves the top process empty, and it is not asked without its placeholder" {
  # Arrange
  meminfo
  says ps ""
  option top_process "1M old"
  sample top_process
  holds top_process ""
  : >"${FAKE}/asked"

  # Act
  sample percentage

  # Assert
  run asked
  [[ "${output}" == "cat /proc/meminfo" ]]
}

@test "readers - each sample joins the history, which keeps the newest samples up to the size set" {
  # Arrange
  meminfo
  option history "10 20 30"
  sample
  holds history "10 20 30 75"
  option history_size 2

  # Act
  sample

  # Assert
  holds history "75 75"
}

@test "readers - a history size of zero or one that is not a number keeps thirty samples" {
  # Arrange
  meminfo
  option history "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30"
  option history_size 0
  sample
  holds history "2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 75"
  option history_size many

  # Act
  sample

  # Assert
  holds history "3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 75 75"
}

@test "readers - a locale with a decimal comma still stores sizes with a point" {
  # Arrange
  macos
  pages
  swapping
  export LC_ALL=pt_BR.UTF-8 LC_NUMERIC=pt_BR.UTF-8

  # Act
  sample

  # Assert
  holds breakdown "1.5 0.8 1.5 1.5"
  holds absolute "6.9G 9.9G"
}

@test "readers - a whole sample reaches tmux in one call" {
  # Arrange
  meminfo
  stalled
  processes

  # Act
  sample "pressure top_process"

  # Assert
  run sends
  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" == "set-option -gq @ram_revamped_percent 75 ; set-option -gq @ram_revamped_available 25 ; "*" ; set-option -gq @ram_revamped_top_process_ts 1000000" ]]
}

@test "readers - a sample tmux refuses is reported as not stored" {
  # Arrange
  meminfo
  printf 'refused\n' >"${FAKE}/refused"

  # Act
  sample

  # Assert
  [[ "${output}" == "stored=0" ]]
  holds percent ""
}

@test "readers - with logging on a sample without figures is written to the log, and with it off nothing is" {
  # Arrange
  proc_file other ""
  sample
  [[ ! -e "${HOME}/.tmux/ram-revamped-logs/ram-revamped.log" ]]
  option enable_logging 1

  # Act
  sample

  # Assert
  run cat "${HOME}/.tmux/ram-revamped-logs/ram-revamped.log"
  [[ "${output}" == *"[ram] no memory figures were read" ]]
}
