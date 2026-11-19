<div align="center">

# tmux-ram-revamped

<strong>在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-ram-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-ram-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-ram-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-ram-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-ram-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-ram-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速開始"><strong>快速開始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#運作原理">運作原理</a> &nbsp;|&nbsp;
  <a href="#畫面">畫面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="ram-revamped 按級別顏色顯示已用記憶體，開啟監察工具彈出視窗，並切換到 Nerd Font 標籤、圖表和 options 繪製模式" width="800">
</p>

```console
$ ram-revamped refresh
Refreshed. 88% of the memory is in use.
$ ram-revamped status text
RAM 88% used, 12% available, swap 75%
```

**18** 個佔位符，**2** 種繪製模式，支援 macOS 和 Linux，需要 tmux **3.2** 或更新版本。

---

## 快速開始

### 前提條件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或更新 | 家族的最低版本，彈出視窗亦需要它 |
| btop, htop | 可選 | 彈出視窗開啟的監察工具；沒有時在 macOS 上顯示 `vm_stat 1`，在 Linux 上顯示 `free -h -s 1` |
| gum | 可選 | `ram-revamped` 的選單、表格和顏色；沒有它時所有指令輸出純文字 |

它在 Linux 和 macOS 上執行，BSD、GNU、uutils 或 BusyBox 工具均可。每個數值都來自系統內置的來源：

| 數值 | macOS | Linux |
|:-----|:------|:------|
| 已用、可用、組成、大小 | `vm_stat` | `/proc/meminfo` |
| 交換空間 | `sysctl vm.swapusage` | `/proc/meminfo` |
| 記憶體壓力 | `vm_stat` 的 wired 和壓縮頁面 | `/proc/pressure/memory` |
| 承諾比例 | 沒有：macOS 沒有承諾上限 | `/proc/meminfo` |
| 可回收 | `vm_stat` 的 purgeable 和檔案支援頁面 | `/proc/meminfo` 的快取、緩衝區及可回收 slab |
| 最大進程 | `ps` | `ps` |

缺少來源時，對應的佔位符為空，`ram-revamped doctor` 會指出是哪一個。

### 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm) 時，將插件加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
```

手動安裝時，複製儲存庫，並在 `~/.tmux.conf` 中執行入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

請在插件載入之前設定 `status-left` 或 `status-right`。插件只在載入時替換一次其中的佔位符。

在複製的目錄中執行 `make install`，亦會把 `ram-revamped` 放入 `~/.local/bin`，並把它的 man 手冊和自動完成放在 `~/.local/share` 下。

### 驗證

```bash
~/.tmux/plugins/tmux-ram-revamped/bin/ram-revamped doctor
```

## 用法

本插件顯示已用記憶體，以及可用記憶體、交換空間、記憶體壓力、記憶體組成、最大進程和最近取樣的圖表。狀態列顯示 tmux 已經儲存的值，背景取樣負責更新它。

| 佔位符 | 輸出 |
|:-------|:-----|
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
| `#{ram_commit}` | 已承諾記憶體與承諾上限之比；macOS 沒有承諾上限，因此為空 |
| `#{ram_reclaimable}` | 在 Linux 上是頁面快取、緩衝區及可回收 slab 之和，在 macOS 上是 purgeable 與檔案支援頁面之和，例如 `4.0G` |
| `#{ram_top_process}` | 常駐記憶體最大的進程，例如 `firefox 1.2G` |
| `#{ram_graph}` | 最近取樣的走勢線，例如 `▁▂▄▆█` |
| `#{ram_trend}` | 紀錄範圍內的 `↑`、`↓` 或 `→` |
| `#{ram_text}` | 供螢幕閱讀器使用的純文字行，例如 `RAM 61% used, 40% available, swap 3%` |

把佔位符放進狀態列：

```tmux
set -g @ram_revamped_low_fg_color '#[fg=green]'
set -g @ram_revamped_medium_fg_color '#[fg=yellow]'
set -g @ram_revamped_high_fg_color '#[fg=red]'

set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] '
```

相同的範例見 [examples/status-right.tmux.conf](examples/status-right.tmux.conf)。

