<div align="center">

<h1>tmux-ram-revamped</h1>

**RAM usage for your tmux status bar, without ever blocking the status render.**

[![Tests](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

</div>

**2** platforms · **95%+** coverage

Shows RAM usage, available memory, swap, and a memory breakdown in your tmux status bar. The value is read from a tmux server user-option and returns instantly, while a detached worker recomputes it in the background. No temp files are used; all state lives in tmux options.

Inspired by the RAM metrics in [tmux-cpu](https://github.com/tmux-plugins/tmux-cpu). Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><b>Non-blocking</b><br>The status render reads a cached value and returns instantly. A detached worker recomputes in the background.</td>
<td><b>No temp files</b><br>All state lives in tmux server options. Nothing is written to disk.</td>
</tr>
<tr>
<td><b>Cross-platform</b><br>Runs on Linux and macOS, Intel and Apple Silicon, with built-in tools only.</td>
<td><b>Tested</b><br>95%+ coverage on every supported platform.</td>
</tr>
</table>

## Placeholders

| Placeholder | Output |
|-------------|--------|
| `#{ram_percentage}` | used memory, for example `61%` |
| `#{ram_icon}` | a tier icon for the current usage |
| `#{ram_fg_color}` | foreground color for the current tier |
| `#{ram_bg_color}` | background color for the current tier |
| `#{ram_available}` | available memory percent, for example `40%` |
| `#{ram_swap}` | swap used percent, empty when there is no swap |
| `#{ram_pressure}` | memory-pressure percent, higher means more pressure, for example `36%` |
| `#{ram_pressure_fg_color}` | foreground color for the pressure tier, by the usage thresholds |
| `#{ram_breakdown}` | memory composition, for example `W 3.2G C 1.1G I 2.0G F 4.5G`; on Linux the four slots hold buffers, zero, cached, and free |
| `#{ram_swap_icon}` | warning icon shown while swap is in use |
| `#{ram_swap_color}` | warning color shown while swap is in use |
| `#{ram_absolute}` | absolute used over total, for example `12.3G / 32G` |
| `#{ram_commit}` | committed-memory ratio percent (Linux), early OOM warning |
| `#{ram_reclaimable}` | reclaimable cache size (Linux), for example `4.0G` |
| `#{ram_top_process}` | the largest memory consumer, for example `firefox 1.2G` |
| `#{ram_graph}` | history sparkline of recent usage, for example `▁▂▄▆█` |
| `#{ram_trend}` | trend arrow over the history window (`↑` `↓` `→`) |
| `#{ram_text}` | glyph-free plain-language line for screen readers |

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

Press `prefix + I` to install.

## Detail popup

Press `prefix + M-r` to open a memory monitor in a tmux popup. It launches `btop`
or `htop` when present, otherwise `free` on Linux or `vm_stat` on macOS. On tmux
older than 3.2 it opens a window instead. Rebind it with `@ram_revamped_popup_key`;
`set -g @ram_revamped_popup_key 'M'` restores the key used before 2.0.0.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@ram_revamped_interval` | `5` | seconds a sample stays fresh before a background re-sample |
| `@ram_revamped_detail_interval` | `60` | seconds the slower detail metrics, pressure, breakdown, absolute, commit, reclaimable and top process, stay fresh before a re-sample |
| `@ram_revamped_percentage_format` | `%s%%` | printf format for the value |
| `@ram_revamped_medium_thresh` | `50` | usage percent at which the tier becomes medium |
| `@ram_revamped_high_thresh` | `85` | usage percent at which the tier becomes high |
| `@ram_revamped_low_icon` | `▰▱▱` | icon for the low tier |
| `@ram_revamped_medium_icon` | `▰▰▱` | icon for the medium tier |
| `@ram_revamped_high_icon` | `▰▰▰` | icon for the high tier |
| `@ram_revamped_low_fg_color` | empty | foreground for the low tier |
| `@ram_revamped_medium_fg_color` | empty | foreground for the medium tier |
| `@ram_revamped_high_fg_color` | empty | foreground for the high tier |
| `@ram_revamped_low_bg_color` | empty | background for the low tier |
| `@ram_revamped_medium_bg_color` | empty | background for the medium tier |
| `@ram_revamped_high_bg_color` | empty | background for the high tier |
| `@ram_revamped_available_format` | `%s%%` | format for available memory |
| `@ram_revamped_swap_format` | `%s%%` | format for swap usage |
| `@ram_revamped_pressure_format` | `%s%%` | format for the memory-pressure metric |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | format for the memory breakdown (four values: wired, compressed, inactive, free on macOS; buffers, zero, cached, free on Linux) |
| `@ram_revamped_absolute_format` | `%s / %s` | format for absolute used over total |
| `@ram_revamped_commit_format` | `%s%%` | format for the commit ratio |
| `@ram_revamped_reclaimable_format` | `%s` | format for the reclaimable cache figure |
| `@ram_revamped_top_process_format` | `%s %s` | format for the top memory process (name, size) |
| `@ram_revamped_history_size` | `30` | number of samples kept in the history ring |
| `@ram_revamped_trend_threshold` | `3` | percent change before the trend arrow flips |
| `@ram_revamped_trend_up` | `↑` | glyph for a rising trend |
| `@ram_revamped_trend_down` | `↓` | glyph for a falling trend |
| `@ram_revamped_trend_flat` | `→` | glyph for a steady trend |
| `@ram_revamped_swap_warn_thresh` | `1` | swap percent at or above which the warning shows |
| `@ram_revamped_swap_active_icon` | empty | icon shown by `#{ram_swap_icon}` while swap is active |
| `@ram_revamped_swap_active_color` | empty | color shown by `#{ram_swap_color}` while swap is active |
| `@ram_revamped_popup_key` | `M-r` | prefix key that opens the detail popup; set `off` to bind nothing |
| `@ram_revamped_popup_width` | `80%` | popup width |
| `@ram_revamped_popup_height` | `60%` | popup height |
| `@ram_revamped_enable_logging` | `0` | set to `1` to log under `~/.tmux/ram-revamped-logs` |

### Internal state

The plugin manages these options itself. Do not set them.

| Option | Holds |
|--------|-------|
| `@ram_revamped_published` | space-separated metrics the status line uses, set at load so the options-mode sampler publishes only those |

## Labels

Every value placeholder can carry a label, an icon or word printed before the value only when the value is not empty, so each figure on the bar says what it is. Set `@ram_revamped_<metric>_label` for one metric, or `@ram_revamped_icons` to `nerd` to label every metric from a Nerd Font set. A metric's own label wins over the set, and setting it to `''` removes the set's label for that metric. The default, `ascii`, adds no labels, so existing bars render unchanged.

Set `@ram_revamped_fixed_width` to `on` to pad every value on the left to the widest it can get, such as four characters for a percentage, so a value that changes length, like `9%` becoming `42%`, never shifts the rest of a right-aligned status line. `@ram_revamped_<metric>_width` sets one metric's width and wins over the fixed width. A longer value is never cut. Both are off by default.

### Render mode

By default each placeholder becomes a `#()` call, and tmux runs it on every status redraw, which can be about once a second when several plugins share the bar. Set `@ram_revamped_render` to `options` and each placeholder becomes a read of a tmux option instead, such as `#{E:@ram_revamped_out_percentage}`. One background process per server samples memory every `@ram_revamped_interval` seconds, 5 by default, writes every value the status line uses in a single tmux call, and redraws once, so values change together and nothing renders empty while a job runs. The process exits after its current tick when the server stops, and a config reload replaces it.

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```


```tmux
set -g @ram_revamped_icons 'nerd'
set -g @ram_revamped_percentage_label ''
```

| Metric | `nerd` glyph |
|--------|--------------|
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

## Theme color suggestions

The tier colors default to the 16 ANSI names, which the active theme remaps, so the plugin matches any theme out of the box; for exact hex copy one block below.

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

The `#{ram_breakdown}` placeholder reports the memory composition in gigabytes.
On macOS the four values are wired, compressed, inactive, and free from
`vm_stat`, matching Activity Monitor. Linux has no wired or compressed counts, so
the same four slots hold buffers, zero, cached, and free from `/proc/meminfo`;
with the default format the `W` figure is buffers and the `I` figure is the page
cache.

The `#{ram_pressure}` placeholder reports a memory-pressure metric. On Linux it
is the `some avg10` value from `/proc/pressure/memory`, the percent of time
memory was stalled in the last ten seconds. On macOS it is the wired-plus-
compressed share of memory from `vm_stat`, the pages that cannot be reclaimed
plus the pages already compressed under stress, which is the signal Activity
Monitor and iStat track. A higher number means more pressure on both platforms.
The placeholder is empty when the source is unavailable.

## Support by platform and architecture

Works on every supported platform and architecture with built-in tools, no extra
package required.

| Platform | Source |
|----------|--------|
| macOS (Intel and Apple Silicon) | `vm_stat` page counts |
| Linux (x86_64 and arm64) | `/proc/meminfo`, used is total minus available |

## Development

```sh
make test
make lint
make coverage
```

## License

[MIT](LICENSE), copyright Gustavo Franco.

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
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save, auto-save, and restore your whole tmux environment, one plugin, no status-line tricks |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **this plugin**, RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab on the status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | BSP tiling window management for tmux. Eight layouts, nineteen operations, zero dependencies |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
