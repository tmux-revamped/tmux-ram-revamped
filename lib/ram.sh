#!/bin/sh

[ -n "${RAM_REVAMPED_RAM_LOADED:-}" ] && return 0
RAM_REVAMPED_RAM_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"
# shellcheck source=SCRIPTDIR/platform.sh
. "${REVAMPED_LIB}/platform.sh"
# shellcheck source=SCRIPTDIR/command.sh
. "${REVAMPED_LIB}/command.sh"
# shellcheck source=SCRIPTDIR/cache.sh
. "${REVAMPED_LIB}/cache.sh"
# shellcheck source=SCRIPTDIR/publish.sh
. "${REVAMPED_LIB}/publish.sh"
# shellcheck source=SCRIPTDIR/ticker.sh
. "${REVAMPED_LIB}/ticker.sh"

ram_revamped_format() {
  printf '%s\n' "${RAM_REVAMPED_SETTINGS}" | awk -F '\t' -v live="${RAM_REVAMPED_LIVE}" '{ printf "%s#{@ram_revamped_%s}", (NR > 1 ? "\t" : ""), $1 } END { count = split(live, name, " "); for (i = 1; i <= count; i++) { printf "\t#{@ram_revamped_%s}", name[i] } }'
}

ram_revamped_resolve() {
  env | RAM_REVAMPED_ROWS="${RAM_REVAMPED_SETTINGS}" RAM_REVAMPED_VALUES="$1" awk -v live="${RAM_REVAMPED_LIVE}" '
    BEGIN {
      count = split(ENVIRON["RAM_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["RAM_REVAMPED_VALUES"], given, "\t")
      for (i = 1; i <= count; i++) {
        at = index(rows[i], "\t")
        if (at == 0) { at = length(rows[i]) + 1 }
        name[i] = substr(rows[i], 1, at - 1)
        value[i] = (given[i] != "") ? given[i] : substr(rows[i], at + 1)
        want["RAM_REVAMPED_" toupper(name[i])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) {
        value[want[key]] = substr($0, at + 1)
      }
    }
    END {
      for (i = 1; i <= count; i++) { print name[i] "\t" value[i] }
      extra = split(live, state, " ")
      for (i = 1; i <= extra; i++) { print state[i] "\t" given[count + i] }
    }
  '
}

ram_revamped_setting_rows() {
  ram_revamped_setting_rows_format=$(ram_revamped_format)
  ram_revamped_setting_rows_live=$(tmux display-message -p "${ram_revamped_setting_rows_format}" 2>/dev/null) || ram_revamped_setting_rows_live=""
  ram_revamped_resolve "${ram_revamped_setting_rows_live}"
}

ram_revamped_load() {
  ram_revamped_load_values=$(ram_revamped_setting_rows)
  while IFS='	' read -r ram_revamped_load_name ram_revamped_load_value; do
    IFS= read -r "RAM_REVAMPED_S_${ram_revamped_load_name}" <<EOF
${ram_revamped_load_value}
EOF
  done <<EOF
${ram_revamped_load_values}
EOF
}

ram_revamped_parse_version() {
  printf '%s\n' "$1" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

ram_revamped_version_ge() {
  case "$1:$2" in
  *[!0-9.:]* | :* | *:) return 1 ;;
  *) ;;
  esac
  ram_revamped_version_ge_have="${1%%.*}"
  ram_revamped_version_ge_want="${2%%.*}"
  [ "${ram_revamped_version_ge_have}" -gt "${ram_revamped_version_ge_want}" ] && return 0
  [ "${ram_revamped_version_ge_have}" -eq "${ram_revamped_version_ge_want}" ] || return 1
  ram_revamped_version_ge_have="${1#*.}"
  ram_revamped_version_ge_want="${2#*.}"
  [ "${ram_revamped_version_ge_have%%.*}" -ge "${ram_revamped_version_ge_want%%.*}" ]
}

ram_revamped_emit() {
  for ram_revamped_emit_arg in "$@"; do
    case "${ram_revamped_emit_arg}" in
    *\;) ram_revamped_emit_arg="${ram_revamped_emit_arg%;}\\;" ;;
    *) ;;
    esac
    RAM_REVAMPED_PLAN="${RAM_REVAMPED_PLAN}${ram_revamped_emit_arg:-${RAM_REVAMPED_EMPTY}}
"
  done
  RAM_REVAMPED_PLAN="${RAM_REVAMPED_PLAN}
"
}

ram_revamped_literal() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e "s/#/'\"\$(printf '%b' '\\\\0043')\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