### 標籤和闊度

`@ram_revamped_<metric>_label` 在某個指標之前顯示圖示或文字，只在該值非空時顯示。把 `@ram_revamped_icons` 設為 `nerd` 會為下面每個指標加上 Nerd Font 符號標籤。指標自己的標籤優先於這一套符號，設為空的標籤代表預設值，所以符號保留。預設的 `ascii` 不加標籤。

| 指標 | `nerd` 圖示 |
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

把 `@ram_revamped_fixed_width` 設為 `on` 會把已用、可用和交換空間的百分比在左邊補齊到 4 個字元，由 `9%` 變為 `42%` 時狀態列的其餘部分不會移位。`@ram_revamped_<metric>_width` 設定某個指標的闊度，並優先於固定闊度。較長的值不會被截斷。

### 繪製模式

預設情況下，每個佔位符會變成一個 `#()` 呼叫，tmux 每次重繪狀態列時都會重新執行。將 `@ram_revamped_render` 設為 `options` 後，每個佔位符會變成讀取選項，例如 `#{E:@ram_revamped_out_percentage}`。每部伺服器只有一個背景程序，每 `@ram_revamped_interval` 秒取樣一次，並在一次 tmux 呼叫中寫入所有值，所以這些值會同時更新。

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

### 級別顏色

級別樣式預設為空，所以在設定之前 `#{ram_fg_color}`、`#{ram_bg_color}` 和 `#{ram_pressure_fg_color}` 不輸出任何內容。下面的配色把低用量對應綠色，中等對應黃色，高用量對應紅色：

| 主題 | 低 | 中 | 高 |
|:-----|:---|:---|:---|
| Catppuccin Mocha | `#a6e3a1` | `#f9e2af` | `#f38ba8` |
| Dracula | `#50fa7b` | `#f1fa8c` | `#ff5555` |
| Nord | `#a3be8c` | `#ebcb8b` | `#bf616a` |
| Gruvbox Dark | `#b8bb26` | `#fabd2f` | `#fb4934` |
| Tokyo Night | `#9ece6a` | `#e0af68` | `#f7768e` |
| Solarized Dark | `#859900` | `#b58900` | `#dc322f` |

每個值都寫成樣式，例如 `set -g @ram_revamped_low_fg_color '#[fg=#a6e3a1]'`。

| 命令 | 作用 |
|:--------|:-------------|
| `ram-revamped apply` | 綁定彈出視窗按鍵並立即替換佔位符；tmux 載入插件時入口腳本會執行它 |
| `ram-revamped list` | 顯示 `apply` 將傳送的每條指令，不作任何更改；`--json` 輸出一個物件 |
| `ram-revamped status NAME` | 輸出一個佔位符，例如 `percentage`、`swap` 或 `graph`；狀態列會執行它 |
| `ram-revamped refresh` | 立即取樣記憶體，並說明已用多少 |
| `ram-revamped card` | 立即讀取全部數值，每個數值顯示一行 |
| `ram-revamped popup` | 在 tmux 彈出視窗中開啟記憶體監察工具：btop，沒有則 htop，再沒有則顯示系統內置的數值；彈出視窗按鍵會執行它 |
| `ram-revamped daemon` | 為 `options` 繪製模式在每個週期發佈佔位符；`apply` 會啟動它 |
| `ram-revamped doctor` | 每個依賴一行：每個數值來自的工具或檔案、彈出視窗開啟的監察工具，以及沒有改動的按鍵 |
| `ram-revamped version` | 版本，以及 tmux 的版本 |
| `ram-revamped help` | 說明頁；`man ram-revamped` 記錄了同樣的指令和設定 |
| `ram-revamped` | 在終端機上顯示選單 |

## 設定

每個選項亦可寫成帶連字號的命令選項，例如 `--interval 2`，或環境變數，例如 `RAM_REVAMPED_INTERVAL`；命令列優先於環境變數，環境變數優先於 tmux 選項。空的 tmux 選項表示使用預設值。`doctor` 會指出數值無法識別的設定。傳給 `apply` 的選項會隨彈出視窗的按鍵和每次狀態呼叫一同生效。

### 取樣

