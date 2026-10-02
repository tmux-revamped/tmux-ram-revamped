# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Metric labels. `@ram_revamped_<metric>_label` prints an icon or word before a
  value only when the value is not empty, and `@ram_revamped_icons` set to
  `nerd` labels every metric from a Nerd Font set. The default adds no labels.

## [1.3.0] - 2026-06-29

### Added

- History sparkline `#{ram_graph}` and trend arrow `#{ram_trend}`, backed by a
  bounded ring buffer stored in a tmux user-option rather than a temp file.
- Absolute used over total `#{ram_absolute}` with auto-scaling units.
- Top memory process `#{ram_top_process}`.
- Commit ratio `#{ram_commit}` and reclaimable cache figure `#{ram_reclaimable}`
  on Linux for early OOM and cache-pressure context.
- Swap-active warning icon and color, `#{ram_swap_icon}` and `#{ram_swap_color}`.
- Glyph-free `#{ram_text}` line for screen readers and no-Nerd-Font terminals.
- Detail popup on `prefix + M` that opens a memory monitor through a mockable
  tmux seam, with a window fallback on tmux older than 3.2.
- `doctor` subcommand reporting the detected platform, sources, and tools.

## [1.2.1] - 2026-06-23

### Changed

- Reviewed the upstream `tmux-plugins/tmux-cpu` memory issues and pull requests.
  Confirmed `#{ram_percentage}` and `#{ram_breakdown}` cover the used and total
  reporting (#101), that memory is read from `/proc/meminfo` directly rather than
  parsing `free` so the GNU and BSD output difference cannot bite (#84), and that
  swap reporting is already shipped (PR #68). Load average lives in the companion
  `tmux-cpu-revamped` plugin via `#{cpu_load}`.

## [1.2.0] - 2026-06-20

### Added

- Memory-pressure placeholder `#{ram_pressure}`. On Linux it reads the
  `some avg10` value from `/proc/pressure/memory`; on macOS it reads the free
  percent from the native `memory_pressure` tool.

## [1.1.0] - 2026-06-20

### Added

- Available-memory placeholder `#{ram_available}` and swap-usage placeholder
  `#{ram_swap}`.
- Memory breakdown placeholder `#{ram_breakdown}` (wired, compressed, inactive,
  free) from vm_stat on macOS and /proc/meminfo on Linux.
- macOS swap via `sysctl vm.swapusage`, Linux swap via `/proc/meminfo`.

## [1.0.0] - 2026-06-19

### Added

- RAM usage placeholders: `#{ram_percentage}`, `#{ram_icon}`,
  `#{ram_fg_color}`, `#{ram_bg_color}`.
- Non-blocking design: usage is computed in a background worker and read from a
  tmux user-option, with no temp files.
- macOS usage from `vm_stat`, Linux usage from `/proc/meminfo`.
- Configurable thresholds, icons, colors, and format string.
