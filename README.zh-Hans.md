<div align="center">

# tmux-ram-revamped

<strong>在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-ram-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-ram-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-ram-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-ram-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-ram-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-ram-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#工作原理">工作原理</a> &nbsp;|&nbsp;
  <a href="#界面">界面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="ram-revamped 按档位颜色显示已用内存，打开监视器弹窗，并切换到 Nerd Font 标签、图表和 options 渲染模式" width="800">
</p>

```console
$ ram-revamped refresh
Refreshed. 88% of the memory is in use.
$ ram-revamped status text
RAM 88% used, 12% available, swap 75%
```

**18** 个占位符，**2** 种渲染模式，支持 macOS 和 Linux，需要 tmux **3.2** 或更高版本。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或更高 | 家族的最低版本，弹窗也需要它 |
| btop, htop | 可选 | 弹窗打开的监视器；没有时在 macOS 上显示 `vm_stat 1`，在 Linux 上显示 `free -h -s 1` |
| gum | 可选 | `ram-revamped` 的菜单、表格和颜色；没有它时所有命令输出纯文本 |

它在 Linux 和 macOS 上运行，BSD、GNU、uutils 或 BusyBox 工具均可。每个数值都来自系统自带的来源：

| 数值 | macOS | Linux |
|:-----|:------|:------|
| 已用、可用、构成、大小 | `vm_stat` | `/proc/meminfo` |
| 交换空间 | `sysctl vm.swapusage` | `/proc/meminfo` |
| 内存压力 | `vm_stat` 的 wired 和压缩页面 | `/proc/pressure/memory` |
| 提交比例 | 无：macOS 没有提交上限 | `/proc/meminfo` |
| 可回收 | `vm_stat` 的 purgeable 和文件支持页面 | `/proc/meminfo` 的缓存、缓冲区和可回收 slab |
| 最大进程 | `ps` | `ps` |

缺少来源时，对应的占位符为空，`ram-revamped doctor` 会指出是哪一个。

### 安装

