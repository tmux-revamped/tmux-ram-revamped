<div align="center">

# tmux-ram-revamped

<strong>RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-ram-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-ram-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-ram-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-ram-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-ram-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-ram-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#quick-start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#usage">Usage</a> &nbsp;|&nbsp;
  <a href="#how-it-works">How it works</a> &nbsp;|&nbsp;
  <a href="#screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="ram-revamped showing the memory in use, coloured by tier, opening the monitor popup, switching to Nerd Font labels, the graph and the options render mode" width="800">
</p>

```console
$ ram-revamped refresh
Refreshed. 88% of the memory is in use.
$ ram-revamped status text
RAM 88% used, 12% available, swap 75%
```

**18** placeholders, **2** render modes, macOS and Linux, tmux **3.2** or later.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:--------|:---------|
| tmux | 3.2 or later | the family floor, and the popup |
| btop, htop | optional | the monitor the popup opens; without them it follows `vm_stat 1` on macOS and `free -h -s 1` on Linux |
| gum | optional | the menu, tables and colours of `ram-revamped`; without it every command prints plain text |

It runs on Linux and macOS with BSD, GNU, uutils or BusyBox tools. Each figure comes from something the OS ships:

| Figure | macOS | Linux |
|:-----|:------|:------|
| Used, available, breakdown, sizes | `vm_stat` | `/proc/meminfo` |
| Swap | `sysctl vm.swapusage` | `/proc/meminfo` |
| Pressure | wired and compressed pages of `vm_stat` | `/proc/pressure/memory` |
| Commit ratio | none: macOS keeps no commit limit | `/proc/meminfo` |
| Reclaimable | purgeable and file-backed pages of `vm_stat` | cached, buffers and reclaimable slab of `/proc/meminfo` |
| Top process | `ps` | `ps` |

A missing source leaves its placeholder empty, and `ram-revamped doctor` names it.

### Install