ram_revamped_send() {
  set --
  ram_revamped_send_sep=""
  while IFS= read -r ram_revamped_send_line; do
    if [ -z "${ram_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || ram_revamped_send_sep=";"
      continue
    fi
    [ -z "${ram_revamped_send_sep}" ] || set -- "$@" "${ram_revamped_send_sep}"
    ram_revamped_send_sep=""
    [ "${ram_revamped_send_line}" != "${RAM_REVAMPED_EMPTY}" ] || ram_revamped_send_line=""
    set -- "$@" "${ram_revamped_send_line}"
  done <<PLAN
${RAM_REVAMPED_PLAN}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@" 2>/dev/null
}

ram_revamped_send_each() {
  ram_revamped_send_each_status=0
  set --
  while IFS= read -r ram_revamped_send_each_line; do
    if [ -n "${ram_revamped_send_each_line}" ]; then
      [ "${ram_revamped_send_each_line}" != "${RAM_REVAMPED_EMPTY}" ] || ram_revamped_send_each_line=""
      set -- "$@" "${ram_revamped_send_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || ram_revamped_send_each_status=1
    set --
  done <<PLAN
${RAM_REVAMPED_PLAN}
PLAN
  return "${ram_revamped_send_each_status}"
}

ram_revamped_deliver() {
  ! ram_revamped_send || return 0
  ram_revamped_send_each
}

ram_revamped_lines() {
  printf '%s' "${RAM_REVAMPED_PLAN}" | awk -v empty="${RAM_REVAMPED_EMPTY}" '$0 == empty { $0 = "\"\"" } $0 == "" && line != "" { print line; line = ""; next } $0 == "" { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

ram_revamped_json() {
  printf '%s' "${RAM_REVAMPED_PLAN}" | awk -v empty="${RAM_REVAMPED_EMPTY}" '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    $0 == empty { $0 = "" }
    { args = args (args == "" ? "" : ",") quote($0) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

ram_revamped_bindings() {
  printf '%s' "${RAM_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

ram_revamped_setting_name() {
  ram_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${RAM_REVAMPED_NAMES} " in
  *" ${ram_revamped_setting_name_raw} "*) printf '%s\n' "${ram_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}

ram_revamped_bind() {
  case "$1" in
  "" | off) return 0 ;;
  *) ;;
  esac
  ram_revamped_bind_key="$1" ram_revamped_bind_note="$2"
  shift 2
  set -- "${ram_revamped_bind_key}" "$@"
  [ "${RAM_REVAMPED_NOTES}" != 1 ] || set -- -N "${ram_revamped_bind_note}" "$@"
  ram_revamped_emit bind-key "$@"
}

ram_revamped_job_quote() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g' -e 's/%/%%/g' -e "1s/^/'/" -e "\$s/\$/'/"
}

ram_revamped_carried() {
  ram_revamped_carried_set=$(env | sed -n 's/^RAM_REVAMPED_\([A-Z_]*\)=\(.*\)$/\1 \2/p')
  [ -n "${ram_revamped_carried_set}" ] || return 0
  printf '%s\n' "${ram_revamped_carried_set}" | RAM_REVAMPED_WANTED="${RAM_REVAMPED_CARRIED}" awk '
    BEGIN { count = split(ENVIRON["RAM_REVAMPED_WANTED"], name, " "); for (i = 1; i <= count; i++) { wanted[toupper(name[i])] = i } }
    {
      key = $1
      if (!(key in wanted)) { next }
      given[wanted[key]] = 1
      value[wanted[key]] = substr($0, length(key) + 2)
    }
    END {
      for (i = 1; i <= count; i++) {
        if (!given[i]) { continue }
        flag = name[i]
        gsub(/_/, "-", flag)
        print flag "\t" value[i]
      }
    }
  '
}

ram_revamped_tools() {
  ram_revamped_tools_path="${REVAMPED_LIB%/lib}/bin/ram-revamped"
  RAM_REVAMPED_TOOL=$(ram_revamped_literal "${ram_revamped_tools_path}")
  RAM_REVAMPED_JOB=$(ram_revamped_job_quote "${ram_revamped_tools_path}")
  ram_revamped_tools_rows=$(ram_revamped_carried)
  while IFS='	' read -r ram_revamped_tools_flag ram_revamped_tools_value; do
    [ -n "${ram_revamped_tools_flag}" ] || continue
    RAM_REVAMPED_TOOL="${RAM_REVAMPED_TOOL} --${ram_revamped_tools_flag} $(ram_revamped_literal "${ram_revamped_tools_value}")"
    RAM_REVAMPED_JOB="${RAM_REVAMPED_JOB} --${ram_revamped_tools_flag} $(ram_revamped_job_quote "${ram_revamped_tools_value}")"
  done <<EOF
${ram_revamped_tools_rows}
EOF
}

ram_revamped_held() {
  tmux list-keys -T prefix 2>/dev/null | awk '
    {
      at = 2
      if ($at == "-r") { at++ }
      if ($at == "-T") { at += 2 }
      key = $at
      if (key ~ /^\\./) { key = substr(key, 2) }
      rest = ""
      for (i = at + 1; i <= NF; i++) { rest = rest " " $i }
      if (index(rest, "ram-revamped") == 0) { printf "%s ", key }
    }
  '
}

ram_revamped_doubled() {
  ram_revamped_doubled_rest="$1" ram_revamped_doubled_hash='#' RAM_REVAMPED_DOUBLED=""
  while [ "${ram_revamped_doubled_rest}" != "${ram_revamped_doubled_rest#*"${ram_revamped_doubled_hash}"}" ]; do
    RAM_REVAMPED_DOUBLED="${RAM_REVAMPED_DOUBLED}${ram_revamped_doubled_rest%%"${ram_revamped_doubled_hash}"*}${ram_revamped_doubled_hash}${ram_revamped_doubled_hash}"
    ram_revamped_doubled_rest="${ram_revamped_doubled_rest#*"${ram_revamped_doubled_hash}"}"
  done
  RAM_REVAMPED_DOUBLED="${RAM_REVAMPED_DOUBLED}${ram_revamped_doubled_rest}"
}

ram_revamped_now() {
  RAM_REVAMPED_NOW=$(date +%s 2>/dev/null) || RAM_REVAMPED_NOW=0
}

ram_revamped_version() {
  ram_revamped_version_raw=$(tmux -V 2>/dev/null) || ram_revamped_version_raw=""
  RAM_REVAMPED_TMUX=$(ram_revamped_parse_version "${ram_revamped_version_raw}")
}

ram_revamped_number() {
  RAM_REVAMPED_NUMBER="$1"
  revamped_cache_is_number "$1" || RAM_REVAMPED_NUMBER="$2"
}

ram_revamped_store() {
  ram_revamped_emit set-option -gq "@ram_revamped_$1" "$2"
  IFS= read -r "RAM_REVAMPED_S_$1" <<EOF
$2
EOF
}

ram_revamped_log() {
  # shellcheck source=SCRIPTDIR/log.sh
  . "${REVAMPED_LIB}/log.sh"
  revamped_log_error ram "$1"
}

ram_revamped_page() {
  RAM_REVAMPED_PAGE="${RAM_REVAMPED_DEFAULT_PAGE}"
  case "$1" in
  *"page size of "*) return 0 ;;
  *) ;;
  esac
  ram_revamped_page_read=$(sysctl -n hw.pagesize 2>/dev/null) || ram_revamped_page_read=""
  ! revamped_cache_is_number "${ram_revamped_page_read}" || RAM_REVAMPED_PAGE="${ram_revamped_page_read}"
}

