#!/usr/bin/env bash
#
# ram.sh: RAM usage acquisition.
#
# Pure parsers turn command output into a used-memory percentage. Reader
# functions wrap the host probes behind thin seams so tests can stub them.

[[ -n "${_RAM_REVAMPED_RAM_LOADED:-}" ]] && return 0
_RAM_REVAMPED_RAM_LOADED=1

_RAM_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_RAM_LIB_DIR}/../utils/platform.sh"
# shellcheck source=/dev/null
source "${_RAM_LIB_DIR}/../utils/has-command.sh"

# _meminfo_field TEXT KEY -> the kB value for a /proc/meminfo key.
_meminfo_field() {
  printf '%s\n' "${1}" | LC_ALL=C awk -v k="${2}:" '$1 == k { print $2; exit }'
}

# ram_pct_from_meminfo TEXT -> integer used-memory percent from /proc/meminfo.
ram_pct_from_meminfo() {
  local total avail
  total=$(_meminfo_field "${1}" "MemTotal")
  avail=$(_meminfo_field "${1}" "MemAvailable")
  [[ "${total}" =~ ^[0-9]+$ && "${avail}" =~ ^[0-9]+$ && "${total}" -gt 0 ]] \
    || { echo 0; return 0; }
  LC_ALL=C awk -v t="${total}" -v a="${avail}" 'BEGIN { printf "%.0f", ((t - a) / t) * 100 }'
}

# _vmstat_pages TEXT LABEL -> the page count for a vm_stat label.
_vmstat_pages() {
  local line had_nocasematch=0
  shopt -q nocasematch && had_nocasematch=1
  shopt -s nocasematch
  while IFS= read -r line; do
    if [[ "${line}" == *"${2}"* && "${line}" =~ ([0-9]+) ]]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
      break
    fi
  done <<<"${1}"
  ((had_nocasematch)) || shopt -u nocasematch
}

# ram_pct_from_vmstat TEXT -> integer used-memory percent from vm_stat.
ram_pct_from_vmstat() {
  local free active inactive spec wired compressed
  free=$(_vmstat_pages "${1}" "Pages free")
  active=$(_vmstat_pages "${1}" "Pages active")
  inactive=$(_vmstat_pages "${1}" "Pages inactive")
  spec=$(_vmstat_pages "${1}" "Pages speculative")
  wired=$(_vmstat_pages "${1}" "Pages wired down")
  compressed=$(_vmstat_pages "${1}" "occupied by compressor")
  free=${free:-0}; active=${active:-0}; inactive=${inactive:-0}
  spec=${spec:-0}; wired=${wired:-0}; compressed=${compressed:-0}
  local used=$(( active + wired + compressed ))
  local total=$(( free + active + inactive + spec + wired + compressed ))
  (( total <= 0 )) && { echo 0; return 0; }
  LC_ALL=C awk -v u="${used}" -v t="${total}" 'BEGIN { printf "%.0f", (u / t) * 100 }'
}

# breakdown_from_vmstat TEXT PAGESIZE -> "wired compressed inactive free" in MB.
breakdown_from_vmstat() {
  local ps="${2:-4096}"
  printf '%s\n' "${1}" | awk -v ps="${ps}" '/Pages wired down:/{w=$NF} /occupied by compressor:/{c=$NF} /Pages inactive:/{i=$NF} /Pages free:/{f=$NF} END{gsub(/\./,"",w);gsub(/\./,"",c);gsub(/\./,"",i);gsub(/\./,"",f); printf "%d %d %d %d", (w+0)*ps/1048576, (c+0)*ps/1048576, (i+0)*ps/1048576, (f+0)*ps/1048576}'
}

# breakdown_from_meminfo TEXT -> "buffers 0 cached free" in MB, the Linux mapping.
breakdown_from_meminfo() {
  printf '%s\n' "${1}" | LC_ALL=C awk '/MemFree:/{f=$2} /^Cached:/{c=$2} /Buffers:/{b=$2} END{printf "%d %d %d %d", (b+0)/1024, 0, (c+0)/1024, (f+0)/1024}'
}

# Host-probe seams. Tests override these.
_read_meminfo() { cat /proc/meminfo 2>/dev/null; }
_read_vmstat() { vm_stat 2>/dev/null; }
_read_pagesize() { pagesize 2>/dev/null || sysctl -n hw.pagesize 2>/dev/null || echo 4096; }

# read_breakdown -> "wired compressed inactive free" in MB for the host.
read_breakdown() {
  if is_linux; then
    breakdown_from_meminfo "$(_read_meminfo)"
  elif is_macos && has_command vm_stat; then
    breakdown_from_vmstat "$(_read_vmstat)" "$(_read_pagesize)"
  fi
}

