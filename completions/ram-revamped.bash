# shellcheck shell=bash
# shellcheck disable=SC2207

_ram_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  status)
    COMPREPLY=($(compgen -W "percentage icon fg_color bg_color available swap swap_icon swap_color pressure pressure_fg_color breakdown absolute commit reclaimable top_process graph trend text" -- "${cur}"))
    return
    ;;
  --render)
    COMPREPLY=($(compgen -W "jobs options" -- "${cur}"))
    return
    ;;
  --icons)
    COMPREPLY=($(compgen -W "ascii nerd" -- "${cur}"))
    return
    ;;
  --fixed-width)
    COMPREPLY=($(compgen -W "on off" -- "${cur}"))
    return
    ;;
  --popup-key | --popup-width | --popup-height | --interval | --detail-interval | --history-size | --medium-thresh | --high-thresh | --swap-warn-thresh | --trend-threshold | --low-icon | --medium-icon | --high-icon | --low-fg-color | --medium-fg-color | --high-fg-color | --low-bg-color | --medium-bg-color | --high-bg-color | --swap-active-icon | --swap-active-color | --trend-up | --trend-down | --trend-flat | --percentage-format | --available-format | --swap-format | --pressure-format | --breakdown-format | --absolute-format | --commit-format | --reclaimable-format | --top-process-format | --percentage-label | --available-label | --swap-label | --pressure-label | --breakdown-label | --absolute-label | --commit-label | --reclaimable-label | --top-process-label | --graph-label | --trend-label | --percentage-width | --available-width | --swap-width | --pressure-width | --breakdown-width | --absolute-width | --commit-width | --reclaimable-width | --top-process-width | --graph-width | --trend-width)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list status refresh card popup daemon doctor version help --json --theme --popup-key --popup-width --popup-height --interval --detail-interval --render --history-size --medium-thresh --high-thresh --swap-warn-thresh --trend-threshold --low-icon --medium-icon --high-icon --low-fg-color --medium-fg-color --high-fg-color --low-bg-color --medium-bg-color --high-bg-color --swap-active-icon --swap-active-color --trend-up --trend-down --trend-flat --percentage-format --available-format --swap-format --pressure-format --breakdown-format --absolute-format --commit-format --reclaimable-format --top-process-format --icons --fixed-width --percentage-label --available-label --swap-label --pressure-label --breakdown-label --absolute-label --commit-label --reclaimable-label --top-process-label --graph-label --trend-label --percentage-width --available-width --swap-width --pressure-width --breakdown-width --absolute-width --commit-width --reclaimable-width --top-process-width --graph-width --trend-width" -- "${cur}"))
}

complete -F _ram_revamped ram-revamped