ram_revamped_raw_macos() {
  RAM_REVAMPED_RAW=$(vm_stat 2>/dev/null) || RAM_REVAMPED_RAW=""
  [ -n "${RAM_REVAMPED_RAW}" ] || return 0
  ram_revamped_page "${RAM_REVAMPED_RAW}"
  ram_revamped_raw_macos_swap=$(sysctl vm.swapusage 2>/dev/null) || ram_revamped_raw_macos_swap=""
  RAM_REVAMPED_RAW="${RAM_REVAMPED_RAW}
${ram_revamped_raw_macos_swap}"
}

ram_revamped_raw_linux() {
  RAM_REVAMPED_RAW=$(cat /proc/meminfo 2>/dev/null) || RAM_REVAMPED_RAW=""
}

ram_revamped_raw_stall() {
  ram_revamped_raw_stall_text=$(cat /proc/pressure/memory 2>/dev/null) || ram_revamped_raw_stall_text=""
  RAM_REVAMPED_RAW="${RAM_REVAMPED_RAW}
${ram_revamped_raw_stall_text}"
}

ram_revamped_raw_processes() {
  ram_revamped_raw_processes_rows=$(ps axo rss=,comm= 2>/dev/null) || ram_revamped_raw_processes_rows=""
  RAM_REVAMPED_RAW="${RAM_REVAMPED_RAW}
${RAM_REVAMPED_MARK}
${ram_revamped_raw_processes_rows}"
}

ram_revamped_figures() {
  LC_ALL=C awk -v page="${RAM_REVAMPED_PAGE}" -v history="${RAM_REVAMPED_S_history}" -v keep="$1" -v mark="${RAM_REVAMPED_MARK}" '
    function human(k,    v, u) {
      if (k >= 1048576) { v = k / 1048576; u = "G" } else if (k >= 1024) { v = k / 1024; u = "M" } else { v = k; u = "K" }
      return (v == int(v)) ? sprintf("%d%s", v, u) : sprintf("%.1f%s", v, u)
    }
    function gigabytes(megabytes) { return sprintf("%.1f", int(megabytes) / 1024) }
    function pages(text) { gsub(/\./, "", text); return text + 0 }
    function whole(text) { gsub(/[^0-9.]/, "", text); return int(text + 0) }
    function resident(text,    size) {
      size = text + 0
      if (text ~ /[mM]$/) { size = size * 1024 }
      if (text ~ /[gG]$/) { size = size * 1048576 }
      return size
    }
    $0 == mark { listing = 1; next }
    listing {
      if (NF < 2) { next }
      size = resident($1)
      if (size > most || holder == "") {
        most = size
        holder = $2
        for (i = 3; i <= NF; i++) { holder = holder " " $i }
      }
      next
    }
    /page size of [0-9]+ bytes/ { for (i = 1; i < NF; i++) { if ($i == "of" && $(i + 1) ~ /^[0-9]+$/) { page = $(i + 1) } } }
    index($0, "Pages free:") == 1 { vf = pages($NF) }
    index($0, "Pages active:") == 1 { va = pages($NF) }
    index($0, "Pages inactive:") == 1 { vi = pages($NF) }
    index($0, "Pages speculative:") == 1 { vs = pages($NF) }
    index($0, "Pages wired down:") == 1 { vw = pages($NF) }
    index($0, "Pages occupied by compressor:") == 1 { vc = pages($NF) }
    index($0, "Pages purgeable:") == 1 { vp = pages($NF); cached = 1 }
    index($0, "File-backed pages:") == 1 { vb = pages($NF); cached = 1 }
    $1 == "vm.swapusage:" { for (i = 2; i <= NF; i++) { if ($i == "total") { st = whole($(i + 2)) } if ($i == "used") { su = whole($(i + 2)) } } }
    $1 == "MemTotal:" { mt = $2 }
    $1 == "MemAvailable:" { ma = $2 }
    $1 == "MemFree:" { mf = $2 }
    $1 == "Buffers:" { mb = $2 }
    $1 == "Cached:" { mc = $2 }
    $1 == "SReclaimable:" { ms = $2 }
    $1 == "SwapTotal:" { wt = $2 }
    $1 == "SwapFree:" { wf = $2 }
    $1 == "CommitLimit:" { cl = $2 }
    $1 == "Committed_AS:" { ca = $2 }
    $1 == "some" { for (i = 2; i <= NF; i++) { if ($i ~ /^avg10=/) { stall = substr($i, 7); stalled = 1 } } }
    END {
      total = vf + va + vi + vs + vw + vc
      if (total > 0) {
        percent = sprintf("%.0f", (va + vw + vc) / total * 100)
        available = sprintf("%.0f", (vf + vi + vs) / total * 100)
        pressure = sprintf("%.0f", (vw + vc) / total * 100)
        breakdown = gigabytes(vw * page / 1048576) " " gigabytes(vc * page / 1048576) " " gigabytes(vi * page / 1048576) " " gigabytes(vf * page / 1048576)
        absolute = human(int((va + vw + vc) * page / 1024)) " " human(int(total * page / 1024))
        if (cached) { reclaimable = human(int((vp + vb) * page / 1024)) }
        if (st > 0) { swap = sprintf("%.0f", su / st * 100) }
      } else if (mt ~ /^[0-9]+$/ && ma ~ /^[0-9]+$/ && mt + 0 > 0) {
        used = mt - ma
        if (used < 0) { used = 0 }
        percent = sprintf("%.0f", used / mt * 100)
        available = sprintf("%.0f", ma / mt * 100)
        breakdown = gigabytes(mb / 1024) " " gigabytes(0) " " gigabytes(mc / 1024) " " gigabytes(mf / 1024)
        absolute = human(used) " " human(mt + 0)
        reclaimable = human(mc + mb + ms)
        if (wt + 0 > 0) { swap = sprintf("%.0f", (wt - wf) / wt * 100) }
        if (cl + 0 > 0) { commit = sprintf("%.0f", ca / cl * 100) }
        if (stalled) { pressure = sprintf("%.0f", stall) }
      }
      if (percent != "") {
        count = split(history, past, " ")
        past[++count] = percent
        history = ""
        for (i = (count > keep ? count - keep + 1 : 1); i <= count; i++) { history = history (history == "" ? "" : " ") past[i] }
      }
      if (holder != "") { top = human(most) " " holder }
      printf "percent\t%s\navailable\t%s\nswap\t%s\npressure\t%s\nbreakdown\t%s\nabsolute\t%s\ncommit\t%s\nreclaimable\t%s\nhistory\t%s\ntop_process\t%s\n", percent, available, swap, pressure, breakdown, absolute, commit, reclaimable, history, top
    }
  '
}

