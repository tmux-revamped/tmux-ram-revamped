<div align="center">

# tmux-ram-revamped

<strong>在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待。</strong>

[English](README.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | 繁體中文（香港）

[![family](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-ram-revamped/family.yml?branch=main&style=flat-square&label=family)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/family.yml)
[![tests](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-ram-revamped/tests.yml?branch=main&style=flat-square&label=tests)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-ram-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-ram-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-ram-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-ram-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-ram-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#what-it-does">功能</a> |
  <a href="#installation">安裝</a> |
  <a href="#usage">用法</a> |
  <a href="#configuration">設定</a> |
  <a href="#key-bindings">按鍵綁定</a> |
  <a href="#how-it-works">運作原理</a>
</p>

</div>

**18 個佔位符。每 5 秒取樣一次，較慢的詳細指標每 60 秒取樣一次。只用系統內置的工具。已在 macOS 及 Linux 上測試。**

---

<a id="what-it-does"></a>

## 功能

插件把記憶體數據放進狀態列：已用及可用記憶體、交換空間、記憶體壓力、記憶體組成、佔用最多的進程，以及最近用量的走勢線。狀態列讀取 tmux 已經儲存的值，下一次取樣由背景進程完成。`prefix + M-r` 會在彈出視窗中開啟記憶體監察器。

## 系統要求

| 項目 | 版本或說明 |
|:------------|:----------------|
| tmux | 3.2 或以上 |
| bash | 3.2 或以上，因此 macOS 內置的 `/bin/bash` 可以使用 |
| 作業系統 | Apple Silicon 及 Intel 上的 macOS，x86_64 及 arm64 上的 Linux |
| 核心工具 | BSD、GNU 或 uutils coreutils |
| 記憶體數據來源 | macOS 上為 `vm_stat` 及 `sysctl`，Linux 上為 `/proc/meminfo` 及 `/proc/pressure/memory` |
| `btop` 或 `htop` | 選用，用於詳細資料彈出視窗 |

<a id="installation"></a>

## 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm) 時，把插件及佔位符加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

不使用 TPM 時，複製儲存庫，並在 `~/.tmux.conf` 中設定 `status-right` 那一行之後執行入口腳本：

```sh
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

<a id="usage"></a>

## 用法

把以下任何佔位符放進 `status-left` 或 `status-right`。數據來源缺失的佔位符不會顯示任何內容。

| 佔位符 | 輸出 |
|:------------|:-------|
| `#{ram_percentage}` | 已用記憶體，例如 `61%` |
| `#{ram_icon}` | 已用記憶體所屬級別的圖示 |
| `#{ram_fg_color}` | 已用記憶體級別的前景樣式 |
| `#{ram_bg_color}` | 已用記憶體級別的背景樣式 |
| `#{ram_available}` | 可用記憶體，例如 `40%` |
| `#{ram_swap}` | 已用交換空間，沒有交換空間時為空 |
| `#{ram_swap_icon}` | 交換空間用量達到門檻時顯示的警告圖示 |
| `#{ram_swap_color}` | 交換空間用量達到門檻時顯示的警告樣式 |
| `#{ram_pressure}` | 記憶體壓力，例如 `36%`。數值越高壓力越大 |
| `#{ram_pressure_fg_color}` | 記憶體壓力的前景樣式，使用與已用記憶體相同的門檻 |
| `#{ram_breakdown}` | 以 GB 為單位的記憶體組成，例如 `W 3.2G C 1.1G I 2.0G F 4.5G` |
| `#{ram_absolute}` | 已用與總量，例如 `12.3G / 32G` |
| `#{ram_commit}` | 已承諾記憶體與承諾上限之比，只限 Linux |
| `#{ram_reclaimable}` | 頁面快取、緩衝區及可回收 slab 之和，只限 Linux，例如 `4.0G` |
| `#{ram_top_process}` | 常駐記憶體最大的進程，例如 `firefox 1.2G` |
| `#{ram_graph}` | 最近取樣的走勢線，例如 `▁▂▄▆█` |
| `#{ram_trend}` | 紀錄範圍內的 `↑`、`↓` 或 `→` |
| `#{ram_text}` | 供螢幕閱讀器使用的純文字行，例如 `RAM 61% used, 40% available, swap 3%` |

一個更完整的狀態列，在末尾重設樣式：

```tmux
set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] #{ram_graph}'
```

插件亦可在 shell 中回應兩個指令：`~/.tmux/plugins/tmux-ram-revamped/src/ram.sh doctor` 報告平台及找到的數據來源，`ram.sh popup` 開啟監察器。

<a id="configuration"></a>

## 設定

在插件載入之前於 `~/.tmux.conf` 中設定選項。

| 選項 | 預設值 | 含義 |
|:-------|:--------|:--------|
| `@ram_revamped_interval` | `5` | 取樣值保持有效的秒數 |
| `@ram_revamped_detail_interval` | `60` | 壓力、組成、絕對值、承諾、可回收及最大進程等數值保持有效的秒數 |
| `@ram_revamped_render` | 未設定 | `options` 把每個佔位符變成選項讀取，由每個伺服器一個背景進程寫入 |
| `@ram_revamped_medium_thresh` | `50` | 級別變為 medium 的百分比 |
| `@ram_revamped_high_thresh` | `85` | 級別變為 high 的百分比 |
| `@ram_revamped_low_icon` | `▰▱▱` | low 級別的圖示 |
| `@ram_revamped_medium_icon` | `▰▰▱` | medium 級別的圖示 |
| `@ram_revamped_high_icon` | `▰▰▰` | high 級別的圖示 |
| `@ram_revamped_low_fg_color` | 空 | low 級別的前景樣式，例如 `#[fg=green]` |
| `@ram_revamped_medium_fg_color` | 空 | medium 級別的前景樣式 |
| `@ram_revamped_high_fg_color` | 空 | high 級別的前景樣式 |
| `@ram_revamped_low_bg_color` | 空 | low 級別的背景樣式 |
| `@ram_revamped_medium_bg_color` | 空 | medium 級別的背景樣式 |
| `@ram_revamped_high_bg_color` | 空 | high 級別的背景樣式 |
| `@ram_revamped_percentage_format` | `%s%%` | 已用記憶體的 printf 格式 |
| `@ram_revamped_available_format` | `%s%%` | 可用記憶體的 printf 格式 |
| `@ram_revamped_swap_format` | `%s%%` | 交換空間的 printf 格式 |
| `@ram_revamped_pressure_format` | `%s%%` | 記憶體壓力的 printf 格式 |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | 記憶體組成四個值的 printf 格式 |
| `@ram_revamped_absolute_format` | `%s / %s` | 已用與總量的 printf 格式 |
| `@ram_revamped_commit_format` | `%s%%` | 承諾比例的 printf 格式 |
| `@ram_revamped_reclaimable_format` | `%s` | 可回收大小的 printf 格式 |
| `@ram_revamped_top_process_format` | `%s %s` | 進程名稱及大小的 printf 格式 |
| `@ram_revamped_history_size` | `30` | 為走勢線及趨勢保留的取樣數目 |
| `@ram_revamped_trend_threshold` | `3` | 趨勢箭咀離開 `→` 所需的變化，以百分點計 |
| `@ram_revamped_trend_up` | `↑` | 上升趨勢的符號 |
| `@ram_revamped_trend_down` | `↓` | 下降趨勢的符號 |
| `@ram_revamped_trend_flat` | `→` | 平穩趨勢的符號 |
| `@ram_revamped_swap_warn_thresh` | `1` | 顯示交換空間警告的百分比 |
| `@ram_revamped_swap_active_icon` | 空 | `#{ram_swap_icon}` 顯示的圖示 |
| `@ram_revamped_swap_active_color` | 空 | `#{ram_swap_color}` 顯示的樣式 |
| `@ram_revamped_icons` | `ascii` | `nerd` 為每個值加上 Nerd Font 符號標籤 |
| `@ram_revamped_<metric>_label` | 未設定 | 顯示在某個值之前的文字，只在該值非空時顯示。`''` 移除該值的 Nerd Font 標籤 |
| `@ram_revamped_fixed_width` | `off` | `on` 把百分比補齊到 4 個字元，由 `9%` 變為 `42%` 時狀態列不會移位 |
| `@ram_revamped_<metric>_width` | 未設定 | 把某個值補齊到此字元數。較長的值不會被截斷 |
| `@ram_revamped_popup_key` | `M-r` | 開啟詳細資料彈出視窗的前綴鍵。`off` 不綁定任何鍵 |
| `@ram_revamped_popup_width` | `80%` | 彈出視窗闊度 |
| `@ram_revamped_popup_height` | `60%` | 彈出視窗高度 |
| `@ram_revamped_enable_logging` | `0` | `1` 把錯誤寫入 `~/.tmux/ram-revamped-logs/` |

`<metric>` 為 `percentage`、`available`、`swap`、`pressure`、`breakdown`、`absolute`、`commit`、`reclaimable`、`top_process`、`graph` 及 `trend` 之一。

<details>
<summary><strong>常見主題的級別顏色</strong></summary>

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

### 內部狀態

以下選項由插件自行管理，請勿設定。

| 選項 | 內容 |
|:-------|:------|
| `@ram_revamped_published` | 狀態列用到的指標，在載入時記錄，令選項模式只寫入這些指標 |
| `@ram_revamped_history` | `#{ram_graph}` 及 `#{ram_trend}` 所用的最近已用記憶體取樣 |
| `@ram_revamped_out_<metric>` | 選項模式下每個指標繪製後的值 |
| `@ram_revamped_ticker_pid` | 選項模式背景進程的進程 ID |
| `@ram_revamped_option_names` | 該進程每輪用一次 tmux 呼叫讀取的選項 |
| `@ram_revamped_percent` 及其他取樣值 | 快取的讀數，每個都附有 `_ts` 時間戳記 |

<a id="key-bindings"></a>

## 按鍵綁定

| 按鍵 | 作用 | 選項 |
|:----|:-------|:-------|
| `prefix + M-r` | 開啟詳細資料彈出視窗 | `@ram_revamped_popup_key` |

`M-r` 是 tmux-revamped 家族分配給本插件的唯一按鍵。2.0.0 之前，彈出視窗位於 `prefix + M`，tmux 把這個鍵用於清除已標記的窗格。如要保留舊按鍵：

```tmux
set -g @ram_revamped_popup_key 'M'
```

彈出視窗在安裝了 `btop` 或 `htop` 時執行它們，否則在 macOS 上執行 `vm_stat 1`，在 Linux 上執行 `free -h -s 1`。

<a id="how-it-works"></a>

## 運作原理

**工作模式，即預設模式。** 入口腳本把每個佔位符替換為呼叫 [`src/ram.sh`](src/ram.sh) 的 `#()`。這個呼叫會即時輸出快取的值。當快取比 `@ram_revamped_interval` 更舊時，它亦會啟動一個分離的進程，取得新樣本並存入 tmux 選項。一個鎖定選項防止在取樣進行時啟動第二個取樣進程。

**選項模式。** tmux 每次重繪都會重新執行所有 `#()`，當多個插件共用狀態列時，這可能達到大約每秒一次。把 `@ram_revamped_render` 設為 `options` 後，每個佔位符都變成類似 `#{E:@ram_revamped_out_percentage}` 的讀取。每個伺服器一個背景進程每 `@ram_revamped_interval` 秒取樣一次，用一次 tmux 呼叫寫入狀態列用到的所有值，並只更新用戶端一次。伺服器停止時它結束，重新載入設定時它會被取代。

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

**數據從何而來。**

| 數值 | macOS | Linux |
|:-------|:------|:------|
| 已用 | `vm_stat` 中 active、wired 及 compressed 的頁面 | `/proc/meminfo` 中 `MemTotal` 減去 `MemAvailable` |
| 可用 | free、inactive 及 speculative 的頁面 | `MemAvailable` |
| 交換空間 | `sysctl vm.swapusage` | `SwapTotal` 及 `SwapFree` |
| 壓力 | wired 及 compressed 頁面佔全部頁面的比例 | `/proc/pressure/memory` 中的 `some avg10`，即最近 10 秒內因等待記憶體而停頓的時間比例 |
| 組成 | wired、compressed、inactive 及 free | 同樣四個位置依次為緩衝區、`0`、快取及 free |
| 最大進程 | `ps axo rss=,comm=` | `ps axo rss=,comm=` |

進程名稱來自 `ps`，電腦上任何用戶都能控制它，因此在 tmux 把它當作格式讀取之前，名稱中的每個 `#` 都會被加倍。數字在 C 地區設定下格式化，所以使用逗號作小數點的地區設定仍然顯示 `1.5G`。

<details>
<summary><strong>Nerd Font 標籤</strong></summary>

```tmux
set -g @ram_revamped_icons 'nerd'
set -g @ram_revamped_percentage_label ''
```

| 指標 | 符號 |
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

## 開發

| 指令 | 作用 |
|:--------|:-------------|
| `make test` | 執行 bats 測試套件 |
| `make lint` | 對所有 shell 檔案執行 shellcheck |
| `make coverage` | 用 kcov 量度行覆蓋率，低於 95% 時失敗，在 Linux 上執行 |

測試套件需要 `bats-core` 及 tmux。

## 授權條款

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的成員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中的同一份約定、`family/` 下的同一套工具和同一個共用程式庫，並由校驗和清單確保逐位元組一致。這些成員可以一併安裝：任何成員都不會佔用其他成員使用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。這項責任寫在約定之中，而不是依靠記憶，`family/bin/sweep` 負責執行。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **本插件**，在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

### 檢查安裝

所有成員都在磁碟上時，一個指令即可報告它們之間的任何衝突：

```sh
family/bin/doctor --live
```

它讀取每個成員和正在運行的 tmux 伺服器，報告重複的按鍵、重複的狀態佔位符、不符合命名規則的選項，以及約定版本落後的成員。

<!-- family:end -->