| 選項 | 預設值 | 意思 |
|:-----|:-------|:-----|
| `@ram_revamped_interval` | `5` | 取樣值保持有效的秒數 |
| `@ram_revamped_detail_interval` | `60` | 記憶體壓力和最大進程保持有效的秒數 |
| `@ram_revamped_render` | `jobs` | `options` 讀取已發佈的選項，而不是執行 `#()` 呼叫；其他任何值都視為 `jobs` |
| `@ram_revamped_history_size` | `30` | 為走勢線及趨勢保留的取樣數目 |
| `@ram_revamped_enable_logging` | 未設定 | `1` 把沒有讀到數值的取樣寫入 `~/.tmux/ram-revamped-logs/`；只能以 tmux 選項設定 |

### 級別和警告

| 選項 | 預設值 | 意思 |
|:-----|:-------|:-----|
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
| `@ram_revamped_swap_warn_thresh` | `1` | 顯示交換空間警告的百分比 |
| `@ram_revamped_swap_active_icon` | 空 | `#{ram_swap_icon}` 顯示的圖示 |
| `@ram_revamped_swap_active_color` | 空 | `#{ram_swap_color}` 顯示的樣式 |
| `@ram_revamped_trend_threshold` | `3` | 趨勢箭咀離開 `→` 所需的變化，以百分點計 |
| `@ram_revamped_trend_up` | `↑` | 上升趨勢的符號 |
| `@ram_revamped_trend_down` | `↓` | 下降趨勢的符號 |
| `@ram_revamped_trend_flat` | `→` | 平穩趨勢的符號 |

### 格式和標籤

| 選項 | 預設值 | 意思 |
|:-----|:-------|:-----|
| `@ram_revamped_percentage_format` | `%s%%` | 已用記憶體的 printf 格式 |
| `@ram_revamped_available_format` | `%s%%` | 可用記憶體的 printf 格式 |
| `@ram_revamped_swap_format` | `%s%%` | 交換空間的 printf 格式 |
| `@ram_revamped_pressure_format` | `%s%%` | 記憶體壓力的 printf 格式 |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | 記憶體組成四個值的 printf 格式 |
| `@ram_revamped_absolute_format` | `%s / %s` | 已用與總量的 printf 格式 |
| `@ram_revamped_commit_format` | `%s%%` | 承諾比例的 printf 格式 |
| `@ram_revamped_reclaimable_format` | `%s` | 可回收大小的 printf 格式 |
| `@ram_revamped_top_process_format` | `%s %s` | 進程名稱及大小的 printf 格式 |
| `@ram_revamped_icons` | `ascii` | `nerd` 為每個值加上 Nerd Font 符號標籤 |
| `@ram_revamped_<metric>_label` | 空 | 顯示在某個值之前的文字，只在該值非空時顯示 |
| `@ram_revamped_fixed_width` | `off` | `on` 把百分比補齊到 4 個字元，由 `9%` 變為 `42%` 時狀態列不會移位 |
| `@ram_revamped_<metric>_width` | 空 | 把某個值補齊到此字元數。較長的值不會被截斷 |

### 彈出視窗

| 選項 | 預設值 | 意思 |
|:-----|:-------|:-----|
| `@ram_revamped_popup_key` | `M-r` | 開啟詳細資料彈出視窗的前綴鍵。`off` 不綁定任何鍵 |
| `@ram_revamped_popup_width` | `80%` | 彈出視窗闊度 |
| `@ram_revamped_popup_height` | `60%` | 彈出視窗高度 |

### 內部狀態

以下選項由插件自行寫入，請勿設定。

| 選項 | 存放內容 |
|:-----|:---------|
| `@ram_revamped_published` | 狀態列用到的指標，在載入時記錄，令選項模式只寫入這些指標 |
| `@ram_revamped_history` | `#{ram_graph}` 及 `#{ram_trend}` 所用的最近已用記憶體取樣 |
| `@ram_revamped_out_<metric>` | 選項模式下每個指標繪製後的值 |
| `@ram_revamped_ticker_pid` | 選項模式背景進程的進程 ID |
| `@ram_revamped_percent` 等數值、`_ts`、`_lock` | 儲存的取樣、每次讀取的時間和更新鎖 |