ram_revamped_measure() {
  RAM_REVAMPED_F_percent="" RAM_REVAMPED_F_available="" RAM_REVAMPED_F_swap="" RAM_REVAMPED_F_pressure="" RAM_REVAMPED_F_breakdown=""
  RAM_REVAMPED_F_absolute="" RAM_REVAMPED_F_commit="" RAM_REVAMPED_F_reclaimable="" RAM_REVAMPED_F_history="" RAM_REVAMPED_F_top_process=""
  ram_revamped_number "${RAM_REVAMPED_S_history_size}" "${RAM_REVAMPED_DEFAULT_HISTORY}"
  [ "${RAM_REVAMPED_NUMBER}" -gt 0 ] || RAM_REVAMPED_NUMBER="${RAM_REVAMPED_DEFAULT_HISTORY}"
  ram_revamped_measure_rows=$(printf '%s\n' "${RAM_REVAMPED_RAW}" | ram_revamped_figures "${RAM_REVAMPED_NUMBER}") || ram_revamped_measure_rows=""
  while IFS='	' read -r ram_revamped_measure_name ram_revamped_measure_value; do
    [ -n "${ram_revamped_measure_name}" ] || continue
    IFS= read -r "RAM_REVAMPED_F_${ram_revamped_measure_name}" <<EOF
${ram_revamped_measure_value}
EOF
  done <<EOF
${ram_revamped_measure_rows}
EOF
}

ram_revamped_wanted() {
  for ram_revamped_wanted_name in "$@"; do
    case " ${RAM_REVAMPED_WANT} " in
    *" ${ram_revamped_wanted_name} "*) return 0 ;;
    *) ;;
    esac
  done
  return 1
}

ram_revamped_due() {
  ram_revamped_due_ts="$1"
  shift
  ram_revamped_wanted "$@" || return 1
  revamped_cache_is_number "${ram_revamped_due_ts}" || return 0
  [ "$((RAM_REVAMPED_NOW - ram_revamped_due_ts))" -gt "${RAM_REVAMPED_DETAIL}" ]
}

ram_revamped_sample() {
  if revamped_is_macos; then
    ram_revamped_raw_macos
  else
    ram_revamped_raw_linux
  fi
  ram_revamped_number "${RAM_REVAMPED_S_detail_interval}" "${RAM_REVAMPED_DEFAULT_DETAIL}"
  RAM_REVAMPED_DETAIL="${RAM_REVAMPED_NUMBER}"
  ram_revamped_sample_pressure=0 ram_revamped_sample_top=0
  if ram_revamped_due "${RAM_REVAMPED_S_pressure_ts}" pressure pressure_fg_color; then
    ram_revamped_sample_pressure=1
    revamped_is_macos || ram_revamped_raw_stall
  fi
  if ram_revamped_due "${RAM_REVAMPED_S_top_process_ts}" top_process; then
    ram_revamped_sample_top=1
    ram_revamped_raw_processes
  fi
  ram_revamped_measure
  ram_revamped_store percent "${RAM_REVAMPED_F_percent}"
  ram_revamped_store available "${RAM_REVAMPED_F_available}"
  ram_revamped_store swap "${RAM_REVAMPED_F_swap}"
  ram_revamped_store breakdown "${RAM_REVAMPED_F_breakdown}"
  ram_revamped_store absolute "${RAM_REVAMPED_F_absolute}"
  ram_revamped_store commit "${RAM_REVAMPED_F_commit}"
  ram_revamped_store reclaimable "${RAM_REVAMPED_F_reclaimable}"
  ram_revamped_store history "${RAM_REVAMPED_F_history}"
  ram_revamped_store percent_ts "${RAM_REVAMPED_NOW}"
  if [ "${ram_revamped_sample_pressure}" = 1 ]; then
    ram_revamped_store pressure "${RAM_REVAMPED_F_pressure}"
    ram_revamped_store pressure_ts "${RAM_REVAMPED_NOW}"
  fi
  if [ "${ram_revamped_sample_top}" = 1 ]; then
    ram_revamped_store top_process "${RAM_REVAMPED_F_top_process}"
    ram_revamped_store top_process_ts "${RAM_REVAMPED_NOW}"
  fi
}

