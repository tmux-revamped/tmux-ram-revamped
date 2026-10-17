<div align="center">

# tmux-ram-revamped

<strong>在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待。</strong>

[English](README.md) | [日本語](README.ja.md) | 简体中文 | [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">功能</a> |
  <a href="#installation">安装</a> |
  <a href="#usage">用法</a> |
  <a href="#configuration">配置</a> |
  <a href="#key-bindings">按键绑定</a> |
  <a href="#how-it-works">工作原理</a>
</p>

</div>

**18 个占位符。每 5 秒采样一次，较慢的详细指标每 60 秒采样一次。只用系统自带的工具。已在 macOS 和 Linux 上测试。**

---

<a id="what-it-does"></a>

## 功能

插件把内存数据放进状态栏：已用和可用内存、交换空间、内存压力、内存构成、占用最多的进程，以及最近用量的火花线。状态栏读取 tmux 已经保存的值，下一次采样由后台进程完成。`prefix + M-r` 会在弹出窗口中打开内存监视器。

## 环境要求

| 项目 | 版本或说明 |
|:------------|:----------------|
| tmux | 3.2 或更高版本 |
| bash | 3.2 或更高版本，因此 macOS 自带的 `/bin/bash` 可以使用 |
| 操作系统 | Apple Silicon 和 Intel 上的 macOS，x86_64 和 arm64 上的 Linux |
| 核心工具 | BSD、GNU 或 uutils coreutils |
| 内存数据来源 | macOS 上为 `vm_stat` 和 `sysctl`，Linux 上为 `/proc/meminfo` 和 `/proc/pressure/memory` |
| `btop` 或 `htop` | 可选，用于详情弹窗 |

<a id="installation"></a>

## 安装

使用 [TPM](https://github.com/tmux-plugins/tpm) 时，把插件和占位符加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

不使用 TPM 时，克隆仓库，并在 `~/.tmux.conf` 中设置 `status-right` 的那一行之后运行入口脚本：

```sh
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

<a id="usage"></a>

## 用法

把以下任意占位符放进 `status-left` 或 `status-right`。数据来源缺失的占位符不显示任何内容。

| 占位符 | 输出 |
|:------------|:-------|
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
| `#{ram_commit}` | 已提交内存与提交上限之比，仅限 Linux |
| `#{ram_reclaimable}` | 页缓存、缓冲区和可回收 slab 之和，仅限 Linux，例如 `4.0G` |
| `#{ram_top_process}` | 常驻内存最大的进程，例如 `firefox 1.2G` |
| `#{ram_graph}` | 最近采样的火花线，例如 `▁▂▄▆█` |
| `#{ram_trend}` | 历史窗口内的 `↑`、`↓` 或 `→` |
| `#{ram_text}` | 供屏幕阅读器使用的纯文本行，例如 `RAM 61% used, 40% available, swap 3%` |

一个更完整的状态栏，在末尾重置样式：

```tmux
set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] #{ram_graph}'
```

插件还可以在 shell 中响应两条命令：`~/.tmux/plugins/tmux-ram-revamped/src/ram.sh doctor` 报告平台和找到的数据来源，`ram.sh popup` 打开监视器。

<a id="configuration"></a>

## 配置

在插件加载之前于 `~/.tmux.conf` 中设置选项。

| 选项 | 默认值 | 含义 |
|:-------|:--------|:--------|
| `@ram_revamped_interval` | `5` | 采样值保持有效的秒数 |
| `@ram_revamped_detail_interval` | `60` | 压力、构成、绝对值、提交、可回收和最大进程等数值保持有效的秒数 |
| `@ram_revamped_render` | 未设置 | `options` 把每个占位符变成选项读取，由每个服务器一个后台进程写入 |
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
| `@ram_revamped_percentage_format` | `%s%%` | 已用内存的 printf 格式 |
| `@ram_revamped_available_format` | `%s%%` | 可用内存的 printf 格式 |
| `@ram_revamped_swap_format` | `%s%%` | 交换空间的 printf 格式 |
| `@ram_revamped_pressure_format` | `%s%%` | 内存压力的 printf 格式 |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | 内存构成四个值的 printf 格式 |
| `@ram_revamped_absolute_format` | `%s / %s` | 已用与总量的 printf 格式 |
| `@ram_revamped_commit_format` | `%s%%` | 提交比例的 printf 格式 |
| `@ram_revamped_reclaimable_format` | `%s` | 可回收大小的 printf 格式 |
| `@ram_revamped_top_process_format` | `%s %s` | 进程名和大小的 printf 格式 |
| `@ram_revamped_history_size` | `30` | 为火花线和趋势保留的采样数 |
| `@ram_revamped_trend_threshold` | `3` | 趋势箭头离开 `→` 所需的变化，单位为百分点 |
| `@ram_revamped_trend_up` | `↑` | 上升趋势的符号 |
| `@ram_revamped_trend_down` | `↓` | 下降趋势的符号 |
| `@ram_revamped_trend_flat` | `→` | 平稳趋势的符号 |
| `@ram_revamped_swap_warn_thresh` | `1` | 显示交换空间警告的百分比 |
| `@ram_revamped_swap_active_icon` | 空 | `#{ram_swap_icon}` 显示的图标 |
| `@ram_revamped_swap_active_color` | 空 | `#{ram_swap_color}` 显示的样式 |
| `@ram_revamped_icons` | `ascii` | `nerd` 为每个值加上 Nerd Font 符号标签 |
| `@ram_revamped_<metric>_label` | 未设置 | 显示在某个值之前的文本，仅当该值非空时显示。`''` 去掉该值的 Nerd Font 标签 |
| `@ram_revamped_fixed_width` | `off` | `on` 把百分比补齐到 4 个字符，从 `9%` 变为 `42%` 时状态栏不会移动 |
| `@ram_revamped_<metric>_width` | 未设置 | 把某个值补齐到此字符数。较长的值不会被截断 |
| `@ram_revamped_popup_key` | `M-r` | 打开详情弹窗的前缀键。`off` 不绑定任何键 |
| `@ram_revamped_popup_width` | `80%` | 弹窗宽度 |
| `@ram_revamped_popup_height` | `60%` | 弹窗高度 |
| `@ram_revamped_enable_logging` | `0` | `1` 把错误写入 `~/.tmux/ram-revamped-logs/` |

`<metric>` 为 `percentage`、`available`、`swap`、`pressure`、`breakdown`、`absolute`、`commit`、`reclaimable`、`top_process`、`graph` 和 `trend` 之一。

<details>
<summary><strong>常见主题的档位颜色</strong></summary>

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

### 内部状态

以下选项由插件自行管理，请勿设置。

| 选项 | 内容 |
|:-------|:------|
| `@ram_revamped_published` | 状态栏用到的指标，在加载时记录，使选项模式只写入这些指标 |
| `@ram_revamped_history` | `#{ram_graph}` 和 `#{ram_trend}` 所用的最近已用内存采样 |
| `@ram_revamped_out_<metric>` | 选项模式下每个指标渲染后的值 |
| `@ram_revamped_ticker_pid` | 选项模式后台进程的进程 ID |
| `@ram_revamped_option_names` | 该进程每轮用一次 tmux 调用读取的选项 |
| `@ram_revamped_percent` 及其他采样值 | 缓存的读数，每个都带有 `_ts` 时间戳 |

<a id="key-bindings"></a>

## 按键绑定

| 按键 | 作用 | 选项 |
|:----|:-------|:-------|
| `prefix + M-r` | 打开详情弹窗 | `@ram_revamped_popup_key` |

`M-r` 是 tmux-revamped 家族分配给本插件的唯一按键。2.0.0 之前，弹窗位于 `prefix + M`，tmux 把这个键用于清除已标记的窗格。要保留旧按键：

```tmux
set -g @ram_revamped_popup_key 'M'
```

弹窗在安装了 `btop` 或 `htop` 时运行它们，否则在 macOS 上运行 `vm_stat 1`，在 Linux 上运行 `free -h -s 1`。

<a id="how-it-works"></a>

## 工作原理

**作业模式，即默认模式。** 入口脚本把每个占位符替换为调用 [`src/ram.sh`](src/ram.sh) 的 `#()`。这个调用立即输出缓存的值。当缓存比 `@ram_revamped_interval` 更旧时，它还会启动一个分离的进程，采集新样本并存入 tmux 选项。一个锁选项防止在采样进行时启动第二个采样进程。

**选项模式。** tmux 每次重绘都会重新运行所有 `#()`，当多个插件共用状态栏时，这可能达到大约每秒一次。把 `@ram_revamped_render` 设为 `options` 后，每个占位符都变成类似 `#{E:@ram_revamped_out_percentage}` 的读取。每个服务器一个后台进程每 `@ram_revamped_interval` 秒采样一次，用一次 tmux 调用写入状态栏用到的所有值，并只刷新客户端一次。服务器停止时它退出，重新加载配置时它被替换。

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

**数据从哪里来。**

| 数值 | macOS | Linux |
|:-------|:------|:------|
| 已用 | `vm_stat` 中 active、wired 和 compressed 的页面 | `/proc/meminfo` 中 `MemTotal` 减去 `MemAvailable` |
| 可用 | free、inactive 和 speculative 的页面 | `MemAvailable` |
| 交换空间 | `sysctl vm.swapusage` | `SwapTotal` 和 `SwapFree` |
| 压力 | wired 和 compressed 页面占全部页面的比例 | `/proc/pressure/memory` 中的 `some avg10`，即最近 10 秒内因等待内存而停顿的时间比例 |
| 构成 | wired、compressed、inactive 和 free | 同样四个位置依次为缓冲区、`0`、缓存和 free |
| 最大进程 | `ps axo rss=,comm=` | `ps axo rss=,comm=` |

进程名来自 `ps`，机器上的任何用户都能控制它，因此在 tmux 将其作为格式读取之前，名称中的每个 `#` 都会被加倍。数字在 C 区域设置下格式化，所以使用逗号作小数点的区域设置仍然显示 `1.5G`。

<details>
<summary><strong>Nerd Font 标签</strong></summary>

```tmux
set -g @ram_revamped_icons 'nerd'
set -g @ram_revamped_percentage_label ''
```

| 指标 | 符号 |
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

## 开发

| 命令 | 作用 |
|:--------|:-------------|
| `make test` | 运行 bats 测试套件 |
| `make lint` | 对所有 shell 文件运行 shellcheck |
| `make coverage` | 用 kcov 测量行覆盖率，低于 95% 时失败，在 Linux 上运行 |

测试套件需要 `bats-core` 和 tmux。

## 许可证

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中的同一份约定、`family/` 下的同一套工具和同一个共享库，并由校验和清单保证逐字节一致。这些成员可以一起安装：任何成员都不会占用其他成员使用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。这项义务写在约定里，而不是靠记忆，`family/bin/sweep` 负责执行它。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **本插件**，在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

### 检查安装

所有成员都在磁盘上时，一条命令即可报告它们之间的任何冲突：

```sh
family/bin/doctor --live
```

它读取每个成员和正在运行的 tmux 服务器，报告重复的按键、重复的状态占位符、不符合命名规则的选项，以及约定版本落后的成员。

<!-- family:end -->
