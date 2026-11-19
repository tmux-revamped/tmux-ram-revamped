<div align="center">

# tmux-ram-revamped

<strong>RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-ram-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-ram-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-ram-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-ram-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-ram-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-ram-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#仕組み">仕組み</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="使用中のメモリを段階ごとの色で表示し、モニターのポップアップを開き、Nerd Font のラベル、グラフ、options 描画モードに切り替える ram-revamped" width="800">
</p>

```console
$ ram-revamped refresh
Refreshed. 88% of the memory is in use.
$ ram-revamped status text
RAM 88% used, 12% available, swap 75%
```

プレースホルダー **18** 個、描画モード **2** つ、macOS と Linux、tmux **3.2** 以降。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 以降 | ファミリー共通の最低バージョン。ポップアップにも必要です |
| btop, htop | 任意 | ポップアップが開くモニター。なければ macOS では `vm_stat 1`、Linux では `free -h -s 1` を表示します |
| gum | 任意 | `ram-revamped` のメニュー、表、色。なくてもすべてのコマンドがプレーンテキストで動きます |

Linux と macOS で、BSD、GNU、uutils、BusyBox のいずれのツールでも動作します。各値は OS に付属するものから取得します。

| 値 | macOS | Linux |
|:-----|:------|:------|
| 使用中、利用可能、内訳、サイズ | `vm_stat` | `/proc/meminfo` |
| スワップ | `sysctl vm.swapusage` | `/proc/meminfo` |
| プレッシャー | `vm_stat` の wired と圧縮のページ | `/proc/pressure/memory` |
| コミット率 | なし。macOS にはコミット上限がありません | `/proc/meminfo` |
| 回収可能 | `vm_stat` の purgeable とファイルに対応するページ | `/proc/meminfo` のキャッシュ、バッファ、回収可能な slab |
| 最大のプロセス | `ps` | `ps` |

取得元がない場合、そのプレースホルダーは空になり、`ram-revamped doctor` がその名前を表示します。

### インストール