ram_revamped_refresh() {
  RAM_REVAMPED_PLAN=""
  ram_revamped_now
  ram_revamped_sample
  RAM_REVAMPED_STORED=1
  ram_revamped_send || RAM_REVAMPED_STORED=0
  [ -n "${RAM_REVAMPED_F_percent}" ] || ram_revamped_log "no memory figures were read"
}

ram_revamped_limit() {
  ram_revamped_number "${RAM_REVAMPED_S_interval}" "${RAM_REVAMPED_DEFAULT_INTERVAL}"
  RAM_REVAMPED_LIMIT="${RAM_REVAMPED_NUMBER}"
}

ram_revamped_stale() {
  revamped_cache_is_number "${RAM_REVAMPED_S_percent_ts}" || return 0
  [ "$((RAM_REVAMPED_NOW - RAM_REVAMPED_S_percent_ts))" -gt "${RAM_REVAMPED_LIMIT}" ]
}

ram_revamped_locked() {
  [ "${RAM_REVAMPED_S_percent_lock}" = 1 ] || return 1
  revamped_cache_is_number "${RAM_REVAMPED_S_percent_lock_ts}" || return 1
  [ "$((RAM_REVAMPED_NOW - RAM_REVAMPED_S_percent_lock_ts))" -lt "${REVAMPED_CACHE_MAX_RUN_DEFAULT}" ]
}

ram_revamped_tier() {
  ram_revamped_number "${RAM_REVAMPED_S_medium_thresh}" "${RAM_REVAMPED_DEFAULT_MEDIUM}"
  ram_revamped_tier_medium="${RAM_REVAMPED_NUMBER}"
  ram_revamped_number "${RAM_REVAMPED_S_high_thresh}" "${RAM_REVAMPED_DEFAULT_HIGH}"
  if [ "$1" -ge "${RAM_REVAMPED_NUMBER}" ]; then
    RAM_REVAMPED_TIER=high
  elif [ "$1" -ge "${ram_revamped_tier_medium}" ]; then
    RAM_REVAMPED_TIER=medium
  else
    RAM_REVAMPED_TIER=low
  fi
}

ram_revamped_value_tiered() {
  RAM_REVAMPED_OUT=""
  revamped_cache_is_number "$2" || return 0
  ram_revamped_tier "$2"
  case "$1:${RAM_REVAMPED_TIER}" in
  icon:high) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_high_icon}" ;;
  icon:medium) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_medium_icon}" ;;
  icon:low) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_low_icon}" ;;
  fg_color:high) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_high_fg_color}" ;;
  fg_color:medium) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_medium_fg_color}" ;;
  fg_color:low) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_low_fg_color}" ;;
  bg_color:high) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_high_bg_color}" ;;
  bg_color:medium) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_medium_bg_color}" ;;
  *) RAM_REVAMPED_OUT="${RAM_REVAMPED_S_low_bg_color}" ;;
  esac
}

ram_revamped_value_shaped() {
  RAM_REVAMPED_OUT=""
  [ -n "$2" ] || return 0
  # shellcheck disable=SC2059
  RAM_REVAMPED_OUT=$(printf "$1" "$2")
}

ram_revamped_value_swapping() {
  RAM_REVAMPED_OUT=""
  revamped_cache_is_number "${RAM_REVAMPED_S_swap}" || return 0
  ram_revamped_number "${RAM_REVAMPED_S_swap_warn_thresh}" "${RAM_REVAMPED_DEFAULT_SWAP_WARN}"
  [ "${RAM_REVAMPED_S_swap}" -ge "${RAM_REVAMPED_NUMBER}" ] || return 0
  RAM_REVAMPED_OUT="$1"
}

ram_revamped_value_breakdown() {
  RAM_REVAMPED_OUT=""
  [ -n "${RAM_REVAMPED_S_breakdown}" ] || return 0
  IFS=' ' read -r ram_revamped_value_breakdown_wired ram_revamped_value_breakdown_packed ram_revamped_value_breakdown_idle ram_revamped_value_breakdown_free <<EOF
${RAM_REVAMPED_S_breakdown}
EOF
  # shellcheck disable=SC2059
  RAM_REVAMPED_OUT=$(printf "${RAM_REVAMPED_S_breakdown_format}" "${ram_revamped_value_breakdown_wired}" "${ram_revamped_value_breakdown_packed}" "${ram_revamped_value_breakdown_idle}" "${ram_revamped_value_breakdown_free}")
}

ram_revamped_value_absolute() {
  RAM_REVAMPED_OUT=""
  [ -n "${RAM_REVAMPED_S_absolute}" ] || return 0
  # shellcheck disable=SC2059
  RAM_REVAMPED_OUT=$(printf "${RAM_REVAMPED_S_absolute_format}" "${RAM_REVAMPED_S_absolute%% *}" "${RAM_REVAMPED_S_absolute#* }")
}

ram_revamped_value_top() {
  RAM_REVAMPED_OUT=""
  [ -n "${RAM_REVAMPED_S_top_process}" ] || return 0
  ram_revamped_doubled "${RAM_REVAMPED_S_top_process#* }"
  # shellcheck disable=SC2059
  RAM_REVAMPED_OUT=$(printf "${RAM_REVAMPED_S_top_process_format}" "${RAM_REVAMPED_DOUBLED}" "${RAM_REVAMPED_S_top_process%% *}")
}