# read_ram_percentage -> used-memory percent for the host.
read_ram_percentage() {
  if is_linux; then
    ram_pct_from_meminfo "$(_read_meminfo)"
  elif is_macos && has_command vm_stat; then
    ram_pct_from_vmstat "$(_read_vmstat)"
  else
    echo 0
  fi
}

# avail_from_meminfo TEXT -> available-memory percent from /proc/meminfo.
avail_from_meminfo() {
  local total avail
  total=$(_meminfo_field "${1}" "MemTotal")
  avail=$(_meminfo_field "${1}" "MemAvailable")
  [[ "${total}" =~ ^[0-9]+$ && "${avail}" =~ ^[0-9]+$ && "${total}" -gt 0 ]] || { echo 0; return 0; }
  LC_ALL=C awk -v a="${avail}" -v t="${total}" 'BEGIN { printf "%.0f", (a / t) * 100 }'
}

# avail_from_vmstat TEXT -> available-memory percent from vm_stat.
avail_from_vmstat() {
  local free inactive spec active wired compressed
  free=$(_vmstat_pages "${1}" "Pages free"); inactive=$(_vmstat_pages "${1}" "Pages inactive")
  spec=$(_vmstat_pages "${1}" "Pages speculative"); active=$(_vmstat_pages "${1}" "Pages active")
  wired=$(_vmstat_pages "${1}" "Pages wired down"); compressed=$(_vmstat_pages "${1}" "occupied by compressor")
  free=${free:-0}; inactive=${inactive:-0}; spec=${spec:-0}
  active=${active:-0}; wired=${wired:-0}; compressed=${compressed:-0}
  local avail=$(( free + inactive + spec ))
  local total=$(( free + active + inactive + spec + wired + compressed ))
  (( total <= 0 )) && { echo 0; return 0; }
  LC_ALL=C awk -v a="${avail}" -v t="${total}" 'BEGIN { printf "%.0f", (a / t) * 100 }'
}

# swap_from_meminfo TEXT -> "<used_kb> <total_kb>" from /proc/meminfo.
swap_from_meminfo() {
  printf '%s\n' "${1}" | awk '/SwapTotal:/{t=$2} /SwapFree:/{f=$2} END{print (t+0)-(f+0), t+0}'
}

# swap_from_sysctl TEXT -> "<used_kb> <total_kb>" from `sysctl vm.swapusage`.
swap_from_sysctl() {
  local total used
  total=$(printf '%s' "${1}" | awk '{for(i=1;i<=NF;i++) if($i=="total"){gsub(/[^0-9.]/,"",$(i+2)); printf "%d",$(i+2)}}')
  used=$(printf '%s' "${1}" | awk '{for(i=1;i<=NF;i++) if($i=="used"){gsub(/[^0-9.]/,"",$(i+2)); printf "%d",$(i+2)}}')
  [[ "${total}" =~ ^[0-9]+$ ]] || total=0
  [[ "${used}" =~ ^[0-9]+$ ]] || used=0
  echo "$(( used * 1024 )) $(( total * 1024 ))"
}

# swap_pct USED_KB TOTAL_KB -> integer percent, empty when total is zero.
swap_pct() {
  [[ "${1}" =~ ^[0-9]+$ && "${2}" =~ ^[0-9]+$ && "${2}" -gt 0 ]] || { echo ""; return 0; }
  LC_ALL=C awk -v u="${1}" -v t="${2}" 'BEGIN { printf "%.0f", (u / t) * 100 }'
}

# psi_from_text TEXT -> integer `some avg10` percent from /proc/pressure/memory.
psi_from_text() {
  printf '%s\n' "${1}" | LC_ALL=C awk '/^some / { for (i = 1; i <= NF; i++) if ($i ~ /^avg10=/) { sub(/^avg10=/, "", $i); printf "%.0f", $i; exit } }'
}

# pressure_from_macos TEXT -> integer free percent from `memory_pressure`.
pressure_from_macos() {
  printf '%s\n' "${1}" | awk '/free percentage:/ { for (i = 1; i <= NF; i++) if ($i ~ /%/) { gsub(/[^0-9]/, "", $i); printf "%s", $i; exit } }'
}

_read_swapusage() { sysctl vm.swapusage 2>/dev/null; }
_read_psi_memory() { cat /proc/pressure/memory 2>/dev/null; }
_read_memory_pressure_macos() { memory_pressure 2>/dev/null; }

# read_available -> available-memory percent for the host.
read_available() {
  if is_linux; then
    avail_from_meminfo "$(_read_meminfo)"
  elif is_macos && has_command vm_stat; then
    avail_from_vmstat "$(_read_vmstat)"
  else
    echo 0
  fi
}

