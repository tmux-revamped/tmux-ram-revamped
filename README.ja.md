<div align="center">

# tmux-ram-revamped

<strong>RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-ram-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">概要</a> &nbsp;|&nbsp;
  <a href="#installation">インストール</a> &nbsp;|&nbsp;
  <a href="#usage">使い方</a> &nbsp;|&nbsp;
  <a href="#configuration">設定</a> &nbsp;|&nbsp;
  <a href="#key-bindings">キーバインド</a> &nbsp;|&nbsp;
  <a href="#how-it-works">仕組み</a>
</p>

</div>

**プレースホルダーは18個です。5秒ごとに新しい値を計測し、時間のかかる詳細は60秒ごとに計測します。OS標準のツールだけを使います。macOSとLinuxでテストしています。**

---

<a id="what-it-does"></a>

## 概要

このプラグインはステータス行にメモリの数値を表示します。使用中と利用可能なメモリ、スワップ、メモリプレッシャー、メモリの内訳、最もメモリを使っているプロセス、最近の使用量のスパークラインです。ステータス行はtmuxがすでに持っている値を読み、次の計測はバックグラウンドのプロセスが行います。`prefix + M-r`でメモリモニターをポップアップで開きます。

## 必要なもの

| 項目 | バージョンや補足 |
|:------------|:----------------|
| tmux | 3.2以降 |
| bash | 3.2以降。macOS標準の`/bin/bash`で動きます |
| OS | Apple SiliconとIntelのmacOS、x86_64とarm64のLinux |
| 基本コマンド | BSD、GNU、uutilsのいずれのcoreutilsでも動きます |
| メモリの情報源 | macOSでは`vm_stat`と`sysctl`、Linuxでは`/proc/meminfo`と`/proc/pressure/memory` |
| `btop`または`htop` | 任意。詳細のポップアップに使います |

<a id="installation"></a>

## インストール