ram_revamped_value_graph() {
  RAM_REVAMPED_OUT=""
  ram_revamped_value_graph_rest="${RAM_REVAMPED_S_history}" ram_revamped_value_graph_bytes=""
  while [ -n "${ram_revamped_value_graph_rest}" ]; do
    ram_revamped_value_graph_item="${ram_revamped_value_graph_rest%% *}"
    ram_revamped_value_graph_rest="${ram_revamped_value_graph_rest#"${ram_revamped_value_graph_item}"}"
    ram_revamped_value_graph_rest="${ram_revamped_value_graph_rest# }"
    revamped_cache_is_number "${ram_revamped_value_graph_item}" || continue
    ram_revamped_value_graph_step=$((ram_revamped_value_graph_item * RAM_REVAMPED_GRAPH_STEPS / 100))
    [ "${ram_revamped_value_graph_step}" -lt "${RAM_REVAMPED_GRAPH_STEPS}" ] || ram_revamped_value_graph_step=$((RAM_REVAMPED_GRAPH_STEPS - 1))
    set -- 201 202 203 204 205 206 207 210
    shift "${ram_revamped_value_graph_step}"
    ram_revamped_value_graph_bytes="${ram_revamped_value_graph_bytes}\\0342\\0226\\0$1"
  done
  [ -n "${ram_revamped_value_graph_bytes}" ] || return 0
  RAM_REVAMPED_OUT=$(printf '%b' "${ram_revamped_value_graph_bytes}")
}

ram_revamped_value_trend() {
  RAM_REVAMPED_OUT=""
  ram_revamped_value_trend_rest="${RAM_REVAMPED_S_history}" ram_revamped_value_trend_first="" ram_revamped_value_trend_last=""
  while [ -n "${ram_revamped_value_trend_rest}" ]; do
    ram_revamped_value_trend_item="${ram_revamped_value_trend_rest%% *}"
    ram_revamped_value_trend_rest="${ram_revamped_value_trend_rest#"${ram_revamped_value_trend_item}"}"
    ram_revamped_value_trend_rest="${ram_revamped_value_trend_rest# }"
    revamped_cache_is_number "${ram_revamped_value_trend_item}" || continue
    [ -n "${ram_revamped_value_trend_first}" ] || ram_revamped_value_trend_first="${ram_revamped_value_trend_item}"
    ram_revamped_value_trend_last="${ram_revamped_value_trend_item}"
  done
  [ -n "${ram_revamped_value_trend_first}" ] || return 0
  ram_revamped_number "${RAM_REVAMPED_S_trend_threshold}" "${RAM_REVAMPED_DEFAULT_TREND}"
  ram_revamped_value_trend_change=$((ram_revamped_value_trend_last - ram_revamped_value_trend_first))
  if [ "${ram_revamped_value_trend_change}" -ge "${RAM_REVAMPED_NUMBER}" ]; then
    RAM_REVAMPED_OUT="${RAM_REVAMPED_S_trend_up}"
  elif [ "${ram_revamped_value_trend_change}" -le "$((0 - RAM_REVAMPED_NUMBER))" ]; then
    RAM_REVAMPED_OUT="${RAM_REVAMPED_S_trend_down}"
  else
    RAM_REVAMPED_OUT="${RAM_REVAMPED_S_trend_flat}"
  fi
}

ram_revamped_value_text() {
  RAM_REVAMPED_OUT=""
  [ -n "${RAM_REVAMPED_S_percent}" ] || return 0
  RAM_REVAMPED_OUT="RAM ${RAM_REVAMPED_S_percent}% used"
  [ -z "${RAM_REVAMPED_S_available}" ] || RAM_REVAMPED_OUT="${RAM_REVAMPED_OUT}, ${RAM_REVAMPED_S_available}% available"
  [ -z "${RAM_REVAMPED_S_swap}" ] || RAM_REVAMPED_OUT="${RAM_REVAMPED_OUT}, swap ${RAM_REVAMPED_S_swap}%"
}

ram_revamped_value() {
  case "$1" in
  percentage) ram_revamped_value_shaped "${RAM_REVAMPED_S_percentage_format}" "${RAM_REVAMPED_S_percent}" ;;
  icon | fg_color | bg_color) ram_revamped_value_tiered "$1" "${RAM_REVAMPED_S_percent}" ;;
  available) ram_revamped_value_shaped "${RAM_REVAMPED_S_available_format}" "${RAM_REVAMPED_S_available}" ;;
  swap) ram_revamped_value_shaped "${RAM_REVAMPED_S_swap_format}" "${RAM_REVAMPED_S_swap}" ;;
  swap_icon) ram_revamped_value_swapping "${RAM_REVAMPED_S_swap_active_icon}" ;;
  swap_color) ram_revamped_value_swapping "${RAM_REVAMPED_S_swap_active_color}" ;;
  pressure) ram_revamped_value_shaped "${RAM_REVAMPED_S_pressure_format}" "${RAM_REVAMPED_S_pressure}" ;;
  pressure_fg_color) ram_revamped_value_tiered fg_color "${RAM_REVAMPED_S_pressure}" ;;
  breakdown) ram_revamped_value_breakdown ;;
  absolute) ram_revamped_value_absolute ;;
  commit) ram_revamped_value_shaped "${RAM_REVAMPED_S_commit_format}" "${RAM_REVAMPED_S_commit}" ;;
  reclaimable) ram_revamped_value_shaped "${RAM_REVAMPED_S_reclaimable_format}" "${RAM_REVAMPED_S_reclaimable}" ;;
  top_process) ram_revamped_value_top ;;
  graph) ram_revamped_value_graph ;;
  trend) ram_revamped_value_trend ;;
  *) ram_revamped_value_text ;;
  esac
}