# read_swap -> swap used percent, empty when there is no swap.
read_swap() {
  local used total
  if is_linux; then
    read -r used total <<< "$(swap_from_meminfo "$(_read_meminfo)")"
  elif is_macos; then
    read -r used total <<< "$(swap_from_sysctl "$(_read_swapusage)")"
  fi
  swap_pct "${used:-0}" "${total:-0}"
}

# read_pressure -> memory-pressure integer for the host, empty when unavailable.
read_pressure() {
  if is_linux; then
    psi_from_text "$(_read_psi_memory)"
  elif is_macos && has_command memory_pressure; then
    pressure_from_macos "$(_read_memory_pressure_macos)"
  fi
}

export -f _meminfo_field
export -f ram_pct_from_meminfo
export -f _vmstat_pages
export -f ram_pct_from_vmstat
export -f avail_from_meminfo
export -f avail_from_vmstat
export -f swap_from_meminfo
export -f swap_from_sysctl
export -f swap_pct
export -f psi_from_text
export -f pressure_from_macos
export -f breakdown_from_vmstat
export -f breakdown_from_meminfo
export -f _read_meminfo
export -f _read_vmstat
export -f _read_pagesize
export -f _read_swapusage
export -f _read_psi_memory
export -f _read_memory_pressure_macos
export -f read_ram_percentage
export -f read_available
export -f read_swap
export -f read_pressure
export -f read_breakdown

# --- Absolute, commit, reclaimable, and top-process acquisition --------------

# absolute_from_meminfo TEXT -> "<used_kb> <total_kb>" from /proc/meminfo.
absolute_from_meminfo() {
  printf '%s\n' "${1}" | awk '/MemTotal:/{t=$2} /MemAvailable:/{a=$2} END{u=(t+0)-(a+0); if(u<0)u=0; printf "%d %d", u, t+0}'
}

# absolute_from_vmstat TEXT PAGESIZE -> "<used_kb> <total_kb>" from vm_stat.
absolute_from_vmstat() {
  local ps="${2:-4096}"
  printf '%s\n' "${1}" | LC_ALL=C awk -v ps="${ps}" '/Pages free:/{f=$NF} /Pages active:/{a=$NF} /Pages inactive:/{i=$NF} /Pages speculative:/{s=$NF} /Pages wired down:/{w=$NF} /occupied by compressor:/{c=$NF} END{u=(a+w+c)*ps/1024; t=(f+a+i+s+w+c)*ps/1024; printf "%d %d", u, t}'
}

# commit_from_meminfo TEXT -> Committed_AS/CommitLimit percent, empty if absent.
commit_from_meminfo() {
  printf '%s\n' "${1}" | LC_ALL=C awk '/CommitLimit:/{l=$2} /Committed_AS:/{c=$2} END{if((l+0)>0) printf "%.0f", ((c+0)/(l+0))*100}'
}

# reclaimable_from_meminfo TEXT -> reclaimable cache in kB (cached+buffers+slab).
reclaimable_from_meminfo() {
  printf '%s\n' "${1}" | awk '/^Cached:/{c=$2} /Buffers:/{b=$2} /SReclaimable:/{s=$2} END{printf "%d", (c+0)+(b+0)+(s+0)}'
}

# top_process_from_ps TEXT -> "<comm> <rss_kb>" for the largest RSS line.
top_process_from_ps() {
  printf '%s\n' "${1}" | awk 'BEGIN{max=-1} NF>=2{r=$1+0; name=$2; for(i=3;i<=NF;i++) name=name" "$i; if(r>max){max=r; n=name}} END{if(max>=0) printf "%s %d", n, max}'
}

# _read_ps_mem -> ps RSS and command name, one line per process. Seam for tests.
_read_ps_mem() { ps axo rss=,comm= 2>/dev/null; }

# read_absolute -> "<used_kb> <total_kb>" for the host.
read_absolute() {
  if is_linux; then
    absolute_from_meminfo "$(_read_meminfo)"
  elif is_macos && has_command vm_stat; then
    absolute_from_vmstat "$(_read_vmstat)" "$(_read_pagesize)"
  fi
}

# read_commit -> commit ratio percent, empty off Linux.
read_commit() {
  if is_linux; then
    commit_from_meminfo "$(_read_meminfo)"
  fi
}

# read_reclaimable -> reclaimable cache in kB, empty off Linux.
read_reclaimable() {
  if is_linux; then
    reclaimable_from_meminfo "$(_read_meminfo)"
  fi
}

# read_top_process -> "<comm> <rss_kb>" of the largest memory consumer.
read_top_process() {
  top_process_from_ps "$(_read_ps_mem)"
}

export -f absolute_from_meminfo
export -f absolute_from_vmstat
export -f commit_from_meminfo
export -f reclaimable_from_meminfo
export -f top_process_from_ps
export -f _read_ps_mem
export -f read_absolute
export -f read_commit
export -f read_reclaimable
export -f read_top_process
