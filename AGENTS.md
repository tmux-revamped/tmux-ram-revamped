# tmux-ram-revamped

Guidance for anyone, human or agent, changing tmux-ram-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-ram-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`ram-revamped.tmux`](ram-revamped.tmux) | The entry point TPM runs: it runs `bin/ram-revamped apply` |
| [`bin/ram-revamped`](bin/ram-revamped) | The command: `apply`, `list`, `status`, `refresh`, `card`, `popup`, `daemon`, `doctor`, `version`, `help` and the menu. `apply`, `status`, `popup` and `daemon` run without loading the interface modules |
| [`lib/ram.sh`](lib/ram.sh) | Reading the settings and the stored sample, the readers for both systems, the figures, the placeholders with their labels and widths, the publisher's tick, the popup and the binding |
| [`lib/state.sh`](lib/state.sh) | Every global, including `RAM_REVAMPED_SETTINGS`, the table of setting names and defaults, `RAM_REVAMPED_LIVE`, the names of the options that hold the sample, and `RAM_REVAMPED_KINDS` |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/readers.bats`](test/readers.bats), [`test/ram.bats`](test/ram.bats), [`test/plan.bats`](test/plan.bats), [`test/commands.bats`](test/commands.bats) | The readers on both systems, every placeholder with its labels and widths, the binding with both render modes, the daemon and the popup, and every command, against a stand-in tmux from [`test/ram_helpers.bash`](test/ram_helpers.bash) that keeps options in a file, with stand-ins for `vm_stat`, `sysctl` and `ps` and a `cat` that serves the two files under `/proc` |
| [`test/entrypoint.bats`](test/entrypoint.bats), [`test/keys.bats`](test/keys.bats) | The plugin on a private tmux server, with the popup key pressed through a second tmux attached to it, in both render modes; both share [`test/server_helpers.bash`](test/server_helpers.bash), whose stand-ins give the same figures on macOS and Linux |
| [`screens/`](screens) | The tapes and the recording's tmux config. `prepare.sh` copies the plugin to a neutral folder and writes stand-ins for `vm_stat`, `sysctl` and `ps` |
| [`examples/`](examples) | A status line to copy |

## Names

- Settings are the tmux options `@ram_revamped_<setting>` listed in `RAM_REVAMPED_SETTINGS`, the long options with dashes, such as `--top-process-label`, and the environment variables `RAM_REVAMPED_<SETTING>`.
- `@ram_revamped_enable_logging` is read as a tmux option only, by the shared log module.
- The stored sample is `@ram_revamped_percent`, `_available`, `_swap`, `_pressure`, `_breakdown`, `_absolute`, `_commit`, `_reclaimable`, `_top_process` and `_history`, with `_percent_ts`, `_pressure_ts`, `_top_process_ts`, `_percent_lock` and `_percent_lock_ts`. `apply` writes `@ram_revamped_published`, the daemon `@ram_revamped_out_<name>` and `@ram_revamped_ticker_pid`. None of them is a setting.
- The placeholders are `#{ram_percentage}`, `#{ram_icon}`, `#{ram_fg_color}`, `#{ram_bg_color}`, `#{ram_available}`, `#{ram_swap}`, `#{ram_swap_icon}`, `#{ram_swap_color}`, `#{ram_pressure}`, `#{ram_pressure_fg_color}`, `#{ram_breakdown}`, `#{ram_absolute}`, `#{ram_commit}`, `#{ram_reclaimable}`, `#{ram_top_process}`, `#{ram_graph}`, `#{ram_trend}` and `#{ram_text}`; `status` names each one without the `ram_`.
- The version constant is `RAM_REVAMPED_VERSION`.
- The command's own functions and the library's never share a name, because the command is sourced after the library and would replace it.

## Behaviour