[TPM](https://github.com/tmux-plugins/tpm)を使う場合は、`~/.tmux.conf`にプラグインとプレースホルダーを追加して`prefix + I`を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-ram-revamped'
set -g status-right '#{ram_icon} #{ram_percentage}'
```

TPMを使わない場合は、リポジトリをクローンし、`~/.tmux.conf`の`status-right`を設定する行より後でエントリーポイントを実行します。

```sh
git clone https://github.com/tmux-revamped/tmux-ram-revamped ~/.tmux/plugins/tmux-ram-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-ram-revamped/ram-revamped.tmux
```

<a id="usage"></a>

## 使い方

以下のプレースホルダーを`status-left`または`status-right`に置きます。情報源がないプレースホルダーは何も表示しません。

| プレースホルダー | 出力 |
|:------------|:-------|
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
| `#{ram_commit}` | コミット済みメモリとコミット上限の比率です。Linuxのみです |
| `#{ram_reclaimable}` | ページキャッシュ、バッファ、回収可能なslabの合計です。Linuxのみで、たとえば`4.0G`です |
| `#{ram_top_process}` | 常駐メモリが最も大きいプロセスで、たとえば`firefox 1.2G`です |
| `#{ram_graph}` | 最近の計測値のスパークラインで、たとえば`▁▂▄▆█`です |
| `#{ram_trend}` | 履歴の範囲での`↑`、`↓`、`→`です |
| `#{ram_text}` | スクリーンリーダー向けのプレーンな1行で、たとえば`RAM 61% used, 40% available, swap 3%`です |

末尾でスタイルを戻す、より詳しいステータス行の例です。

```tmux
set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] #{ram_graph}'
```

シェルからは2つのコマンドも使えます。`~/.tmux/plugins/tmux-ram-revamped/src/ram.sh doctor`はプラットフォームと見つかった情報源を報告し、`ram.sh popup`はモニターを開きます。

<a id="configuration"></a>

## 設定

オプションはプラグインを読み込む前に`~/.tmux.conf`で設定します。

| オプション | 既定値 | 意味 |
|:-------|:--------|:--------|
| `@ram_revamped_interval` | `5` | 計測値が新しいとみなされる秒数です |
| `@ram_revamped_detail_interval` | `60` | プレッシャー、内訳、絶対値、コミット、回収可能、上位プロセスの値が新しいとみなされる秒数です |
| `@ram_revamped_render` | 未設定 | `options`にすると各プレースホルダーをオプションの読み取りに変え、サーバーごとに1つのバックグラウンドのプロセスが書き込みます |
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
| `@ram_revamped_percentage_format` | `%s%%` | 使用中のメモリのprintf書式です |
| `@ram_revamped_available_format` | `%s%%` | 利用可能なメモリのprintf書式です |
| `@ram_revamped_swap_format` | `%s%%` | スワップのprintf書式です |
| `@ram_revamped_pressure_format` | `%s%%` | プレッシャーのprintf書式です |
| `@ram_revamped_breakdown_format` | `W %sG C %sG I %sG F %sG` | 内訳の4つの値のprintf書式です |
| `@ram_revamped_absolute_format` | `%s / %s` | 使用量と合計のprintf書式です |
| `@ram_revamped_commit_format` | `%s%%` | コミット率のprintf書式です |
| `@ram_revamped_reclaimable_format` | `%s` | 回収可能なサイズのprintf書式です |
| `@ram_revamped_top_process_format` | `%s %s` | プロセス名とサイズのprintf書式です |
| `@ram_revamped_history_size` | `30` | スパークラインと傾向のために残す計測値の数です |
| `@ram_revamped_trend_threshold` | `3` | 傾向の矢印が`→`から変わるまでの変化量、パーセントポイントです |
| `@ram_revamped_trend_up` | `↑` | 上昇傾向の記号です |
| `@ram_revamped_trend_down` | `↓` | 下降傾向の記号です |
| `@ram_revamped_trend_flat` | `→` | 横ばいの記号です |
| `@ram_revamped_swap_warn_thresh` | `1` | スワップの警告を出すパーセントです |
| `@ram_revamped_swap_active_icon` | 空 | `#{ram_swap_icon}`が表示するアイコンです |
| `@ram_revamped_swap_active_color` | 空 | `#{ram_swap_color}`が表示するスタイルです |
| `@ram_revamped_icons` | `ascii` | `nerd`にするとすべての値にNerd Fontの記号のラベルを付けます |
| `@ram_revamped_<metric>_label` | 未設定 | 1つの値の前に出すテキストで、値が空でないときだけ出ます。`''`にするとその値のNerd Fontのラベルを外します |
| `@ram_revamped_fixed_width` | `off` | `on`でパーセントを4文字に揃え、`9%`が`42%`に変わってもステータス行がずれないようにします |
| `@ram_revamped_<metric>_width` | 未設定 | 1つの値をこの文字数に揃えます。長い値は切り詰めません |
| `@ram_revamped_popup_key` | `M-r` | 詳細のポップアップを開くプレフィックスキーです。`off`で何も割り当てません |
| `@ram_revamped_popup_width` | `80%` | ポップアップの幅です |
| `@ram_revamped_popup_height` | `60%` | ポップアップの高さです |
| `@ram_revamped_enable_logging` | `0` | `1`でエラーを`~/.tmux/ram-revamped-logs/`に書きます |

`<metric>`は`percentage`、`available`、`swap`、`pressure`、`breakdown`、`absolute`、`commit`、`reclaimable`、`top_process`、`graph`、`trend`のいずれかです。

<details>
<summary><strong>よく使われるテーマの段階の色</strong></summary>

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

### 内部状態

以下のオプションはプラグインが自分で管理します。設定しないでください。

| オプション | 内容 |
|:-------|:------|
| `@ram_revamped_published` | ステータス行が使う指標で、オプションモードがそれだけを書き込むよう読み込み時に記録します |
| `@ram_revamped_history` | `#{ram_graph}`と`#{ram_trend}`のもとになる、最近の使用中メモリの計測値です |
| `@ram_revamped_out_<metric>` | オプションモードでの各指標の描画済みの値です |
| `@ram_revamped_ticker_pid` | オプションモードのバックグラウンドのプロセスのIDです |
| `@ram_revamped_option_names` | そのプロセスが1回ごとに1つのtmux呼び出しで読むオプションです |
| `@ram_revamped_percent`などの計測値 | キャッシュした読み取り値で、それぞれ`_ts`のタイムスタンプを持ちます |

<a id="key-bindings"></a>

## キーバインド

| キー | 動作 | オプション |
|:----|:-------|:-------|
| `prefix + M-r` | 詳細のポップアップを開く | `@ram_revamped_popup_key` |

`M-r`は、tmux-revampedファミリーがこのプラグインに割り当てた唯一のキーです。2.0.0より前のポップアップは`prefix + M`で、これはtmuxがマークしたペインの解除に割り当てているキーです。元のキーを使い続けるには次のようにします。

```tmux
set -g @ram_revamped_popup_key 'M'
```

ポップアップは、`btop`か`htop`が入っていればそれを、なければmacOSでは`vm_stat 1`、Linuxでは`free -h -s 1`を実行します。

<a id="how-it-works"></a>

## 仕組み

**ジョブモード、既定の方式。** エントリーポイントは各プレースホルダーを[`src/ram.sh`](src/ram.sh)を呼ぶ`#()`に置き換えます。この呼び出しはキャッシュした値をすぐに出力します。キャッシュが`@ram_revamped_interval`より古ければ、新しい値を計測してtmuxオプションに保存する切り離されたプロセスも起動します。ロック用のオプションにより、計測中に2つ目の計測は始まりません。

**オプションモード。** tmuxは再描画のたびにすべての`#()`を実行し直すため、複数のプラグインがバーを共有するとおよそ1秒に1回になることがあります。`@ram_revamped_render`を`options`にすると、各プレースホルダーは`#{E:@ram_revamped_out_percentage}`のような読み取りになります。サーバーごとに1つのバックグラウンドのプロセスが`@ram_revamped_interval`秒ごとに計測し、ステータス行が使うすべての値を1回のtmux呼び出しで書き込み、クライアントを1回だけ更新します。サーバーが止まると終了し、設定を再読み込みすると置き換わります。

```tmux
set -g @ram_revamped_render 'options'
set -g @ram_revamped_fixed_width 'on'
```

**数値の出どころ。**

| 数値 | macOS | Linux |
|:-------|:------|:------|
| 使用中 | `vm_stat`のactive、wired、compressedのページ | `/proc/meminfo`の`MemTotal`から`MemAvailable`を引いた値 |
| 利用可能 | free、inactive、speculativeのページ | `MemAvailable` |
| スワップ | `sysctl vm.swapusage` | `SwapTotal`と`SwapFree` |
| プレッシャー | 全ページに占めるwiredとcompressedのページの割合 | `/proc/pressure/memory`の`some avg10`で、直近10秒のうちメモリ待ちで止まっていた時間の割合です |
| 内訳 | wired、compressed、inactive、free | 同じ4つの枠に、バッファ、`0`、キャッシュ、free |
| 上位プロセス | `ps axo rss=,comm=` | `ps axo rss=,comm=` |

プロセス名はマシン上の誰でも決められる`ps`から来るため、tmuxが書式として読む前に、名前の中のすべての`#`を二重にします。数値はCロケールで整形するので、小数点にカンマを使うロケールでも`1.5G`と表示します。

<details>
<summary><strong>Nerd Fontのラベル</strong></summary>

```tmux
set -g @ram_revamped_icons 'nerd'
set -g @ram_revamped_percentage_label ''
```

| 指標 | 記号 |
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

## 開発

| コマンド | 内容 |
|:--------|:-------------|
| `make test` | batsのテストスイートを実行します |
| `make lint` | すべてのシェルファイルにshellcheckを実行します |
| `make coverage` | kcovで行カバレッジを測り、95パーセント未満なら失敗します。Linuxで動きます |

テストスイートには`bats-core`とtmuxが必要です。

## ライセンス

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約、`family/` 配下の同じツール、同じ共有ライブラリを持ち、チェックサムの一覧によってバイト単位で同一に保たれています。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。この義務は記憶に頼らず規約に書かれており、`family/bin/sweep` がその作業を行います。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CI、ファミリーのツールを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | **このプラグイン**、RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

### インストールの確認

全メンバーがディスク上にあれば、1 つのコマンドでメンバー間の衝突を報告できます。

```sh
family/bin/doctor --live
```

各メンバーと実行中の tmux サーバーを読み取り、重複したキー、重複したステータスのプレースホルダー、命名規則に合わないオプション、規約のバージョンが古いメンバーを報告します。

<!-- family:end -->