使用 [TPM](https://github.com/tmux-plugins/tpm) 时，把插件加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
```

手动安装时，克隆仓库，并在 `~/.tmux.conf` 中运行入口脚本：

```bash
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

请在插件加载之前设置 `status-left` 或 `status-right`。插件只在加载时替换一次其中的占位符。

在克隆的目录中运行 `make install`，还会把 `ram-revamped` 放进 `~/.local/bin`，把它的 man 手册和补全放在 `~/.local/share` 下。

### 验证

```bash
~/.tmux/plugins/tmux-ram-revamped/bin/ram-revamped doctor
```

## 用法

本插件显示已用内存，以及可用内存、交换空间、内存压力、内存构成、最大进程和最近采样的图表。状态栏显示 tmux 已经保存的值，后台采样负责更新它。

| 占位符 | 输出 |
|:-------|:-----|
| `#{ram_percentage}` | 已用内存，例如 `61%` |
| `#{ram_icon}` | 已用内存所处档位的图标 |
| `#{ram_fg_color}` | 已用内存档位的前景样式 |
| `#{ram_bg_color}` | 已用内存档位的背景样式 |
| `#{ram_available}` | 可用内存，例如 `40%` |
| `#{ram_swap}` | 已用交换空间，没有交换空间时为空 |
| `#{ram_swap_icon}` | 交换空间用量达到阈值时显示的警告图标 |
| `#{ram_swap_color}` | 交换空间用量达到阈值时显示的警告样式 |
| `#{ram_pressure}` | 内存压力，例如 `36%`。数值越高压力越大 |
| `#{ram_pressure_fg_color}` | 内存压力的前景样式，使用与已用内存相同的阈值 |
| `#{ram_breakdown}` | 以 GB 为单位的内存构成，例如 `W 3.2G C 1.1G I 2.0G F 4.5G` |
| `#{ram_absolute}` | 已用与总量，例如 `12.3G / 32G` |
| `#{ram_commit}` | 已提交内存与提交上限之比；macOS 没有提交上限，因此为空 |
| `#{ram_reclaimable}` | 在 Linux 上是页缓存、缓冲区和可回收 slab 之和，在 macOS 上是 purgeable 与文件支持页面之和，例如 `4.0G` |
| `#{ram_top_process}` | 常驻内存最大的进程，例如 `firefox 1.2G` |
| `#{ram_graph}` | 最近采样的火花线，例如 `▁▂▄▆█` |
| `#{ram_trend}` | 历史窗口内的 `↑`、`↓` 或 `→` |
| `#{ram_text}` | 供屏幕阅读器使用的纯文本行，例如 `RAM 61% used, 40% available, swap 3%` |

把占位符放进状态栏：

```tmux
set -g @ram_revamped_low_fg_color '#[fg=green]'
set -g @ram_revamped_medium_fg_color '#[fg=yellow]'
set -g @ram_revamped_high_fg_color '#[fg=red]'

set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] '
```

同样的示例见 [examples/status-right.tmux.conf](examples/status-right.tmux.conf)。

### 标签和宽度

`@ram_revamped_<metric>_label` 在某个指标之前显示图标或文字，仅当该值非空时显示。把 `@ram_revamped_icons` 设为 `nerd` 会为下面每个指标加上 Nerd Font 符号标签。指标自己的标签优先于这一套符号，设为空的标签表示默认值，所以符号保留。默认的 `ascii` 不加标签。

| 指标 | `nerd` 图标 |
|:-----|:------------|
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

把 `@ram_revamped_fixed_width` 设为 `on` 会把已用、可用和交换空间的百分比在左侧补齐到 4 个字符，从 `9%` 变为 `42%` 时状态栏的其余部分不会移动。`@ram_revamped_<metric>_width` 设置某个指标的宽度，并优先于固定宽度。较长的值不会被截断。

### 渲染模式

默认情况下，每个占位符会变成一个 `#()` 调用，tmux 每次重绘状态栏时都会重新运行它。把 `@ram_revamped_render` 设为 `options` 后，每个占位符会变成读取选项，例如 `#{E:@ram_revamped_out_percentage}`。每个服务器只有一个后台进程，每 `@ram_revamped_interval` 秒采样一次，并在一次 tmux 调用中写入所有值，所以这些值会同时更新。

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

### 档位颜色

档位样式默认为空，所以在设置之前 `#{ram_fg_color}`、`#{ram_bg_color}` 和 `#{ram_pressure_fg_color}` 不输出任何内容。下面的配色把低用量对应绿色，中等对应黄色，高用量对应红色：

| 主题 | 低 | 中 | 高 |
|:-----|:---|:---|:---|
| Catppuccin Mocha | `#a6e3a1` | `#f9e2af` | `#f38ba8` |
| Dracula | `#50fa7b` | `#f1fa8c` | `#ff5555` |
| Nord | `#a3be8c` | `#ebcb8b` | `#bf616a` |
| Gruvbox Dark | `#b8bb26` | `#fabd2f` | `#fb4934` |
| Tokyo Night | `#9ece6a` | `#e0af68` | `#f7768e` |
| Solarized Dark | `#859900` | `#b58900` | `#dc322f` |

每个值都写成样式，例如 `set -g @ram_revamped_low_fg_color '#[fg=#a6e3a1]'`。

| 命令 | 作用 |
|:--------|:-------------|
| `ram-revamped apply` | 绑定弹窗按键并立即替换占位符；tmux 加载插件时入口脚本会运行它 |
| `ram-revamped list` | 显示 `apply` 将发送的每条命令，不做任何更改；`--json` 输出一个对象 |
| `ram-revamped status NAME` | 输出一个占位符，例如 `percentage`、`swap` 或 `graph`；状态栏会运行它 |
| `ram-revamped refresh` | 立即采样内存，并说明已用多少 |
| `ram-revamped card` | 立即读取全部数值，每个数值显示一行 |
| `ram-revamped popup` | 在 tmux 弹窗中打开内存监视器：btop，没有则 htop，再没有则显示系统自带的数值；弹窗按键会运行它 |
| `ram-revamped daemon` | 为 `options` 渲染模式在每个周期发布占位符；`apply` 会启动它 |
| `ram-revamped doctor` | 每个依赖一行：每个数值来自的工具或文件、弹窗打开的监视器，以及未改动的按键 |
| `ram-revamped version` | 版本，以及 tmux 的版本 |
| `ram-revamped help` | 帮助页；`man ram-revamped` 记录了同样的命令和设置 |
| `ram-revamped` | 在终端上显示菜单 |

## 配置

每个选项也可以写成带连字符的命令选项，例如 `--interval 2`，或环境变量，例如 `RAM_REVAMPED_INTERVAL`；命令行优先于环境变量，环境变量优先于 tmux 选项。空的 tmux 选项表示使用默认值。`doctor` 会指出值无法识别的设置。传给 `apply` 的选项会随弹窗按键和每次状态调用一起生效。

### 采样

| 选项 | 默认值 | 含义 |
|:-----|:-------|:-----|
| `@ram_revamped_interval` | `5` | 采样值保持有效的秒数 |
| `@ram_revamped_detail_interval` | `60` | 内存压力和最大进程保持有效的秒数 |
| `@ram_revamped_render` | `jobs` | `options` 读取已发布的选项，而不是运行 `#()` 调用；其他任何值都视为 `jobs` |
| `@ram_revamped_history_size` | `30` | 为火花线和趋势保留的采样数 |
| `@ram_revamped_enable_logging` | 未设置 | `1` 把没有读到数值的采样写入 `~/.tmux/ram-revamped-logs/`；只能作为 tmux 选项设置 |

### 档位和警告

| 选项 | 默认值 | 含义 |
|:-----|:-------|:-----|
| `@ram_revamped_medium_thresh` | `50` | 档位变为 medium 的百分比 |
| `@ram_revamped_high_thresh` | `85` | 档位变为 high 的百分比 |
| `@ram_revamped_low_icon` | `▰▱▱` | low 档位的图标 |
| `@ram_revamped_medium_icon` | `▰▰▱` | medium 档位的图标 |
| `@ram_revamped_high_icon` | `▰▰▰` | high 档位的图标 |
| `@ram_revamped_low_fg_color` | 空 | low 档位的前景样式，例如 `#[fg=green]` |
| `@ram_revamped_medium_fg_color` | 空 | medium 档位的前景样式 |
| `@ram_revamped_high_fg_color` | 空 | high 档位的前景样式 |
| `@ram_revamped_low_bg_color` | 空 | low 档位的背景样式 |
| `@ram_revamped_medium_bg_color` | 空 | medium 档位的背景样式 |
| `@ram_revamped_high_bg_color` | 空 | high 档位的背景样式 |
| `@ram_revamped_swap_warn_thresh` | `1` | 显示交换空间警告的百分比 |
| `@ram_revamped_swap_active_icon` | 空 | `#{ram_swap_icon}` 显示的图标 |
| `@ram_revamped_swap_active_color` | 空 | `#{ram_swap_color}` 显示的样式 |
| `@ram_revamped_trend_threshold` | `3` | 趋势箭头离开 `→` 所需的变化，单位为百分点 |
| `@ram_revamped_trend_up` | `↑` | 上升趋势的符号 |
| `@ram_revamped_trend_down` | `↓` | 下降趋势的符号 |
| `@ram_revamped_trend_flat` | `→` | 平稳趋势的符号 |

### 格式和标签

| 选项 | 默认值 | 含义 |
|:-----|:-------|:-----|
| `@ram_revamped_percentage_format` | `%s%%` | 已用内存的 printf 格式 |
| `@ram_revamped_available_format` | `%s%%` | 可用内存的 printf 格式 |
| `@ram_revamped_swap_format` | `%s%%` | 交换空间的 printf 格式 |
| `@ram_revamped_pressure_format` | `%s%%` | 内存压力的 printf 格式 |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | 内存构成四个值的 printf 格式 |
| `@ram_revamped_absolute_format` | `%s / %s` | 已用与总量的 printf 格式 |
| `@ram_revamped_commit_format` | `%s%%` | 提交比例的 printf 格式 |
| `@ram_revamped_reclaimable_format` | `%s` | 可回收大小的 printf 格式 |
| `@ram_revamped_top_process_format` | `%s %s` | 进程名和大小的 printf 格式 |
| `@ram_revamped_icons` | `ascii` | `nerd` 为每个值加上 Nerd Font 符号标签 |
| `@ram_revamped_<metric>_label` | 空 | 显示在某个值之前的文本，仅当该值非空时显示 |
| `@ram_revamped_fixed_width` | `off` | `on` 把百分比补齐到 4 个字符，从 `9%` 变为 `42%` 时状态栏不会移动 |
| `@ram_revamped_<metric>_width` | 空 | 把某个值补齐到此字符数。较长的值不会被截断 |

### 弹窗

| 选项 | 默认值 | 含义 |
|:-----|:-------|:-----|
| `@ram_revamped_popup_key` | `M-r` | 打开详情弹窗的前缀键。`off` 不绑定任何键 |
| `@ram_revamped_popup_width` | `80%` | 弹窗宽度 |
| `@ram_revamped_popup_height` | `60%` | 弹窗高度 |

### 内部状态

以下选项由插件自己写入，请勿设置。

| 选项 | 保存内容 |
|:-----|:---------|
| `@ram_revamped_published` | 状态栏用到的指标，在加载时记录，使选项模式只写入这些指标 |
| `@ram_revamped_history` | `#{ram_graph}` 和 `#{ram_trend}` 所用的最近已用内存采样 |
| `@ram_revamped_out_<metric>` | 选项模式下每个指标渲染后的值 |
| `@ram_revamped_ticker_pid` | 选项模式后台进程的进程 ID |
| `@ram_revamped_percent` 等数值、`_ts`、`_lock` | 保存的采样、每次读取的时间和刷新锁 |

## 按键绑定

| 按键 | 动作 | 默认 |
|:-----|:-----|:-----|
| `prefix + M-r` | 在弹窗中打开内存监视器：btop，没有则 htop，再没有则显示系统自带的数值 | 已绑定 |

`@ram_revamped_popup_key` 可以指定其他按键，设为 `off` 则不绑定。默认按键已被占用时不会改动它，`ram-revamped doctor` 会说明这一点。

<a id="工作原理"></a>

## 工作原理

tmux 加载插件时，[`ram-revamped.tmux`](ram-revamped.tmux) 运行一次。它把 `status-left` 和 `status-right` 用到的指标记录在 `@ram_revamped_published` 中，然后把每个占位符替换成对 [`bin/ram-revamped`](bin/ram-revamped) 的调用；在 `options` 模式下则替换成选项读取，并启动后台进程。

在默认模式下，每个 `#()` 调用立即返回保存的采样。采样比间隔旧时，调用会取得锁并在后台开始刷新，所以同一时间只有一个刷新在运行。一次采样在 macOS 上读取一次 `vm_stat` 和 `sysctl`，在 Linux 上读取一次 `/proc/meminfo`，由一个 `awk` 算出全部数值，并用一次 tmux 调用写入。Linux 上的内存压力和最大进程各需要多读一次，所以只为状态栏用到的占位符读取，每 `@ram_revamped_detail_interval` 秒一次。

内存压力在两个系统上的含义不同：在 Linux 上是 `/proc/pressure/memory` 的 10 秒平均值，即有任务等待内存的时间比例；在 macOS 上是 wired 页面和压缩器占用页面的比例。内存构成在 macOS 上是 wired、压缩、inactive 和 free，在 Linux 上是缓冲区、0、缓存和 free。

最大进程的名称来自 `ps`，任何用户都能控制它，所以在送到状态栏之前会把其中每个 `#` 加倍。读取、采样和格式化的代码在 [`lib/ram.sh`](lib/ram.sh)，设置表在 [`lib/state.sh`](lib/state.sh)。

<a id="界面"></a>

## 界面

<details>
<summary>所有界面，在真实的 tmux 中用 <code>make screens</code> 录制，每个按键显示在状态栏上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="ram-revamped: 已用内存及其档位图标和颜色、可用内存和交换空间警告"><br><sub>已用内存及其档位图标和颜色、可用内存和交换空间警告，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="ram-revamped: prefix M-r 在弹窗中打开内存监视器"><br><sub><code>prefix M-r</code> 在弹窗中打开内存监视器，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="ram-revamped: 把 @ram_revamped_icons 设为 nerd 会为每个指标加上符号标签"><br><sub>把 <code>@ram_revamped_icons</code> 设为 <code>nerd</code> 会为每个指标加上符号标签，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="ram-revamped: 图表、趋势和文本行"><br><sub>图表、趋势和文本行，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="ram-revamped: 在 options 渲染模式下，每个占位符读取一个 tmux 选项"><br><sub>在 <code>options</code> 渲染模式下，每个占位符读取一个 tmux 选项，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="ram-revamped: card 显示每个数值"><br><sub><code>card</code> 显示每个数值，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/details.png" alt="ram-revamped: 已用与总量、带档位颜色的内存压力、可回收大小和最大进程"><br><sub>已用与总量、带档位颜色的内存压力、可回收大小和最大进程，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/breakdown.png" alt="ram-revamped: 内存构成和提交比例"><br><sub>内存构成和提交比例，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/format.png" alt="ram-revamped: @ram_revamped_percentage_format 决定已用百分比的格式"><br><sub><code>@ram_revamped_percentage_format</code> 决定已用百分比的格式，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="ram-revamped: @ram_revamped_fixed_width 把百分比补齐到 4 个字符"><br><sub><code>@ram_revamped_fixed_width</code> 把百分比补齐到 4 个字符，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="ram-revamped: 某个指标自己的标签"><br><sub>某个指标自己的标签，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="ram-revamped: @ram_revamped_medium_thresh 和 @ram_revamped_high_thresh 移动档位的界线"><br><sub><code>@ram_revamped_medium_thresh</code> 和 <code>@ram_revamped_high_thresh</code> 移动档位的界线，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="ram-revamped: @ram_revamped_popup_key 为弹窗指定另一个按键"><br><sub><code>@ram_revamped_popup_key</code> 为弹窗指定另一个按键，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="ram-revamped: status text 和 status graph 各输出一个占位符"><br><sub><code>status text</code> 和 <code>status graph</code> 各输出一个占位符，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="ram-revamped: refresh 立即采样内存"><br><sub><code>refresh</code> 立即采样内存，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="ram-revamped: list 显示每个绑定"><br><sub><code>list</code> 显示每个绑定，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="ram-revamped: list --json 把同样的内容输出为一个对象"><br><sub><code>list --json</code> 把同样的内容输出为一个对象，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="ram-revamped: doctor"><br><sub><code>doctor</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="ram-revamped: 菜单"><br><sub>菜单，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="ram-revamped: 从菜单打开的卡片"><br><sub>从菜单打开的卡片，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="ram-revamped: 来自 RAM_REVAMPED_ACCENT 的强调色"><br><sub>来自 <code>RAM_REVAMPED_ACCENT</code> 的强调色，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="ram-revamped: 没有 gum 时的菜单"><br><sub>没有 gum 时的菜单，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="ram-revamped: 没有 gum 时从菜单打开的 doctor"><br><sub>没有 gum 时从菜单打开的 <code>doctor</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="ram-revamped: 没有 gum 时的 card"><br><sub>没有 gum 时的 <code>card</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="ram-revamped: 版本"><br><sub>版本，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="ram-revamped: 未知命令"><br><sub>未知命令，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="ram-revamped: 六种主题下的标题"><br><sub>六种主题下的标题，来自 <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="ram-revamped: 帮助页"><br><sub>帮助页，来自 <code>help.tape</code></sub></td>
</tr>
</table>

录制时运行的是真实的插件和 tmux。`vm_stat`、`sysctl` 和 `ps` 由小脚本代替，所以画面上的数值来自这些脚本。

</details>

## 可移植性

插件是 POSIX `sh`。CI 在下面每一行上运行全部测试。

| Shell | 状态 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支持 |
| `bash` 3.2 和 5.x、系统自带的 `zsh` 和 Homebrew 的 `zsh` | 支持 |

| 系统 | 状态 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系统自带的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make fmt` | 对每个脚本运行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零告警 |
| `make test` | 在系统 `sh` 下运行 bats 测试 |
| `make test-all` | 在每个已安装的 shell 下运行测试，macOS 上包括 bash 和 zsh 的两种构建 |
| `make test-linux` | 在 Ubuntu 容器中运行测试 |
| `make coverage` | 在这台 Mac 和 Ubuntu 容器中运行 bashcov，合并后以 100% 为门槛 |
| `make screens` | 用 VHS 在 tmux 中从真实插件录制上面的界面，在 macOS 上运行 |
| `make install` | 把命令、man 手册和补全安装到 `PREFIX` 下 |

在 macOS 上，运行 `brew bundle` 会根据 [`Brewfile`](Brewfile) 安装这些目标用到的所有工具。

提交遵循 Conventional Commits 格式，直接进入 `main`。`main` 上的 `ci` 通过后，`release.yml` 运行 semantic-release：自上一个标签以来的每个 `feat` 或 `fix` 都会发布新版本，更新版本常量，并把说明写进 [`CHANGELOG.md`](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

这个插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中相同的约定和相同的共享库，并且设计为一起安装：没有成员占用另一个成员占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后，它会自动重新加载，无需按键，也无需命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示每个已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，从不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘用量，从不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 从屏幕上挑选 URL、路径、哈希或任意其他词元，并输入到光标处，全部用纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏中显示活动窗格的 git 分支、改动和托管平台计数，且不阻塞渲染 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏中显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏中显示当前的 Kubernetes 上下文和命名空间，不依赖 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚缓冲区或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，从不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，从不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和窗口管理按键，适配 tmux 版本，兼容 vim，每个 prefix 按键都可禁用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **本插件**，在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

<!-- family:end -->
