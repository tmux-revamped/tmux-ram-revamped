#!/usr/bin/env bash
#
# doctor.sh: capability report.
#
# Explains which platform was detected, which source feeds each metric, and
# which optional tools are present. It probes only command availability and the
# OS; it never executes a monitor.

[[ -n "${_RAM_REVAMPED_DOCTOR_LOADED:-}" ]] && return 0
_RAM_REVAMPED_DOCTOR_LOADED=1

_RAM_DOCTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_DOCTOR_DIR}/../utils/has-command.sh"
# shellcheck source=/dev/null
source "${_RAM_DOCTOR_DIR}/../utils/platform.sh"

# _doctor_probe LABEL COMMAND -> one line stating whether COMMAND is on PATH.
_doctor_probe() {
  if has_command "${2}"; then
    echo "${1}: ${2} found"
  else
    echo "${1}: ${2} missing"
  fi
}

# ram_doctor -> print the capability report to stdout.
ram_doctor() {
  echo "tmux-ram-revamped doctor"
  echo "platform: $(platform_os)"
  if is_linux; then
    echo "source: /proc/meminfo (Linux)"
  elif is_macos; then
    echo "source: vm_stat (macOS)"
  else
    echo "source: none (unsupported platform)"
  fi
  _doctor_probe "swap" "vm_stat"
  _doctor_probe "pressure" "vm_stat"
  _doctor_probe "top process" "ps"
  _doctor_probe "popup monitor" "btop"
}

export -f _doctor_probe
export -f ram_doctor