## 按鍵綁定

| 按鍵 | 動作 | 預設 |
|:-----|:-----|:-----|
| `prefix + M-r` | 在彈出視窗中開啟記憶體監察工具：btop，沒有則 htop，再沒有則顯示系統內置的數值 | 已綁定 |

`@ram_revamped_popup_key` 可以指定其他按鍵，設為 `off` 則不綁定。預設按鍵已被佔用時不會改動它，`ram-revamped doctor` 會說明這一點。

<a id="運作原理"></a>

## 運作原理

tmux 載入插件時，[`ram-revamped.tmux`](ram-revamped.tmux) 執行一次。它把 `status-left` 和 `status-right` 用到的指標記錄在 `@ram_revamped_published` 中，然後把每個佔位符替換成對 [`bin/ram-revamped`](bin/ram-revamped) 的呼叫；在 `options` 模式下則替換成選項讀取，並啟動背景進程。

在預設模式下，每個 `#()` 呼叫立即傳回儲存的取樣。取樣比間隔舊時，呼叫會取得鎖並在背景開始更新，所以同一時間只有一個更新在執行。一次取樣在 macOS 上讀取一次 `vm_stat` 和 `sysctl`，在 Linux 上讀取一次 `/proc/meminfo`，由一個 `awk` 算出全部數值，並以一次 tmux 呼叫寫入。Linux 上的記憶體壓力和最大進程各需要多讀一次，所以只為狀態列用到的佔位符讀取，每 `@ram_revamped_detail_interval` 秒一次。

記憶體壓力在兩個系統上的意思不同：在 Linux 上是 `/proc/pressure/memory` 的 10 秒平均值，即有工作等待記憶體的時間比例；在 macOS 上是 wired 頁面和壓縮器佔用頁面的比例。記憶體組成在 macOS 上是 wired、壓縮、inactive 和 free，在 Linux 上是緩衝區、0、快取和 free。

最大進程的名稱來自 `ps`，任何使用者都能控制它，所以在送到狀態列之前會把其中每個 `#` 加倍。讀取、取樣和格式化的程式碼在 [`lib/ram.sh`](lib/ram.sh)，設定表在 [`lib/state.sh`](lib/state.sh)。

<a id="畫面"></a>

## 畫面