[TPM](https://github.com/tmux-plugins/tpm) を使う場合は、`~/.tmux.conf` にプラグインを追加して `prefix + I` を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
```

手動でインストールする場合は、リポジトリをクローンし、`~/.tmux.conf` からエントリポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

`status-left` または `status-right` はプラグインを読み込む前に設定してください。プラグインは読み込み時に 1 回だけ、そこにあるプレースホルダーを置き換えます。

クローンで `make install` を実行すると、`ram-revamped` が `~/.local/bin` に、manページと補完が `~/.local/share` の下に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-ram-revamped/bin/ram-revamped doctor
```

## 使い方

このプラグインは、使用中のメモリを、利用可能なメモリ、スワップ、プレッシャー、内訳、最大のプロセス、最近の計測値のグラフとともに表示します。ステータスラインは tmux がすでに持っている値を表示し、バックグラウンドの計測がそれを更新します。

| プレースホルダー | 出力 |
|:-----------------|:-----|
| `#{ram_percentage}` | 使用中のメモリで、たとえば`61%`です |
| `#{ram_icon}` | 使用中のメモリの段階を示すアイコンです |
| `#{ram_fg_color}` | 使用中のメモリの段階に応じた前景のスタイルです |
| `#{ram_bg_color}` | 使用中のメモリの段階に応じた背景のスタイルです |
| `#{ram_available}` | 利用可能なメモリで、たとえば`40%`です |
| `#{ram_swap}` | 使用中のスワップで、スワップがなければ空です |
| `#{ram_swap_icon}` | スワップの使用量がしきい値以上の間に出る警告アイコンです |
| `#{ram_swap_color}` | スワップの使用量がしきい値以上の間に出る警告のスタイルです |
| `#{ram_pressure}` | メモリプレッシャーで、たとえば`36%`です。高いほど逼迫しています |
| `#{ram_pressure_fg_color}` | プレッシャーの前景のスタイルで、使用中のメモリと同じしきい値で決まります |
| `#{ram_breakdown}` | ギガバイト単位のメモリの内訳で、たとえば`W 3.2G C 1.1G I 2.0G F 4.5G`です |
| `#{ram_absolute}` | 使用量と合計で、たとえば`12.3G / 32G`です |
| `#{ram_commit}` | コミット済みメモリとコミット上限の比率です。コミット上限のない macOS では空です |
| `#{ram_reclaimable}` | Linux ではページキャッシュ、バッファ、回収可能な slab の合計、macOS では purgeable とファイルに対応するページの合計で、たとえば`4.0G`です |
| `#{ram_top_process}` | 常駐メモリが最も大きいプロセスで、たとえば`firefox 1.2G`です |
| `#{ram_graph}` | 最近の計測値のスパークラインで、たとえば`▁▂▄▆█`です |
| `#{ram_trend}` | 履歴の範囲での`↑`、`↓`、`→`です |
| `#{ram_text}` | スクリーンリーダー向けのプレーンな1行で、たとえば`RAM 61% used, 40% available, swap 3%`です |

ステータスラインにプレースホルダーを置きます。

```tmux
set -g @ram_revamped_low_fg_color '#[fg=green]'
set -g @ram_revamped_medium_fg_color '#[fg=yellow]'
set -g @ram_revamped_high_fg_color '#[fg=red]'

set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] '
```

同じ例が [examples/status-right.tmux.conf](examples/status-right.tmux.conf) にあります。

### ラベルと幅

`@ram_revamped_<metric>_label` は、値が空でないときだけ、1 つの指標の前にアイコンや語を表示します。`@ram_revamped_icons` を `nerd` にすると、下の各指標に Nerd Font の記号のラベルが付きます。指標ごとのラベルはこのセットより優先され、空にしたラベルは既定値を意味するので記号は残ります。既定の `ascii` はラベルを付けません。

| 指標 | `nerd` のグリフ |
|:-----|:----------------|
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

`@ram_revamped_fixed_width` を `on` にすると、使用中、利用可能、スワップのパーセントを左から 4 文字に揃えるので、`9%` が `42%` に変わっても行の残りがずれません。`@ram_revamped_<metric>_width` は 1 つの指標の幅を決め、固定幅より優先されます。長い値は切り詰めません。

### 描画モード

既定では、各プレースホルダーは `#()` の呼び出しになり、tmux はステータスの再描画のたびにそれを再実行します。`@ram_revamped_render` を `options` にすると、各プレースホルダーは `#{E:@ram_revamped_out_percentage}` のようなオプションの読み取りになります。サーバーごとに 1 つのバックグラウンドプロセスが `@ram_revamped_interval` 秒ごとに計測し、すべての値を 1 回の tmux 呼び出しで書き込むため、値はそろって変わります。

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

### 段階ごとの色

段階のスタイルは既定では空なので、設定するまで `#{ram_fg_color}`、`#{ram_bg_color}`、`#{ram_pressure_fg_color}` は何も出力しません。以下の配色は、使用量の少ない段階を緑、中程度を黄、多い段階を赤に対応させています。

| テーマ | 少 | 中 | 多 |
|:-------|:---|:---|:---|
| Catppuccin Mocha | `#a6e3a1` | `#f9e2af` | `#f38ba8` |
| Dracula | `#50fa7b` | `#f1fa8c` | `#ff5555` |
| Nord | `#a3be8c` | `#ebcb8b` | `#bf616a` |
| Gruvbox Dark | `#b8bb26` | `#fabd2f` | `#fb4934` |
| Tokyo Night | `#9ece6a` | `#e0af68` | `#f7768e` |
| Solarized Dark | `#859900` | `#b58900` | `#dc322f` |

各値は `set -g @ram_revamped_low_fg_color '#[fg=#a6e3a1]'` のようにスタイルとして指定します。

| コマンド | 動作 |
|:--------|:-------------|
| `ram-revamped apply` | ポップアップのキーを割り当て、プレースホルダーを今すぐ置き換えます。プラグインの読み込み時にエントリーポイントが実行します |
| `ram-revamped list` | `apply` が送るコマンドをすべて表示し、何も変更しません。`--json` で 1 つのオブジェクトを出力します |
| `ram-revamped status NAME` | プレースホルダーを 1 つ出力します。`percentage`、`swap`、`graph` などで、ステータスラインが実行します |
| `ram-revamped refresh` | メモリを今すぐ計測し、使用中の割合を表示します |
| `ram-revamped card` | すべてを今すぐ読み取り、値ごとに 1 行で表示します |
| `ram-revamped popup` | メモリのモニターを tmux のポップアップで開きます。btop、なければ htop、どちらもなければシステム付属の表示です。ポップアップのキーが実行します |
| `ram-revamped daemon` | `options` 描画モードのために、ティックごとにプレースホルダーを公開します。`apply` が起動します |
| `ram-revamped doctor` | 依存関係ごとに 1 行。各値の取得元となるツールやファイル、ポップアップが開くモニター、触れなかったキーも含みます |
| `ram-revamped version` | バージョンと tmux のバージョン |
| `ram-revamped help` | ヘルプ。`man ram-revamped` にも同じコマンドと設定があります |
| `ram-revamped` | 端末ではメニュー |

## 設定

どのオプションも、ダッシュ区切りのコマンドオプション（例 `--interval 2`）と環境変数（例 `RAM_REVAMPED_INTERVAL`）で指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。空の tmux オプションは既定値を意味します。`doctor` は、プラグインが認識できない値を持つ設定の名前を表示します。`apply` に渡したものは、ポップアップのキーとすべてのステータスの呼び出しに引き継がれます。

### 計測

| オプション | 既定値 | 意味 |
|:-----------|:-------|:-----|
| `@ram_revamped_interval` | `5` | 計測値が新しいとみなされる秒数です |
| `@ram_revamped_detail_interval` | `60` | プレッシャーと最大のプロセスが新しいとみなされる秒数です |
| `@ram_revamped_render` | `jobs` | `options` にすると `#()` の呼び出しの代わりに公開済みのオプションを読みます。それ以外の値は `jobs` として扱います |
| `@ram_revamped_history_size` | `30` | スパークラインと傾向のために残す計測値の数です |
| `@ram_revamped_enable_logging` | 未設定 | `1` で、値を得られなかった計測を `~/.tmux/ram-revamped-logs/` に書きます。tmux オプションでのみ指定できます |

### 段階と警告

| オプション | 既定値 | 意味 |
|:-----------|:-------|:-----|
| `@ram_revamped_medium_thresh` | `50` | 段階がmediumになるパーセントです |
| `@ram_revamped_high_thresh` | `85` | 段階がhighになるパーセントです |
| `@ram_revamped_low_icon` | `▰▱▱` | low段階のアイコンです |
| `@ram_revamped_medium_icon` | `▰▰▱` | medium段階のアイコンです |
| `@ram_revamped_high_icon` | `▰▰▰` | high段階のアイコンです |
| `@ram_revamped_low_fg_color` | 空 | low段階の前景のスタイルで、たとえば`#[fg=green]`です |
| `@ram_revamped_medium_fg_color` | 空 | medium段階の前景のスタイルです |
| `@ram_revamped_high_fg_color` | 空 | high段階の前景のスタイルです |
| `@ram_revamped_low_bg_color` | 空 | low段階の背景のスタイルです |
| `@ram_revamped_medium_bg_color` | 空 | medium段階の背景のスタイルです |
| `@ram_revamped_high_bg_color` | 空 | high段階の背景のスタイルです |
| `@ram_revamped_swap_warn_thresh` | `1` | スワップの警告を出すパーセントです |
| `@ram_revamped_swap_active_icon` | 空 | `#{ram_swap_icon}`が表示するアイコンです |
| `@ram_revamped_swap_active_color` | 空 | `#{ram_swap_color}`が表示するスタイルです |
| `@ram_revamped_trend_threshold` | `3` | 傾向の矢印が`→`から変わるまでの変化量、パーセントポイントです |
| `@ram_revamped_trend_up` | `↑` | 上昇傾向の記号です |
| `@ram_revamped_trend_down` | `↓` | 下降傾向の記号です |
| `@ram_revamped_trend_flat` | `→` | 横ばいの記号です |

### 書式とラベル

| オプション | 既定値 | 意味 |
|:-----------|:-------|:-----|
| `@ram_revamped_percentage_format` | `%s%%` | 使用中のメモリのprintf書式です |
| `@ram_revamped_available_format` | `%s%%` | 利用可能なメモリのprintf書式です |
| `@ram_revamped_swap_format` | `%s%%` | スワップのprintf書式です |
| `@ram_revamped_pressure_format` | `%s%%` | プレッシャーのprintf書式です |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | 内訳の4つの値のprintf書式です |
| `@ram_revamped_absolute_format` | `%s / %s` | 使用量と合計のprintf書式です |
| `@ram_revamped_commit_format` | `%s%%` | コミット率のprintf書式です |
| `@ram_revamped_reclaimable_format` | `%s` | 回収可能なサイズのprintf書式です |
| `@ram_revamped_top_process_format` | `%s %s` | プロセス名とサイズのprintf書式です |
| `@ram_revamped_icons` | `ascii` | `nerd`にするとすべての値にNerd Fontの記号のラベルを付けます |
| `@ram_revamped_<metric>_label` | 空 | 1つの値の前に出すテキストで、値が空でないときだけ出ます |
| `@ram_revamped_fixed_width` | `off` | `on`でパーセントを4文字に揃え、`9%`が`42%`に変わってもステータス行がずれないようにします |
| `@ram_revamped_<metric>_width` | 空 | 1つの値をこの文字数に揃えます。長い値は切り詰めません |

### ポップアップ

| オプション | 既定値 | 意味 |
|:-----------|:-------|:-----|
| `@ram_revamped_popup_key` | `M-r` | 詳細のポップアップを開くプレフィックスキーです。`off`で何も割り当てません |
| `@ram_revamped_popup_width` | `80%` | ポップアップの幅です |
| `@ram_revamped_popup_height` | `60%` | ポップアップの高さです |

### 内部状態

以下のオプションはプラグイン自身が書き込みます。設定しないでください。

| オプション | 保持する内容 |
|:-----------|:-------------|
| `@ram_revamped_published` | ステータス行が使う指標で、オプションモードがそれだけを書き込むよう読み込み時に記録します |
| `@ram_revamped_history` | `#{ram_graph}`と`#{ram_trend}`のもとになる、最近の使用中メモリの計測値です |
| `@ram_revamped_out_<metric>` | オプションモードでの各指標の描画済みの値です |
| `@ram_revamped_ticker_pid` | オプションモードのバックグラウンドのプロセスのIDです |
| `@ram_revamped_percent` などの値、`_ts`、`_lock` | 保存した計測値、それぞれの読み取り時刻と更新ロック |

## キーバインド

| キー | 動作 | 既定 |
|:-----|:-----|:-----|
| `prefix + M-r` | メモリのモニターをポップアップで開きます。btop、なければ htop、どちらもなければシステム付属の表示です | 割り当て済み |

`@ram_revamped_popup_key` で別のキーを指定でき、`off` にすると割り当てません。既定のキーがすでに他で使われている場合は触れず、`ram-revamped doctor` がそれを表示します。

<a id="仕組み"></a>

## 仕組み

tmux がプラグインを読み込むと、[`ram-revamped.tmux`](ram-revamped.tmux) が 1 回実行されます。`status-left` と `status-right` が使う指標を `@ram_revamped_published` に記録し、各プレースホルダーを [`bin/ram-revamped`](bin/ram-revamped) の呼び出しに置き換えます。`options` モードでは、オプションの読み取りに置き換えてバックグラウンドプロセスを起動します。

既定のモードでは、各 `#()` の呼び出しは保存済みの計測値をすぐに返します。計測値が間隔より古ければ、ロックを取ってバックグラウンドで更新を始めるため、同時に動く更新は 1 つだけです。1 回の計測では、macOS では `vm_stat` と `sysctl`、Linux では `/proc/meminfo` を 1 回読み、1 つの `awk` ですべての値を求め、1 回の tmux 呼び出しで書き込みます。Linux のプレッシャーと最大のプロセスはそれぞれもう 1 回の読み取りが必要なので、ステータスラインが使うプレースホルダーの分だけ、`@ram_revamped_detail_interval` 秒ごとに読み取ります。

プレッシャーの意味は 2 つのシステムで異なります。Linux では `/proc/pressure/memory` の 10 秒平均で、いずれかのタスクがメモリを待った時間の割合です。macOS では wired またはコンプレッサーが保持するページの割合です。内訳は、macOS では wired、圧縮、inactive、free、Linux ではバッファ、0、キャッシュ、free です。

最大のプロセスの名前は `ps` から得られ、どのユーザーでも変えられるため、ステータスラインに渡す前にすべての `#` を二重にします。読み取り、計測、整形は [`lib/ram.sh`](lib/ram.sh) に、設定の表は [`lib/state.sh`](lib/state.sh) にあります。

<a id="画面"></a>

## 画面

<details>
<summary>すべての画面。本物の tmux の中で <code>make screens</code> で録画し、押したキーをステータスラインに表示しています</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="ram-revamped: 使用中のメモリと段階のアイコンと色、利用可能なメモリ、スワップの警告"><br><sub>使用中のメモリと段階のアイコンと色、利用可能なメモリ、スワップの警告。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="ram-revamped: prefix M-r でメモリのモニターをポップアップで開きます"><br><sub><code>prefix M-r</code> でメモリのモニターをポップアップで開きます。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="ram-revamped: @ram_revamped_icons を nerd にすると各指標に記号のラベルが付きます"><br><sub><code>@ram_revamped_icons</code> を <code>nerd</code> にすると各指標に記号のラベルが付きます。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="ram-revamped: グラフ、傾向、テキストの行"><br><sub>グラフ、傾向、テキストの行。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="ram-revamped: options 描画モードでは各プレースホルダーが tmux のオプションを読みます"><br><sub><code>options</code> 描画モードでは各プレースホルダーが tmux のオプションを読みます。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="ram-revamped: card はすべての値を表示します"><br><sub><code>card</code> はすべての値を表示します。<code>features.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/details.png" alt="ram-revamped: 使用量と合計、段階の色のプレッシャー、回収可能なサイズ、最大のプロセス"><br><sub>使用量と合計、段階の色のプレッシャー、回収可能なサイズ、最大のプロセス。<code>features.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/breakdown.png" alt="ram-revamped: 内訳とコミット率"><br><sub>内訳とコミット率。<code>features.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/format.png" alt="ram-revamped: @ram_revamped_percentage_format で使用中のパーセントの書式を変えます"><br><sub><code>@ram_revamped_percentage_format</code> で使用中のパーセントの書式を変えます。<code>features.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="ram-revamped: @ram_revamped_fixed_width でパーセントを 4 文字に揃えます"><br><sub><code>@ram_revamped_fixed_width</code> でパーセントを 4 文字に揃えます。<code>features.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="ram-revamped: 指標ごとのラベル"><br><sub>指標ごとのラベル。<code>features.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="ram-revamped: @ram_revamped_medium_thresh と @ram_revamped_high_thresh で段階の境目を変えます"><br><sub><code>@ram_revamped_medium_thresh</code> と <code>@ram_revamped_high_thresh</code> で段階の境目を変えます。<code>features.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="ram-revamped: @ram_revamped_popup_key でポップアップに別のキーを割り当てます"><br><sub><code>@ram_revamped_popup_key</code> でポップアップに別のキーを割り当てます。<code>features.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="ram-revamped: status text と status graph はプレースホルダーを 1 つずつ出力します"><br><sub><code>status text</code> と <code>status graph</code> はプレースホルダーを 1 つずつ出力します。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="ram-revamped: refresh はメモリを今すぐ計測します"><br><sub><code>refresh</code> はメモリを今すぐ計測します。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="ram-revamped: list はすべての割り当てを表示します"><br><sub><code>list</code> はすべての割り当てを表示します。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="ram-revamped: list --json は同じ内容を 1 つのオブジェクトで出力します"><br><sub><code>list --json</code> は同じ内容を 1 つのオブジェクトで出力します。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="ram-revamped: doctor"><br><sub><code>doctor</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="ram-revamped: メニュー"><br><sub>メニュー。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="ram-revamped: メニューから開いたカード"><br><sub>メニューから開いたカード。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="ram-revamped: RAM_REVAMPED_ACCENT のアクセント色"><br><sub><code>RAM_REVAMPED_ACCENT</code> のアクセント色。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="ram-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="ram-revamped: gum なしでメニューから開いた doctor"><br><sub>gum なしでメニューから開いた <code>doctor</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="ram-revamped: gum なしの card"><br><sub>gum なしの <code>card</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="ram-revamped: バージョン"><br><sub>バージョン。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="ram-revamped: 不明なコマンド"><br><sub>不明なコマンド。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="ram-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー。<code>themes.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="ram-revamped: ヘルプ"><br><sub>ヘルプ。<code>help.tape</code>より</sub></td>
</tr>
</table>

録画では本物のプラグインと tmux を動かしています。`vm_stat`、`sysctl`、`ps` の代わりに小さなスクリプトを使っているため、画面の値はそのスクリプトのものです。

</details>

## 移植性

プラグインは POSIX `sh` です。CI は下の各行ですべてのテストを実行します。

| シェル | 状態 |
|:------|:-------|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-------|:-------|
| macOS | Apple Silicon と Intel の Tahoe。付属のツール、Homebrew の GNU ツール、Homebrew の uutils で確認 |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox で確認 |

## 開発

| コマンド | 実行内容 |
|:--------|:-------------|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` をかけます |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint を、指摘ゼロで通します |
| `make test` | システムの `sh` で bats のテスト |
| `make test-all` | インストール済みのすべてのシェルでテスト。macOS では bash と zsh の両方のビルドを含みます |
| `make test-linux` | Ubuntu のコンテナでテスト |
| `make coverage` | この Mac と Ubuntu のコンテナで bashcov を実行し、合算して 100 パーセントで判定します |
| `make screens` | 上の画面を、本物のプラグインから tmux の中で VHS で録画します。macOS で実行します |
| `make install` | コマンド、manページ、補完を `PREFIX` の下に置きます |

macOS では、`brew bundle` を実行すると、これらのターゲットが使うツールがすべて [`Brewfile`](Brewfile) からインストールされます。

コミットは Conventional Commits の形式に従い、そのまま `main` に入ります。`main` で `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降に `feat` か `fix` があればリリースを公開し、バージョン定数を更新し、変更内容を [`CHANGELOG.md`](CHANGELOG.md) に追加します。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **このプラグイン**、RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->
