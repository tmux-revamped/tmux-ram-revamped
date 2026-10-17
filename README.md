<div align="center">

# tmux-ram-revamped

<strong>RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">What it does</a> &nbsp;|&nbsp;
  <a href="#installation">Installation</a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#configuration">Configuration</a> &nbsp;|&nbsp;
  <a href="#key-bindings">Key bindings</a> &nbsp;|&nbsp;
  <a href="#how-it-works">How it works</a>
</p>

</div>

**18 placeholders. A fresh sample every 5 seconds and the slower details every 60. Built-in tools only. Tested on macOS and Linux.**

---

## What it does

The plugin puts memory figures in your status line: used and available memory, swap, memory pressure, a breakdown of where memory went, the largest process, and a sparkline of recent usage. The status line reads a value tmux already holds, and a background process takes the next sample. `prefix + M-r` opens a memory monitor in a popup.

## Requirements

| Requirement | Version or note |
|:------------|:----------------|
| tmux | 3.2 or later |
| bash | 3.2 or later, so the stock macOS `/bin/bash` works |
| Operating system | macOS on Apple Silicon and Intel, Linux on x86_64 and arm64 |
| Core tools | BSD, GNU or uutils coreutils |
| Memory source | `vm_stat` and `sysctl` on macOS, `/proc/meminfo` and `/proc/pressure/memory` on Linux |
| `btop` or `htop` | Optional, for the detail popup |

## Installation