<details>
<summary>所有畫面，在真實的 tmux 中以 <code>make screens</code> 錄製，每個按鍵顯示在狀態列上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="ram-revamped: 已用記憶體及其級別圖示和顏色、可用記憶體和交換空間警告"><br><sub>已用記憶體及其級別圖示和顏色、可用記憶體和交換空間警告，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="ram-revamped: prefix M-r 在彈出視窗中開啟記憶體監察工具"><br><sub><code>prefix M-r</code> 在彈出視窗中開啟記憶體監察工具，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="ram-revamped: 把 @ram_revamped_icons 設為 nerd 會為每個指標加上符號標籤"><br><sub>把 <code>@ram_revamped_icons</code> 設為 <code>nerd</code> 會為每個指標加上符號標籤，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="ram-revamped: 圖表、趨勢和文字行"><br><sub>圖表、趨勢和文字行，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="ram-revamped: 在 options 繪製模式下，每個佔位符讀取一個 tmux 選項"><br><sub>在 <code>options</code> 繪製模式下，每個佔位符讀取一個 tmux 選項，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="ram-revamped: card 顯示每個數值"><br><sub><code>card</code> 顯示每個數值，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/details.png" alt="ram-revamped: 已用與總量、帶級別顏色的記憶體壓力、可回收大小和最大進程"><br><sub>已用與總量、帶級別顏色的記憶體壓力、可回收大小和最大進程，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/breakdown.png" alt="ram-revamped: 記憶體組成和承諾比例"><br><sub>記憶體組成和承諾比例，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/format.png" alt="ram-revamped: @ram_revamped_percentage_format 決定已用百分比的格式"><br><sub><code>@ram_revamped_percentage_format</code> 決定已用百分比的格式，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="ram-revamped: @ram_revamped_fixed_width 把百分比補齊到 4 個字元"><br><sub><code>@ram_revamped_fixed_width</code> 把百分比補齊到 4 個字元，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="ram-revamped: 某個指標自己的標籤"><br><sub>某個指標自己的標籤，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="ram-revamped: @ram_revamped_medium_thresh 和 @ram_revamped_high_thresh 移動級別的界線"><br><sub><code>@ram_revamped_medium_thresh</code> 和 <code>@ram_revamped_high_thresh</code> 移動級別的界線，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="ram-revamped: @ram_revamped_popup_key 為彈出視窗指定另一個按鍵"><br><sub><code>@ram_revamped_popup_key</code> 為彈出視窗指定另一個按鍵，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="ram-revamped: status text 和 status graph 各輸出一個佔位符"><br><sub><code>status text</code> 和 <code>status graph</code> 各輸出一個佔位符，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="ram-revamped: refresh 立即取樣記憶體"><br><sub><code>refresh</code> 立即取樣記憶體，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="ram-revamped: list 顯示每個綁定"><br><sub><code>list</code> 顯示每個綁定，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="ram-revamped: list --json 把同樣的內容輸出為一個物件"><br><sub><code>list --json</code> 把同樣的內容輸出為一個物件，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="ram-revamped: doctor"><br><sub><code>doctor</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="ram-revamped: 選單"><br><sub>選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="ram-revamped: 從選單開啟的卡片"><br><sub>從選單開啟的卡片，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="ram-revamped: 來自 RAM_REVAMPED_ACCENT 的強調色"><br><sub>來自 <code>RAM_REVAMPED_ACCENT</code> 的強調色，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="ram-revamped: 沒有 gum 時的選單"><br><sub>沒有 gum 時的選單，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="ram-revamped: 沒有 gum 時從選單開啟的 doctor"><br><sub>沒有 gum 時從選單開啟的 <code>doctor</code>，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="ram-revamped: 沒有 gum 時的 card"><br><sub>沒有 gum 時的 <code>card</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="ram-revamped: 版本"><br><sub>版本，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="ram-revamped: 不明指令"><br><sub>不明指令，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="ram-revamped: 六種主題下的標題"><br><sub>六種主題下的標題，來自 <code>themes.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="ram-revamped: 說明頁"><br><sub>說明頁，來自 <code>help.tape</code></sub></td>
</tr>
</table>

錄製時執行的是真實的插件和 tmux。`vm_stat`、`sysctl` 和 `ps` 由小腳本代替，所以畫面上的數值來自這些腳本。

</details>

## 可攜性

插件是 POSIX `sh`。CI 在下列每一行上執行全部測試。

| Shell | 狀態 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支援 |
| `bash` 3.2 和 5.x、系統內建的 `zsh` 和 Homebrew 的 `zsh` | 支援 |

| 系統 | 狀態 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用內建的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make fmt` | 對每個腳本執行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零警告 |
| `make test` | 在系統 `sh` 下執行 bats 測試 |
| `make test-all` | 在每個已安裝的 shell 下執行測試，macOS 上包括 bash 和 zsh 的兩種版本 |
| `make test-linux` | 在 Ubuntu 容器中執行測試 |
| `make coverage` | 在這部 Mac 和 Ubuntu 容器中執行 bashcov，合併後以 100% 為門檻 |
| `make screens` | 以 VHS 在 tmux 中從真實插件錄製上述畫面，在 macOS 上執行 |
| `make install` | 把指令、man 手冊和自動完成安裝到 `PREFIX` 下 |

在 macOS 上，執行 `brew bundle` 會根據 [`Brewfile`](Brewfile) 安裝這些目標用到的所有工具。

提交遵循 Conventional Commits 格式，直接進入 `main`。`main` 上的 `ci` 通過後，`release.yml` 會執行 semantic-release：自上一個標籤以來的每個 `feat` 或 `fix` 都會發佈新版本，更新版本常數，並把說明寫入 [`CHANGELOG.md`](CHANGELOG.md)。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定和相同的共用程式庫，並且設計為一起安裝：沒有成員佔用另一個成員佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **本插件**，在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

<!-- family:end -->
