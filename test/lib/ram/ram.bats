#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _RAM_REVAMPED_RAM_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/ram/ram.sh"
}

teardown() {
  cleanup_test_environment
}

@test "ram.sh - _meminfo_field reads a key" {
  local txt=$'MemTotal:       16000 kB\nMemAvailable:    4000 kB'
  [[ "$(_meminfo_field "${txt}" MemTotal)" == "16000" ]]
  [[ "$(_meminfo_field "${txt}" MemAvailable)" == "4000" ]]
}

@test "ram.sh - ram_pct_from_meminfo computes used percent" {
  local txt=$'MemTotal:       1000 kB\nMemAvailable:    250 kB'
  [[ "$(ram_pct_from_meminfo "${txt}")" == "75" ]]
}

@test "ram.sh - ram_pct_from_meminfo is 0 with missing fields" {
  [[ "$(ram_pct_from_meminfo "")" == "0" ]]
}

@test "ram.sh - _vmstat_pages reads a label" {
  local txt=$'Pages free:    100.\nPages active:  300.'
  [[ "$(_vmstat_pages "${txt}" "Pages free")" == "100" ]]
}

@test "ram.sh - ram_pct_from_vmstat computes used percent" {
  local txt=$'Pages free:                  100.\nPages active:                300.\nPages inactive:              100.\nPages speculative:             0.\nPages wired down:            100.\nPages occupied by compressor:  0.'
  [[ "$(ram_pct_from_vmstat "${txt}")" == "67" ]]
}

@test "ram.sh - ram_pct_from_vmstat is 0 with no pages" {
  [[ "$(ram_pct_from_vmstat "")" == "0" ]]
}

@test "ram.sh - read_ram_percentage reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'MemTotal:  1000 kB\nMemAvailable: 250 kB\n'; }
  [[ "$(read_ram_percentage)" == "75" ]]
}

@test "ram.sh - read_ram_percentage reads vm_stat on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_vmstat() {
    printf 'Pages free: 100.\nPages active: 300.\nPages inactive: 100.\nPages speculative: 0.\nPages wired down: 100.\nPages occupied by compressor: 0.\n'
  }
  [[ "$(read_ram_percentage)" == "67" ]]
}

@test "ram.sh - read_ram_percentage is 0 on macOS without vm_stat" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 1; }
  [[ "$(read_ram_percentage)" == "0" ]]
}

@test "ram.sh - read_ram_percentage is 0 on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ "$(read_ram_percentage)" == "0" ]]
}

@test "ram.sh - avail_from_meminfo computes available percent" {
  local txt=$'MemTotal: 1000 kB\nMemAvailable: 250 kB'
  [[ "$(avail_from_meminfo "${txt}")" == "25" ]]
  [[ "$(avail_from_meminfo "")" == "0" ]]
}

@test "ram.sh - avail_from_vmstat computes available percent" {
  local txt=$'Pages free: 100.\nPages active: 300.\nPages inactive: 100.\nPages speculative: 0.\nPages wired down: 100.\nPages occupied by compressor: 0.'
  [[ "$(avail_from_vmstat "${txt}")" == "33" ]]
  [[ "$(avail_from_vmstat "")" == "0" ]]
}

@test "ram.sh - swap_from_meminfo computes used and total" {
  local txt=$'SwapTotal: 2048 kB\nSwapFree: 512 kB'
  [[ "$(swap_from_meminfo "${txt}")" == "1536 2048" ]]
}

@test "ram.sh - swap_from_sysctl parses vm.swapusage" {
  [[ "$(swap_from_sysctl 'vm.swapusage: total = 2048.00M  used = 512.00M  free = 1536.00M')" == "524288 2097152" ]]
}

@test "ram.sh - swap_pct computes percent and handles empty swap" {
  [[ "$(swap_pct 512 2048)" == "25" ]]
  [[ -z "$(swap_pct 0 0)" ]]
}

@test "ram.sh - read_available uses meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'MemTotal: 1000 kB\nMemAvailable: 400 kB\n'; }
  [[ "$(read_available)" == "40" ]]
}

