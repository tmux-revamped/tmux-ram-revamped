#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/ram_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/ram_helpers.bash"

logged() {
  grep -qxF -- "$1" "${FAKE}/log"
}

other_owner() {
  quiet sleep 'kept=$(grep -v "^@ram_revamped_ticker_pid	" "'"${FAKE}"'/vars" || :)
printf "%s\n@ram_revamped_ticker_pid\tsomeone-else\n" "${kept}" | grep -v "^$" >"'"${FAKE}"'/vars.next"
mv -f "'"${FAKE}"'/vars.next" "'"${FAKE}"'/vars"'
}

settled() {
  local tries=0
  until "$@"; do
    tries=$((tries + 1))
    [[ "${tries}" -lt 200 ]] || return 1
    /bin/sleep 0.05
  done
}

@test "plan - a fresh install binds the monitor popup to M-r" {
  # Arrange
  local tool
  tool=$(tool_path)

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Memory details M-r run-shell ${tool} popup" ]]
}

@test "plan - a key set to off binds nothing, and a key the person names is bound whoever holds it" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  planned
  [[ -z "${output}" ]]
  printf 'bind-key    -T prefix F8     display-message mine\n' >"${FAKE}/keys"
  option popup_key F8

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Memory details F8 run-shell ${tool} popup" ]]
}

@test "plan - a tmux older than 3.1 gets its key without a note" {
  # Arrange
  tmux_is 3.0

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key M-r run-shell "*" popup" ]]
}

@test "plan - the default key is left alone when something else holds it, and bound again when the binding is the plugin's own" {
  # Arrange
  printf 'bind-key    -T prefix M-r     display-message mine\n' >"${FAKE}/keys"
  planned 'ram_revamped_plan; printf "[%s]\n" "${RAM_REVAMPED_SKIPPED}"; '
  [[ "${output}" == "[M-r]" ]]
  printf 'bind-key -r -T prefix M-r     run-shell "/old/bin/ram-revamped popup"\n' >"${FAKE}/keys"

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Memory details M-r run-shell "*" popup" ]]
}

@test "plan - each placeholder becomes a job that prints it, and the metrics in use are recorded" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  var status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] #{ram_swap} #{ram_swap_icon}'
  var status-left '#{ram_text} #S'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-left #(${tool} status text) #S" ]]
  [[ "${lines[1]}" == "set-option -gq status-right #(${tool} status fg_color)#(${tool} status icon) #(${tool} status percentage)#[default] #(${tool} status swap) #(${tool} status swap_icon)" ]]
  [[ "${lines[2]}" == "set-option -gq @ram_revamped_published percentage icon fg_color swap swap_icon text" ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "plan - every placeholder has its job" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  var status-right '#{ram_bg_color}#{ram_available}#{ram_swap_color}#{ram_pressure}#{ram_pressure_fg_color}#{ram_breakdown}#{ram_absolute}#{ram_commit}#{ram_reclaimable}#{ram_top_process}#{ram_graph}#{ram_trend}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status bg_color)#(${tool} status available)#(${tool} status swap_color)#(${tool} status pressure)#(${tool} status pressure_fg_color)#(${tool} status breakdown)#(${tool} status absolute)#(${tool} status commit)#(${tool} status reclaimable)#(${tool} status top_process)#(${tool} status graph)#(${tool} status trend)" ]]
  [[ "${lines[1]}" == "set-option -gq @ram_revamped_published bg_color available swap_color pressure pressure_fg_color breakdown absolute commit reclaimable top_process graph trend" ]]
}

@test "plan - a status line that ends in a semicolon keeps it, escaped, so tmux does not read it as a separator" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  var status-right '#{ram_percentage};'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status percentage)\\;" ]]
}

@test "plan - in options mode each placeholder becomes a read of the option the daemon fills" {
  # Arrange
  option popup_key off
  option render options
  var status-right '#{ram_fg_color}#{ram_percentage} | #{ram_swap}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #{E:@ram_revamped_out_fg_color}#{E:@ram_revamped_out_percentage} | #{E:@ram_revamped_out_swap}" ]]
  [[ "${lines[1]}" == "set-option -gq @ram_revamped_published percentage fg_color swap" ]]
}

@test "plan - a render mode the plugin does not know means jobs" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  option render both
  var status-right '#{ram_percentage}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status percentage)" ]]
}

@test "plan - a status line already rewritten is left as it is, and its metrics stay recorded" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  option render options
  option published "percentage swap"
  var status-right '#{E:@ram_revamped_out_percentage} | #{E:@ram_revamped_out_swap}'
  planned
  [[ -z "${output}" ]]
  option render jobs
  option published "swap swap_icon"
  var status-right "#(${tool} status swap_icon) #(${tool} status swap)"

  # Act
  planned

  # Assert
  [[ -z "${output}" ]]
}

@test "plan - a status line with no placeholder is not written, and an old list of metrics is emptied" {
  # Arrange
  option popup_key off
  option published "percentage"
  var status-right '%H:%M #{session_name}'

  # Act
  planned

  # Assert
  [[ "${output}" == 'set-option -gq @ram_revamped_published ""' ]]
}

@test "plan - a setting given in the environment rides on the key and on every job" {
  # Arrange
  var status-right '#{ram_percentage}'

  # Act
  planned 'export RAM_REVAMPED_INTERVAL=2; '

  # Assert
  [[ "${lines[0]}" == *"ram-revamped' --interval '2' popup" ]]
  [[ "${lines[1]}" == *"ram-revamped' --interval '2' status percentage)" ]]
}