ram_revamped_own() {
  RAM_REVAMPED_NATURAL=0
  case "$1" in
  percentage) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_percentage_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_percentage_width}" RAM_REVAMPED_GLYPH='\0363\0260\0212\0232' RAM_REVAMPED_NATURAL="${RAM_REVAMPED_PERCENT_NATURAL}" ;;
  available) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_available_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_available_width}" RAM_REVAMPED_GLYPH='\0363\0260\0215\0233' RAM_REVAMPED_NATURAL="${RAM_REVAMPED_PERCENT_NATURAL}" ;;
  swap) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_swap_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_swap_width}" RAM_REVAMPED_GLYPH='\0363\0260\0276\0264' RAM_REVAMPED_NATURAL="${RAM_REVAMPED_PERCENT_NATURAL}" ;;
  pressure) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_pressure_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_pressure_width}" RAM_REVAMPED_GLYPH='\0363\0260\0276\0206' ;;
  breakdown) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_breakdown_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_breakdown_width}" RAM_REVAMPED_GLYPH='\0363\0260\0236\0257' ;;
  absolute) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_absolute_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_absolute_width}" RAM_REVAMPED_GLYPH='\0363\0260\0206\0274' ;;
  commit) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_commit_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_commit_width}" RAM_REVAMPED_GLYPH='\0363\0260\0222\0240' ;;
  reclaimable) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_reclaimable_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_reclaimable_width}" RAM_REVAMPED_GLYPH='\0363\0260\0221\0214' ;;
  top_process) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_top_process_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_top_process_width}" RAM_REVAMPED_GLYPH='\0363\0260\0243\0206' ;;
  graph) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_graph_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_graph_width}" RAM_REVAMPED_GLYPH='\0363\0260\0236\0261' ;;
  *) RAM_REVAMPED_LABEL="${RAM_REVAMPED_S_trend_label}" RAM_REVAMPED_WIDTH="${RAM_REVAMPED_S_trend_width}" RAM_REVAMPED_GLYPH='\0363\0260\0224\0265' ;;
  esac
}

ram_revamped_pad() {
  if ! revamped_cache_is_number "${RAM_REVAMPED_WIDTH}"; then
    RAM_REVAMPED_WIDTH=0
    [ "${RAM_REVAMPED_S_fixed_width}" != on ] || RAM_REVAMPED_WIDTH="${RAM_REVAMPED_NATURAL}"
  fi
  [ "${RAM_REVAMPED_WIDTH}" -gt 0 ] || return 0
  revamped_publish_count "${RAM_REVAMPED_OUT}"
  [ "${revamped_publish_count_out}" -lt "${RAM_REVAMPED_WIDTH}" ] || return 0
  ram_revamped_pad_gap=$(printf "%$((RAM_REVAMPED_WIDTH - revamped_publish_count_out))s" '')
  RAM_REVAMPED_OUT="${ram_revamped_pad_gap}${RAM_REVAMPED_OUT}"
}

ram_revamped_label() {
  [ -z "${RAM_REVAMPED_LABEL}" ] || return 0
  [ "${RAM_REVAMPED_S_icons}" = nerd ] || return 0
  RAM_REVAMPED_LABEL=$(printf '%b' "${RAM_REVAMPED_GLYPH}")
}

ram_revamped_output() {
  ram_revamped_value "$1"
  [ -n "${RAM_REVAMPED_OUT}" ] || return 0
  case " ${RAM_REVAMPED_LABELLED} " in
  *" $1 "*) ram_revamped_own "$1" ;;
  *) return 0 ;;
  esac
  ram_revamped_pad
  ram_revamped_label
  [ -z "${RAM_REVAMPED_LABEL}" ] || RAM_REVAMPED_OUT="${RAM_REVAMPED_LABEL} ${RAM_REVAMPED_OUT}"
}

ram_revamped_show() {
  ram_revamped_output "$1"
  [ -z "${RAM_REVAMPED_OUT}" ] || printf '%s\n' "${RAM_REVAMPED_OUT}"
}

ram_revamped_status() {
  ram_revamped_load
  ram_revamped_now
  ram_revamped_limit
  RAM_REVAMPED_WANT="${RAM_REVAMPED_S_published} $1"
  if ram_revamped_stale && ! ram_revamped_locked; then
    revamped_cache_refresh_if_stale percent "${RAM_REVAMPED_LIMIT}" ram_revamped_refresh || :
  fi
  ram_revamped_show "$1"
}

ram_revamped_publish() {
  RAM_REVAMPED_WANT="${RAM_REVAMPED_S_published}"
  ram_revamped_refresh
  [ "${RAM_REVAMPED_STORED}" = 1 ] || return 0
  ram_revamped_publish_rest="${RAM_REVAMPED_S_published}"
  while [ -n "${ram_revamped_publish_rest}" ]; do
    ram_revamped_publish_metric="${ram_revamped_publish_rest%% *}"
    ram_revamped_publish_rest="${ram_revamped_publish_rest#"${ram_revamped_publish_metric}"}"
    ram_revamped_publish_rest="${ram_revamped_publish_rest# }"
    [ -n "${ram_revamped_publish_metric}" ] || continue
    ram_revamped_output "${ram_revamped_publish_metric}"
    revamped_publish_add "@ram_revamped_out_${ram_revamped_publish_metric}" "${RAM_REVAMPED_OUT}"
  done
  revamped_publish_commit || :
}

ram_revamped_tick() {
  ram_revamped_load
  ram_revamped_publish
}

ram_revamped_daemon() {
  revamped_ticker_run ram_revamped ram_revamped_tick "$$" "${RAM_REVAMPED_DEFAULT_INTERVAL}"
}