@test "ram.sh - read_available uses vm_stat on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_vmstat() { printf 'Pages free: 100.\nPages active: 300.\nPages inactive: 100.\nPages speculative: 0.\nPages wired down: 100.\nPages occupied by compressor: 0.\n'; }
  [[ "$(read_available)" == "33" ]]
}

@test "ram.sh - read_available is 0 on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ "$(read_available)" == "0" ]]
}

@test "ram.sh - read_swap reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'SwapTotal: 2048 kB\nSwapFree: 1024 kB\n'; }
  [[ "$(read_swap)" == "50" ]]
}

@test "ram.sh - read_swap reads sysctl on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  _read_swapusage() { echo 'vm.swapusage: total = 2048.00M  used = 1024.00M  free = 1024.00M'; }
  [[ "$(read_swap)" == "50" ]]
}

@test "ram.sh - read_swap is empty without swap" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'SwapTotal: 0 kB\nSwapFree: 0 kB\n'; }
  [[ -z "$(read_swap)" ]]
}

@test "ram.sh - psi_from_text extracts the some avg10 integer" {
  local txt=$'some avg10=2.34 avg60=1.10 avg300=0.50 total=12345\nfull avg10=1.00 avg60=0.50 avg300=0.20 total=6789'
  [[ "$(psi_from_text "${txt}")" == "2" ]]
}

@test "ram.sh - psi_from_text is empty without a some line" {
  [[ -z "$(psi_from_text "")" ]]
}

@test "ram.sh - pressure_from_macos extracts the free percentage" {
  [[ "$(pressure_from_macos 'System-wide memory free percentage: 43%')" == "43" ]]
}

@test "ram.sh - pressure_from_macos is empty without the line" {
  [[ -z "$(pressure_from_macos "")" ]]
}

@test "ram.sh - read_pressure reads PSI on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_psi_memory() { printf 'some avg10=5.00 avg60=2.00 avg300=1.00 total=1\nfull avg10=0.00 avg60=0.00 avg300=0.00 total=0\n'; }
  [[ "$(read_pressure)" == "5" ]]
}

@test "ram.sh - read_pressure reads memory_pressure on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_memory_pressure_macos() { printf 'System-wide memory free percentage: 60%%\n'; }
  [[ "$(read_pressure)" == "60" ]]
}

@test "ram.sh - read_pressure is empty on macOS without memory_pressure" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 1; }
  [[ -z "$(read_pressure)" ]]
}

@test "ram.sh - read_pressure is empty on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ -z "$(read_pressure)" ]]
}

@test "ram.sh - breakdown_from_vmstat converts pages to megabytes" {
  local txt=$'Pages free: 4.\nPages active: 9.\nPages inactive: 3.\nPages wired down: 2.\nPages occupied by compressor: 1.'
  [[ "$(breakdown_from_vmstat "${txt}" 1048576)" == "2 1 3 4" ]]
}

@test "ram.sh - breakdown_from_meminfo maps the Linux fields" {
  local txt=$'MemFree: 4096 kB\nCached: 3072 kB\nBuffers: 2048 kB'
  [[ "$(breakdown_from_meminfo "${txt}")" == "2 0 3 4" ]]
}

@test "ram.sh - read_breakdown reads meminfo on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  _read_meminfo() { printf 'MemFree: 4096 kB\nCached: 3072 kB\nBuffers: 2048 kB\n'; }
  [[ "$(read_breakdown)" == "2 0 3 4" ]]
}

@test "ram.sh - read_breakdown reads vm_stat on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_vmstat() { printf 'Pages free: 4.\nPages inactive: 3.\nPages wired down: 2.\nPages occupied by compressor: 1.\n'; }
  _read_pagesize() { echo 1048576; }
  [[ "$(read_breakdown)" == "2 1 3 4" ]]
}

@test "ram.sh - host-probe seams are callable" {
  run _read_meminfo
  run _read_vmstat
  run _read_swapusage
  run _read_pagesize
  run _read_psi_memory
  run _read_memory_pressure_macos
  true
}