@test "plan - settings given in the environment ride in the order of the settings table, and an empty one rides too" {
  # Arrange
  var status-right '#{ram_percentage}'

  # Act
  planned 'export RAM_REVAMPED_HIGH_THRESH=90 RAM_REVAMPED_SWAP_LABEL= RAM_REVAMPED_INTERVAL=3 RAM_REVAMPED_POPUP_KEY=F8 RAM_REVAMPED_POPUP_WIDTH=90%; '

  # Assert
  [[ "${lines[0]}" == "bind-key -N Memory details F8 run-shell "*"ram-revamped' --popup-width '90%' --interval '3' --high-thresh '90' --swap-label '' popup" ]]
}

@test "plan - apply sends everything in one tmux call and clears a daemon's claim in jobs mode" {
  # Arrange
  var status-right '#{ram_percentage}'

  # Act
  lib_run ram 'ram_revamped_apply'

  # Assert
  [[ "${status}" -eq 0 ]]
  run sends
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "bind-key -N Memory details M-r run-shell "*" popup ; set-option -gq status-right #("*" status percentage) ; set-option -gq @ram_revamped_published percentage" ]]
  [[ "${lines[1]}" == "set-option -gqu @ram_revamped_ticker_pid" ]]
}

@test "plan - when tmux refuses the batch each command is sent alone, and the bad one fails the run" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key F99
  var status-right '#{ram_percentage}'
  printf '%s\n' "bind-key -N Memory details F99 run-shell ${tool} popup" >"${FAKE}/refused"

  # Act
  lib_run ram 'ram_revamped_apply'

  # Assert
  [[ "${status}" -eq 1 ]]
  run sent '^set-option -gq status-right #(.* status percentage)$'
  [[ "${output}" == "1" ]]
  holds published percentage
}

@test "plan - in options mode apply starts the daemon, which claims the ticker and publishes until another takes over" {
  # Arrange
  meminfo
  option popup_key off
  option render options
  option interval 1
  var status-right '#{ram_percentage}'
  other_owner

  # Act
  lib_run ram 'ram_revamped_apply'

  # Assert
  [[ "${status}" -eq 0 ]]
  settled holds out_percentage "75%%"
  settled holds ticker_pid someone-else
  run sent '^set-option -gq @ram_revamped_ticker_pid [0-9][0-9]*$'
  [[ "${output}" == "1" ]]
}

@test "plan - the daemon ends when another process owns the ticker" {
  # Arrange
  meminfo
  option published "available"
  other_owner

  # Act
  tool daemon

  # Assert
  [[ "${status}" -eq 0 ]]
  holds out_available "25%%"
  holds ticker_pid someone-else
}

@test "plan - the popup opens btop when it is installed, at the size the options give" {
  # Arrange
  quiet btop ':'
  quiet htop ':'
  option popup_width 90%
  option popup_height 50%

  # Act
  lib_run ram 'ram_revamped_popup'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "display-popup -E -w 90% -h 50% btop"
}

@test "plan - without btop the popup opens htop" {
  # Arrange
  quiet htop ':'

  # Act
  lib_run ram 'ram_revamped_popup'

  # Assert
  logged "display-popup -E -w 80% -h 60% htop"
}

@test "plan - with neither, macOS follows vm_stat every second" {
  # Arrange
  macos
  quiet free ':'

  # Act
  lib_run ram 'ram_revamped_popup'

  # Assert
  logged "display-popup -E -w 80% -h 60% vm_stat 1"
}

@test "plan - with neither, Linux follows free every second, and prints /proc/meminfo when free is missing too" {
  # Arrange
  lib_run ram 'ram_revamped_popup'
  logged "display-popup -E -w 80% -h 60% cat /proc/meminfo; read -r ram_revamped_wait"
  quiet free ':'

  # Act
  lib_run ram 'ram_revamped_popup'

  # Assert
  logged "display-popup -E -w 80% -h 60% free -h -s 1"
}

@test "plan - on a tmux older than 3.2 the monitor opens in a window named ram" {
  # Arrange
  tmux_is 3.1
  quiet htop ':'

  # Act
  lib_run ram 'ram_revamped_popup'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "new-window -n ram htop"
  run sent '^display-popup'
  [[ "${output}" == "0" ]]
}

@test "plan - a popup or a window tmux refuses to open leaves the key quiet" {
  # Arrange
  quiet htop ':'
  printf '%s\n' "display-popup -E -w 80% -h 60% htop" "new-window -n ram htop" >"${FAKE}/refused"
  lib_run ram 'ram_revamped_popup'
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  tmux_is 3.1

  # Act
  lib_run ram 'ram_revamped_popup'

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "plan - a path is quoted for a job with each hash and each percent sign doubled, and for a key with no hash left" {
  # Arrange
  local script='ram_revamped_job_quote "/a b/it'"'"'s#1 50%"; ram_revamped_literal "/a b/it'"'"'s#1 50%"'

  # Act
  lib_run ram "${script}"

  # Assert
  [[ "${lines[0]}" == "'/a b/it'\\''s##1 50%%'" ]]
  [[ "${lines[1]}" == "'/a b/it'\\''s'\"\$(printf '%b' '\\0043')\"'1 50%'" ]]
}

@test "plan - a format given in the environment rides on the job with its percent signs doubled, since tmux reads the status line as a time format" {
  # Arrange
  option popup_key off
  var status-right '#{ram_percentage}'

  # Act
  planned 'export RAM_REVAMPED_PERCENTAGE_FORMAT="%s%% used"; '

  # Assert
  [[ "${lines[0]}" == *"ram-revamped' --percentage-format '%%s%%%% used' status percentage)" ]]
}