ram_revamped_monitor() {
  if revamped_has_command btop; then
    RAM_REVAMPED_MONITOR=btop
  elif revamped_has_command htop; then
    RAM_REVAMPED_MONITOR=htop
  elif revamped_is_macos; then
    RAM_REVAMPED_MONITOR="vm_stat 1"
  elif revamped_has_command free; then
    RAM_REVAMPED_MONITOR="free -h -s 1"
  else
    RAM_REVAMPED_MONITOR="cat /proc/meminfo; read -r ram_revamped_wait"
  fi
}

ram_revamped_popup() {
  ram_revamped_load
  ram_revamped_version
  ram_revamped_monitor
  if ram_revamped_version_ge "${RAM_REVAMPED_TMUX}" "${RAM_REVAMPED_POPUP_SINCE}"; then
    tmux display-popup -E -w "${RAM_REVAMPED_S_popup_width}" -h "${RAM_REVAMPED_S_popup_height}" "${RAM_REVAMPED_MONITOR}" 2>/dev/null || :
    return 0
  fi
  tmux new-window -n ram "${RAM_REVAMPED_MONITOR}" 2>/dev/null || :
}

ram_revamped_plan_keys() {
  case "${RAM_REVAMPED_S_popup_key}: ${RAM_REVAMPED_KEYS} " in
  "${RAM_REVAMPED_DEFAULT_POPUP_KEY}:"*" ${RAM_REVAMPED_DEFAULT_POPUP_KEY} "*) RAM_REVAMPED_SKIPPED="${RAM_REVAMPED_SKIPPED}${RAM_REVAMPED_SKIPPED:+ }${RAM_REVAMPED_DEFAULT_POPUP_KEY}" ;;
  *) ram_revamped_bind "${RAM_REVAMPED_S_popup_key}" "Memory details" run-shell "${RAM_REVAMPED_TOOL} popup" ;;
  esac
}

ram_revamped_replaced() {
  printf '%s\n' "$1" | RAM_REVAMPED_PUT="${RAM_REVAMPED_JOB}" awk -v mode="${RAM_REVAMPED_S_render}" -v kinds="${RAM_REVAMPED_METRICS}" '
    BEGIN {
      command = ENVIRON["RAM_REVAMPED_PUT"]
      count = split(kinds, kind, " ")
    }
    {
      line = $0
      for (i = 1; i <= count; i++) {
        holder = "#{ram_" kind[i] "}"
        target = (mode == "options") ? "#{E:@ram_revamped_out_" kind[i] "}" : "#(" command " status " kind[i] ")"
        done = ""
        while ((at = index(line, holder)) > 0) {
          done = done substr(line, 1, at - 1) target
          line = substr(line, at + length(holder))
        }
        line = done line
      }
      print line
    }
  '
}

ram_revamped_used() {
  printf '%s\n' "$1" | awk -v kinds="${RAM_REVAMPED_METRICS}" '
    BEGIN { count = split(kinds, kind, " ") }
    { text = text $0 " " }
    END {
      out = ""
      for (i = 1; i <= count; i++) {
        if (index(text, "#{ram_" kind[i] "}") > 0 || index(text, "@ram_revamped_out_" kind[i] "}") > 0 || index(text, " status " kind[i] ")") > 0) { out = out (out == "" ? "" : " ") kind[i] }
      }
      print out
    }
  '
}

ram_revamped_plan_status() {
  ram_revamped_plan_status_all=""
  for ram_revamped_plan_status_option in status-left status-right; do
    ram_revamped_plan_status_now=$(tmux show-option -gqv "${ram_revamped_plan_status_option}" 2>/dev/null) || ram_revamped_plan_status_now=""
    ram_revamped_plan_status_all="${ram_revamped_plan_status_all} ${ram_revamped_plan_status_now}"
    case "${ram_revamped_plan_status_now}" in
    *"#{ram_"*"}"*) ram_revamped_plan_status_new=$(ram_revamped_replaced "${ram_revamped_plan_status_now}") ;;
    *) continue ;;
    esac
    [ "${ram_revamped_plan_status_new}" != "${ram_revamped_plan_status_now}" ] || continue
    ram_revamped_emit set-option -gq "${ram_revamped_plan_status_option}" "${ram_revamped_plan_status_new}"
  done
  ram_revamped_plan_status_used=$(ram_revamped_used "${ram_revamped_plan_status_all}")
  [ "${ram_revamped_plan_status_used}" = "${RAM_REVAMPED_S_published}" ] || ram_revamped_emit set-option -gq @ram_revamped_published "${ram_revamped_plan_status_used}"
  RAM_REVAMPED_S_published="${ram_revamped_plan_status_used}"
}

ram_revamped_plan() {
  ram_revamped_load
  ram_revamped_version
  RAM_REVAMPED_NOTES=0
  ! ram_revamped_version_ge "${RAM_REVAMPED_TMUX}" "${RAM_REVAMPED_NOTES_SINCE}" || RAM_REVAMPED_NOTES=1
  ram_revamped_tools
  RAM_REVAMPED_KEYS=$(ram_revamped_held)
  RAM_REVAMPED_PLAN="" RAM_REVAMPED_SKIPPED=""
  ram_revamped_plan_keys
  ram_revamped_plan_status
}

ram_revamped_apply() {
  ram_revamped_plan
  ram_revamped_apply_status=0
  ram_revamped_deliver || ram_revamped_apply_status=1
  if [ "${RAM_REVAMPED_S_render}" = options ]; then
    revamped_ticker_start "${REVAMPED_LIB%/lib}/bin/ram-revamped"
  else
    tmux set-option -gqu @ram_revamped_ticker_pid 2>/dev/null || :
  fi
  return "${ram_revamped_apply_status}"
}