- `apply` reads every setting and the stored sample with one `tmux display-message` call and one `env` read, reads the prefix table once, and sends the binding and the replaced status strings in one tmux call. When that call fails, it sends each command alone and `apply` exits 1.
- In `jobs` mode each placeholder in `status-left` or `status-right` becomes `#(<tool> status <name>)`, with the tool's path and every carried value quoted for a shell and every `#` and `%` doubled, since tmux reads the status line as a format and as a time format. In `options` mode it becomes `#{E:@ram_revamped_out_<name>}`, `apply` starts the daemon, and a status refresh starts no process. A render mode other than `options` means `jobs`. A string already rewritten is not written again, and the names it uses stay in `@ram_revamped_published`, so loading twice changes nothing.
- `status` makes one tmux read and one `date` call, and prints the stored sample at once. Only when the sample is older than `@ram_revamped_interval`, and no sample is under way, does it start one in the background through the shared cache module.
- A sample reads the memory once, turns it into every figure with one `awk`, and writes everything in one tmux call. The pressure and the top process are read only for a placeholder in `@ram_revamped_published`, or the one `status` was asked for, and only when older than `@ram_revamped_detail_interval`; `card` reads them all.
- The daemon is the shared ticker: it claims `@ram_revamped_ticker_pid`, samples and publishes every name in `@ram_revamped_published` in one tmux call per tick, sleeps for the interval, and ends when another process holds the claim or the server is gone. At the ticker's tick cap it starts itself again.
- `M-r` opens a monitor in a popup of `@ram_revamped_popup_width` by `@ram_revamped_popup_height`: `btop`, else `htop`, else `vm_stat 1` on macOS, else `free -h -s 1`, else `/proc/meminfo` until Enter. On a tmux older than 3.2 the monitor opens in a window named `ram`. `popup` returns 0 whatever the monitor returns, so ending `vm_stat 1` with Ctrl-C leaves no `returned 2` over the pane.
- A key set to `off` binds nothing. Only the default key is skipped when someone else holds it, and `doctor` names it; a key the person names is bound whoever holds it.
- A setting `apply` got from the command line or the environment rides, as an option, on the popup key and on every status call; `RAM_REVAMPED_CARRIED` lists the ones that ride. The daemon inherits the environment of the `apply` that started it.

## Domain rules

- macOS reads `vm_stat` and `sysctl vm.swapusage`; Linux reads `/proc/meminfo` and `/proc/pressure/memory`. The page size comes from the header of `vm_stat`, else `sysctl -n hw.pagesize`, else 4096 bytes.
- Used memory is active, wired and compressed pages over all six page counts on macOS, and total less available over total on Linux, never below zero. A source that gives no total stores every figure empty, and with `@ram_revamped_enable_logging` at `1` the sample is written to the log.
- The pressure is the wired and compressed share on macOS and the ten second `some` average of the pressure file on Linux. The breakdown is wired, compressed, inactive and free on macOS, and buffers, zero, cached and free on Linux, each cut to whole megabytes before it becomes gigabytes with one decimal.
- `#{ram_reclaimable}` is cached, buffers and reclaimable slab on Linux, and purgeable plus file-backed pages on macOS.
- Sizes are printed in the largest of K, M and G that keeps the number at one or more, whole when it is whole, else with one decimal. A `ps` that writes sizes with an `m` or `g`, as BusyBox does, is read in kilobytes.
- The top process is the row of `ps axo rss=,comm=` with the most resident memory, stored as its size and its whole name. The name comes from outside, so each `#` in it is doubled when a placeholder prints it; `card` prints it as read.
- Each sample with a figure joins `@ram_revamped_history`, which keeps the newest `@ram_revamped_history_size` samples; zero or junk there means 30. The graph draws one of eight bars per sample, and the trend compares the newest sample with the oldest against `@ram_revamped_trend_threshold`.
- The tier of a value is high from `@ram_revamped_high_thresh`, medium from `@ram_revamped_medium_thresh`, else low; the icon and the colours follow the used memory, and `#{ram_pressure_fg_color}` follows the pressure with the same thresholds. The colour, icon and text placeholders are never labelled or padded.
- A label is printed only before a value. In the `nerd` set each labelled metric gets its glyph unless its own label is set; an empty tmux option means its default, so a label set to nothing keeps the glyph.
- A value is padded on the left to its own `_width`, else, with `@ram_revamped_fixed_width` at `on`, the used, available and swap percents to four characters. Width counts characters, and a longer value is never cut.
- An argument that ends in `;` is sent as `\;`: tmux reads a bare trailing semicolon in an argument as a command separator. The command list keeps an empty argument as the marker in `RAM_REVAMPED_EMPTY`; only an empty line ends a command.

## Release

- `RAM_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-19:

- `#{ram_commit}` works on Linux only: macOS keeps no commit limit to read, and `doctor` says so.
- No `@ram_revamped_notify` for the out-of-memory warning yet.