With [TPM](https://github.com/tmux-plugins/tpm), add the plugin and a placeholder to `~/.tmux.conf`, then press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

Without TPM, clone the repository and run the entry point from `~/.tmux.conf`, after the line that sets `status-right`:

```sh
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

## Usage

Put any of these placeholders in `status-left` or `status-right`. A placeholder whose source is missing renders nothing.

| Placeholder | Output |
|:------------|:-------|
| `#{ram_percentage}` | Used memory, for example `61%` |
| `#{ram_icon}` | Tier icon for the used memory |
| `#{ram_fg_color}` | Foreground style for the used-memory tier |
| `#{ram_bg_color}` | Background style for the used-memory tier |
| `#{ram_available}` | Available memory, for example `40%` |
| `#{ram_swap}` | Swap in use, empty when there is no swap |
| `#{ram_swap_icon}` | Warning icon while swap use is at or above the threshold |
| `#{ram_swap_color}` | Warning style while swap use is at or above the threshold |
| `#{ram_pressure}` | Memory pressure, for example `36%`. Higher means more pressure |
| `#{ram_pressure_fg_color}` | Foreground style for the pressure, by the same thresholds as used memory |
| `#{ram_breakdown}` | Memory composition in gigabytes, for example `W 3.2G C 1.1G I 2.0G F 4.5G` |
| `#{ram_absolute}` | Used over total, for example `12.3G / 32G` |
| `#{ram_commit}` | Committed memory over the commit limit, Linux only |
| `#{ram_reclaimable}` | Page cache, buffers and reclaimable slab, Linux only, for example `4.0G` |
| `#{ram_top_process}` | The process with the largest resident memory, for example `firefox 1.2G` |
| `#{ram_graph}` | Sparkline of recent samples, for example `▁▂▄▆█` |
| `#{ram_trend}` | `↑`, `↓` or `→` over the history window |
| `#{ram_text}` | A plain line for screen readers, for example `RAM 61% used, 40% available, swap 3%` |

A fuller status line, with the style reset at the end:

```tmux
set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] #{ram_graph}'
```

The plugin also answers two commands from a shell: `~/.tmux/plugins/tmux-ram-revamped/src/ram.sh doctor` reports the platform and the sources it found, and `ram.sh popup` opens the monitor.

## Configuration

Set any option in `~/.tmux.conf` before the plugin loads.

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@ram_revamped_interval` | `5` | Seconds a sample stays fresh |
| `@ram_revamped_detail_interval` | `60` | Seconds the pressure, breakdown, absolute, commit, reclaimable and top process figures stay fresh |
| `@ram_revamped_render` | unset | `options` turns each placeholder into an option read, written by one background process per server |
| `@ram_revamped_medium_thresh` | `50` | Percent at which the tier becomes medium |
| `@ram_revamped_high_thresh` | `85` | Percent at which the tier becomes high |
| `@ram_revamped_low_icon` | `▰▱▱` | Icon for the low tier |
| `@ram_revamped_medium_icon` | `▰▰▱` | Icon for the medium tier |
| `@ram_revamped_high_icon` | `▰▰▰` | Icon for the high tier |
| `@ram_revamped_low_fg_color` | empty | Foreground style for the low tier, such as `#[fg=green]` |
| `@ram_revamped_medium_fg_color` | empty | Foreground style for the medium tier |
| `@ram_revamped_high_fg_color` | empty | Foreground style for the high tier |
| `@ram_revamped_low_bg_color` | empty | Background style for the low tier |
| `@ram_revamped_medium_bg_color` | empty | Background style for the medium tier |
| `@ram_revamped_high_bg_color` | empty | Background style for the high tier |
| `@ram_revamped_percentage_format` | `%s%%` | printf format for used memory |
| `@ram_revamped_available_format` | `%s%%` | printf format for available memory |
| `@ram_revamped_swap_format` | `%s%%` | printf format for swap |
| `@ram_revamped_pressure_format` | `%s%%` | printf format for pressure |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | printf format for the four breakdown values |
| `@ram_revamped_absolute_format` | `%s / %s` | printf format for used and total |
| `@ram_revamped_commit_format` | `%s%%` | printf format for the commit ratio |
| `@ram_revamped_reclaimable_format` | `%s` | printf format for the reclaimable size |
| `@ram_revamped_top_process_format` | `%s %s` | printf format for the process name and size |
| `@ram_revamped_history_size` | `30` | Samples kept for the sparkline and the trend |
| `@ram_revamped_trend_threshold` | `3` | Percentage points of change before the trend arrow leaves `→` |
| `@ram_revamped_trend_up` | `↑` | Rising trend glyph |
| `@ram_revamped_trend_down` | `↓` | Falling trend glyph |
| `@ram_revamped_trend_flat` | `→` | Steady trend glyph |
| `@ram_revamped_swap_warn_thresh` | `1` | Swap percent at which the swap warning shows |
| `@ram_revamped_swap_active_icon` | empty | Icon that `#{ram_swap_icon}` shows |
| `@ram_revamped_swap_active_color` | empty | Style that `#{ram_swap_color}` shows |
| `@ram_revamped_icons` | `ascii` | `nerd` labels every value with a Nerd Font glyph |
| `@ram_revamped_<metric>_label` | unset | Text printed before one value, only when the value is not empty. `''` removes the Nerd Font label for that value |
| `@ram_revamped_fixed_width` | `off` | `on` pads percentages to 4 characters, so a change from `9%` to `42%` does not shift the status line |
| `@ram_revamped_<metric>_width` | unset | Pad one value to this many characters. A longer value is never cut |
| `@ram_revamped_popup_key` | `M-r` | Prefix key that opens the detail popup. `off` binds nothing |
| `@ram_revamped_popup_width` | `80%` | Popup width |
| `@ram_revamped_popup_height` | `60%` | Popup height |
| `@ram_revamped_enable_logging` | `0` | `1` writes errors to `~/.tmux/ram-revamped-logs/` |

`<metric>` is one of `percentage`, `available`, `swap`, `pressure`, `breakdown`, `absolute`, `commit`, `reclaimable`, `top_process`, `graph` and `trend`.

<details>
<summary><strong>Tier colors for common themes</strong></summary>

### Catppuccin Mocha

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#a6e3a1]'
set -g @ram_revamped_medium_fg_color '#[fg=#f9e2af]'
set -g @ram_revamped_high_fg_color '#[fg=#f38ba8]'
```

### Dracula

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#50fa7b]'
set -g @ram_revamped_medium_fg_color '#[fg=#f1fa8c]'
set -g @ram_revamped_high_fg_color '#[fg=#ff5555]'
```

### Nord

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#a3be8c]'
set -g @ram_revamped_medium_fg_color '#[fg=#ebcb8b]'
set -g @ram_revamped_high_fg_color '#[fg=#bf616a]'
```

### Gruvbox Dark

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#b8bb26]'
set -g @ram_revamped_medium_fg_color '#[fg=#fabd2f]'
set -g @ram_revamped_high_fg_color '#[fg=#fb4934]'
```

### Tokyo Night

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#9ece6a]'
set -g @ram_revamped_medium_fg_color '#[fg=#e0af68]'
set -g @ram_revamped_high_fg_color '#[fg=#f7768e]'
```

### Solarized Dark

```tmux
set -g @ram_revamped_low_fg_color '#[fg=#859900]'
set -g @ram_revamped_medium_fg_color '#[fg=#b58900]'
set -g @ram_revamped_high_fg_color '#[fg=#dc322f]'
```

</details>

### Internal state

The plugin manages these options itself. Do not set them.

| Option | Holds |
|:-------|:------|
| `@ram_revamped_published` | The metrics the status line uses, recorded at load so options mode writes only those |
| `@ram_revamped_history` | The recent used-memory samples behind `#{ram_graph}` and `#{ram_trend}` |
| `@ram_revamped_out_<metric>` | The rendered value of each metric in options mode |
| `@ram_revamped_ticker_pid` | The process id of the options-mode background process |
| `@ram_revamped_option_names` | The options that process reads in one tmux call per tick |
| `@ram_revamped_percent` and the other samples | Cached readings, each with a `_ts` timestamp |

## Key bindings

| Key | Action | Option |
|:----|:-------|:-------|
| `prefix + M-r` | Open the detail popup | `@ram_revamped_popup_key` |

`M-r` is the one key the tmux-revamped family allocates to this plugin. Before 2.0.0 the popup was on `prefix + M`, which tmux binds to clear the marked pane. To keep the old key:

```tmux
set -g @ram_revamped_popup_key 'M'
```

The popup runs `btop` or `htop` when one is installed, `vm_stat 1` on macOS, and `free -h -s 1` on Linux.

## How it works

**Jobs mode, the default.** The entry point replaces each placeholder with a `#()` call to [`src/ram.sh`](src/ram.sh). The call prints the cached value at once. When the cache is older than `@ram_revamped_interval`, it also starts a detached process that takes a new sample and stores it in tmux options. A lock option keeps a second sampler from starting while one runs.

**Options mode.** tmux reruns every `#()` call on each redraw, which can be about once a second when several plugins share the bar. With `@ram_revamped_render` set to `options`, each placeholder becomes a read such as `#{E:@ram_revamped_out_percentage}`. One background process per server samples every `@ram_revamped_interval` seconds, writes every value the status line uses in one tmux call, and refreshes the clients once. It exits when the server stops, and a config reload replaces it.

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

**Where the numbers come from.**

| Figure | macOS | Linux |
|:-------|:------|:------|
| Used | Active, wired and compressed pages from `vm_stat` | `MemTotal` minus `MemAvailable` from `/proc/meminfo` |
| Available | Free, inactive and speculative pages | `MemAvailable` |
| Swap | `sysctl vm.swapusage` | `SwapTotal` and `SwapFree` |
| Pressure | Wired and compressed pages as a share of all pages | `some avg10` from `/proc/pressure/memory`, the percent of the last 10 seconds spent stalled on memory |
| Breakdown | Wired, compressed, inactive and free | Buffers, `0`, cached and free, in the same four slots |
| Top process | `ps axo rss=,comm=` | `ps axo rss=,comm=` |

The process name comes from `ps`, which any user on the machine controls, so every `#` in it is doubled before tmux reads it as a format. Numbers are formatted under the C locale, so a locale with a decimal comma still prints `1.5G`.

<details>
<summary><strong>Nerd Font labels</strong></summary>

```tmux
set -g @ram_revamped_icons 'nerd'
set -g @ram_revamped_percentage_label ''
```

| Metric | Glyph |
|:-------|:------|
| `percentage` | `md-gauge` |
| `available` | `md-memory` |
| `swap` | `md-file_swap` |
| `pressure` | `U+F0F86` |
| `breakdown` | `md-chart_donut` |
| `absolute` | `md-database` |
| `commit` | `md-sigma` |
| `reclaimable` | `md-recycle` |
| `top_process` | `md-application` |
| `graph` | `md-chart_line_variant` |
| `trend` | `md-trending_up` |

</details>

## Development

| Command | What it does |
|:--------|:-------------|
| `make test` | Runs the bats suite |
| `make lint` | Runs shellcheck on every shell file |
| `make coverage` | Measures line coverage with kcov and fails below 95 percent, on Linux |

The suite needs `bats-core` and tmux.

## License

[MIT](LICENSE)

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness, CI and family tooling |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **this plugin**, RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