With [TPM](https://github.com/tmux-plugins/tpm), add the plugin to `~/.tmux.conf` and press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
```

To install by hand, clone the repository and run the entrypoint from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

Set `status-left` or `status-right` before the plugin loads. The plugin replaces the placeholders it finds there once, at load time.

`make install` in the clone also puts `ram-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-ram-revamped/bin/ram-revamped doctor
```

## Usage

The plugin shows how much memory is in use, with the memory available, the swap, the pressure, a breakdown, the largest process and a graph of the recent samples. The status line prints a value tmux already holds, and a background sample refreshes it.

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
| `#{ram_commit}` | Committed memory over the commit limit; empty on macOS, which keeps no commit limit |
| `#{ram_reclaimable}` | Page cache, buffers and reclaimable slab on Linux, purgeable and file-backed pages on macOS, for example `4.0G` |
| `#{ram_top_process}` | The process with the largest resident memory, for example `firefox 1.2G` |
| `#{ram_graph}` | Sparkline of recent samples, for example `▁▂▄▆█` |
| `#{ram_trend}` | `↑`, `↓` or `→` over the history window |
| `#{ram_text}` | A plain line for screen readers, for example `RAM 61% used, 40% available, swap 3%` |

Put placeholders in the status line:

```tmux
set -g @ram_revamped_low_fg_color '#[fg=green]'
set -g @ram_revamped_medium_fg_color '#[fg=yellow]'
set -g @ram_revamped_high_fg_color '#[fg=red]'

set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] '
```

The same example is in [examples/status-right.tmux.conf](examples/status-right.tmux.conf).

### Labels and widths

`@ram_revamped_<metric>_label` prints an icon or word before one metric, only when its value is not empty. `@ram_revamped_icons` set to `nerd` labels every metric below with a Nerd Font glyph. A metric's own label wins over the set, and a label set to nothing means the default, so the glyph stays. The default, `ascii`, adds no labels.

| Metric | `nerd` glyph |
|:-------|:-------------|
| `percentage` | U+F029A |
| `available` | U+F035B |
| `swap` | U+F0FB4 |
| `pressure` | U+F0F86 |
| `breakdown` | U+F07AF |
| `absolute` | U+F01BC |
| `commit` | U+F04A0 |
| `reclaimable` | U+F044C |
| `top_process` | U+F08C6 |
| `graph` | U+F07B1 |
| `trend` | U+F0535 |

`@ram_revamped_fixed_width` set to `on` pads the used, available and swap percents on the left to four characters, so a change from `9%` to `42%` does not shift the rest of the line. `@ram_revamped_<metric>_width` sets one metric's width and wins over the fixed width. A longer value is never cut.

### Render mode

By default each placeholder becomes a `#()` call, which tmux reruns on status redraws. With `@ram_revamped_render` set to `options`, each placeholder becomes an option read such as `#{E:@ram_revamped_out_percentage}`. One background process per server then samples every `@ram_revamped_interval` seconds and writes all values in one tmux call, so they change together.

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

### Tier colors

The tier styles are empty by default, so `#{ram_fg_color}`, `#{ram_bg_color}` and `#{ram_pressure_fg_color}` print nothing until you set them. These palettes map low use to green, medium to yellow and high to red:

| Theme | Low | Medium | High |
|:------|:----|:-------|:-----|
| Catppuccin Mocha | `#a6e3a1` | `#f9e2af` | `#f38ba8` |
| Dracula | `#50fa7b` | `#f1fa8c` | `#ff5555` |
| Nord | `#a3be8c` | `#ebcb8b` | `#bf616a` |
| Gruvbox Dark | `#b8bb26` | `#fabd2f` | `#fb4934` |
| Tokyo Night | `#9ece6a` | `#e0af68` | `#f7768e` |
| Solarized Dark | `#859900` | `#b58900` | `#dc322f` |

Each value goes in a style, such as `set -g @ram_revamped_low_fg_color '#[fg=#a6e3a1]'`.

| Command | What it does |
|:--------|:-------------|
| `ram-revamped apply` | Binds the popup key and fills the placeholders now; the entry point runs it when tmux loads the plugin |
| `ram-revamped list` | Prints every command `apply` would send and changes nothing; `--json` prints one object |
| `ram-revamped status NAME` | Prints one placeholder, such as `percentage`, `swap` or `graph`; the status line runs it |
| `ram-revamped refresh` | Samples the memory now and says how much is in use |
| `ram-revamped card` | Reads everything now and prints one row per figure |
| `ram-revamped popup` | Opens a memory monitor in a tmux popup: btop, else htop, else the system's own figures; the popup key runs it |
| `ram-revamped daemon` | Publishes the placeholders on every tick, for the `options` render mode; `apply` starts it |
| `ram-revamped doctor` | One row per dependency: each tool or file a figure comes from, the monitor the popup opens, and any key left alone |
| `ram-revamped version` | The version, then the tmux version |
| `ram-revamped help` | The help page; `man ram-revamped` documents the same commands and settings |
| `ram-revamped` | On a terminal, a menu |

## Configuration

Every option is also a command option with dashes, such as `--interval 2`, and an environment variable, such as `RAM_REVAMPED_INTERVAL`; the command line wins over the environment, and the environment over the tmux option. An empty tmux option means its default. `doctor` names any setting that holds a value the plugin does not know. One given to `apply` rides on the popup key and on every status call.

### Sampling

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@ram_revamped_interval` | `5` | Seconds a sample stays fresh |
| `@ram_revamped_detail_interval` | `60` | Seconds the pressure and the top process stay fresh |
| `@ram_revamped_render` | `jobs` | `options` reads published options instead of running `#()` calls; any other value means `jobs` |
| `@ram_revamped_history_size` | `30` | Samples kept for the sparkline and the trend |
| `@ram_revamped_enable_logging` | unset | `1` writes a sample that found no figures to `~/.tmux/ram-revamped-logs/`; a tmux option only |

### Tiers and warnings

| Option | Default | Meaning |
|:-------|:--------|:--------|
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
| `@ram_revamped_swap_warn_thresh` | `1` | Swap percent at which the swap warning shows |
| `@ram_revamped_swap_active_icon` | empty | Icon that `#{ram_swap_icon}` shows |
| `@ram_revamped_swap_active_color` | empty | Style that `#{ram_swap_color}` shows |
| `@ram_revamped_trend_threshold` | `3` | Percentage points of change before the trend arrow leaves `→` |
| `@ram_revamped_trend_up` | `↑` | Rising trend glyph |
| `@ram_revamped_trend_down` | `↓` | Falling trend glyph |
| `@ram_revamped_trend_flat` | `→` | Steady trend glyph |

### Formats and labels

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@ram_revamped_percentage_format` | `%s%%` | printf format for used memory |
| `@ram_revamped_available_format` | `%s%%` | printf format for available memory |
| `@ram_revamped_swap_format` | `%s%%` | printf format for swap |
| `@ram_revamped_pressure_format` | `%s%%` | printf format for pressure |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | printf format for the four breakdown values |
| `@ram_revamped_absolute_format` | `%s / %s` | printf format for used and total |
| `@ram_revamped_commit_format` | `%s%%` | printf format for the commit ratio |
| `@ram_revamped_reclaimable_format` | `%s` | printf format for the reclaimable size |
| `@ram_revamped_top_process_format` | `%s %s` | printf format for the process name and size |
| `@ram_revamped_icons` | `ascii` | `nerd` labels every value with a Nerd Font glyph |
| `@ram_revamped_<metric>_label` | empty | Text printed before one value, only when the value is not empty |
| `@ram_revamped_fixed_width` | `off` | `on` pads percentages to 4 characters, so a change from `9%` to `42%` does not shift the status line |
| `@ram_revamped_<metric>_width` | empty | Pad one value to this many characters. A longer value is never cut |

### Popup

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@ram_revamped_popup_key` | `M-r` | Prefix key that opens the detail popup. `off` binds nothing |
| `@ram_revamped_popup_width` | `80%` | Popup width |
| `@ram_revamped_popup_height` | `60%` | Popup height |

### Internal state

The plugin writes these options itself. Do not set them.

| Option | Holds |
|:-------|:------|
| `@ram_revamped_published` | The metrics the status line uses, recorded at load so options mode writes only those |
| `@ram_revamped_history` | The recent used-memory samples behind `#{ram_graph}` and `#{ram_trend}` |
| `@ram_revamped_out_<metric>` | The rendered value of each metric in options mode |
| `@ram_revamped_ticker_pid` | The process id of the options-mode background process |
| `@ram_revamped_percent` and the other figures, `_ts`, `_lock` | The stored sample, the time of each reading and the refresh lock |

## Key bindings

| Key | Action | Default |
|:----|:-------|:--------|
| `prefix + M-r` | Opens a memory monitor in a popup: btop, else htop, else the system's own figures | Bound |

`@ram_revamped_popup_key` names another key, and `off` binds none. The default key is left alone when something else already holds it, and `ram-revamped doctor` says so.

<a id="how-it-works"></a>

## How it works

[`ram-revamped.tmux`](ram-revamped.tmux) runs once when tmux loads the plugin. It records which metrics `status-left` and `status-right` use in `@ram_revamped_published`, then replaces each placeholder with a call to [`bin/ram-revamped`](bin/ram-revamped) or, in `options` mode, with an option read and starts the background process.

In the default mode, each `#()` call returns the stored sample at once. When the sample is older than its interval, the call starts a refresh in the background and takes a lock, so only one refresh runs at a time. A sample is one read of `vm_stat` and `sysctl` on macOS, or of `/proc/meminfo` on Linux, turned into every figure by one `awk` and written in one tmux call. The pressure on Linux and the top process cost one more read each, so they run only for a placeholder the status line uses, every `@ram_revamped_detail_interval` seconds.

The pressure means different things on the two systems: on Linux it is the ten second average of `/proc/pressure/memory`, the share of time some task waited for memory, and on macOS it is the share of pages that are wired or held by the compressor. The breakdown is wired, compressed, inactive and free on macOS, and buffers, zero, cached and free on Linux.

The name of the top process comes from `ps`, which any user controls, so every `#` in it is doubled before it reaches the status line. The readers, the sampling and the formatting live in [`lib/ram.sh`](lib/ram.sh), and the settings table in [`lib/state.sh`](lib/state.sh).

<a id="screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="ram-revamped: The memory in use with its tier icon and colour, the memory available and the swap warning"><br><sub>The memory in use with its tier icon and colour, the memory available and the swap warning, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="ram-revamped: prefix M-r opens a memory monitor in a popup"><br><sub><code>prefix M-r</code> opens a memory monitor in a popup, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="ram-revamped: @ram_revamped_icons set to nerd labels every metric with a glyph"><br><sub><code>@ram_revamped_icons</code> set to <code>nerd</code> labels every metric with a glyph, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="ram-revamped: The graph, the trend and the text line"><br><sub>The graph, the trend and the text line, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="ram-revamped: In the options render mode each placeholder reads a tmux option"><br><sub>In the <code>options</code> render mode each placeholder reads a tmux option, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="ram-revamped: card prints every figure"><br><sub><code>card</code> prints every figure, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/details.png" alt="ram-revamped: Used of total, the pressure in its tier colour, the reclaimable size and the top process"><br><sub>Used of total, the pressure in its tier colour, the reclaimable size and the top process, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/breakdown.png" alt="ram-revamped: The breakdown and the commit ratio"><br><sub>The breakdown and the commit ratio, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/format.png" alt="ram-revamped: @ram_revamped_percentage_format shapes the used percent"><br><sub><code>@ram_revamped_percentage_format</code> shapes the used percent, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="ram-revamped: @ram_revamped_fixed_width pads the percents to four characters"><br><sub><code>@ram_revamped_fixed_width</code> pads the percents to four characters, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="ram-revamped: A label of its own before one metric"><br><sub>A label of its own before one metric, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="ram-revamped: @ram_revamped_medium_thresh and @ram_revamped_high_thresh move the tiers"><br><sub><code>@ram_revamped_medium_thresh</code> and <code>@ram_revamped_high_thresh</code> move the tiers, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="ram-revamped: @ram_revamped_popup_key names another key for the popup"><br><sub><code>@ram_revamped_popup_key</code> names another key for the popup, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="ram-revamped: status text and status graph print one placeholder each"><br><sub><code>status text</code> and <code>status graph</code> print one placeholder each, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="ram-revamped: refresh samples the memory now"><br><sub><code>refresh</code> samples the memory now, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="ram-revamped: list prints every binding"><br><sub><code>list</code> prints every binding, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="ram-revamped: list --json prints the same plan as one object"><br><sub><code>list --json</code> prints the same plan as one object, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="ram-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="ram-revamped: The menu"><br><sub>The menu, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="ram-revamped: The card from the menu"><br><sub>The card from the menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="ram-revamped: An accent from RAM_REVAMPED_ACCENT"><br><sub>An accent from <code>RAM_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="ram-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="ram-revamped: doctor from the menu, without gum"><br><sub><code>doctor</code> from the menu, without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="ram-revamped: card without gum"><br><sub><code>card</code> without gum, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="ram-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="ram-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="ram-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="ram-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
</tr>
</table>

The recordings run the real plugin and tmux. Small scripts stand in for `vm_stat`, `sysctl` and `ps`, so the figures on screen are theirs.

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:------|:-------|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-------|:-------|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:--------|:-------------|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh` |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

On macOS, `brew bundle` installs every tool these targets call, from the [`Brewfile`](Brewfile).

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

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
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **this plugin**, RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->
