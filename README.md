# inf_launch_ext
INFINITASの起動オプションをいじる

For USTA(Korean) Version: 
[Coldlapse/inf_launch_ext_kr](https://github.com/Coldlapse/inf_launch_ext_kr)

## 2025/09/25追記

INFINITASをSteamに非Steamゲームとして追加するための機能を追加しました。詳細は後述。

複数あったインストール時のオプションを1つに絞りました。INFINITASのインストール先にコピーして実行するのが既定の動作となります。

新機能を使う場合は再度インストールしてください。

## 2023/09/21追記

IIDXから離れてて最近の動向追えてないしメンテナンスもしてないので、もっと良いソリューションがあるかもです。

素晴らしい機能拡張版フォークたち

- [kinetic-flow/infzoom](https://github.com/kinetic-flow/infzoom)
  - プレー画面を拡大できる！
  - [chinimuruhi/infzoom-for-special-k](https://github.com/chinimuruhi/infzoom-for-special-k/)
    - 外部ツール使用でウィンドウ/ボーダーレスでも120FPS出るみたいです

## 注意

このスクリプトを使用することによって生じる問題等の責任を一切負いません<br>
このスクリプトを作成するにあたってゲーム本体の改造やリバースエンジニアリング等の利用規約違反となる行為は行っていませんが、なにがあるかわからないので自己責任にて使用してください。<br>
なお、作者及びこのスクリプトはKonami Amusementと一切関係ありません。

これはランチャーの代わりにこのスクリプトを立ち上げるようにレジストリを変更します。<br>
**スクリプトファイルを削除する前に必ずアンインストール方法をお読みください。**

## なにこれ

INFINITASの起動ページからランチャーではなくこのスクリプトを起動するようにし、コマンドラインオプションを付け加えてゲームを起動できるようにするツールです。

できること
- 通常のランチャーの起動
- ランチャーを介さずゲーム本体を起動
- ASIO出力やウィンドウモードを使用して起動
- ウィンドウサイズの変更、ボーダーレス化
- Steamからの起動
- 前回の設定の読み込み

## ASIO出力について

ARESPEARに採用されていることでも知られるASUS Xonar AEならこのスクリプトでASIOを使うことができます。WASAPI排他モードを超える低遅延や安定性を期待できそうです。<br>
それ以外でもある条件を満たせば使えます。詳しくは[ASIOについて](https://github.com/darekasan/inf_launch_ext/blob/master/asio.md)を参照。

## インストール

#### 1 [inf_launch_ext.ps1](https://github.com/darekasan/inf_launch_ext/blob/master/inf_launch_ext.ps1)をダウンロード

どこでもいいです。

#### 2 PowerShellを管理者として開く

ダウンロードしたフォルダで「ファイル > Windows PowerShellを開く > Windows PowerShellを管理者として開く」とするとそのフォルダがカレントディレクトリになるので楽です。<br>
![エクスプローラーの左上](https://raw.githubusercontent.com/darekasan/inf_launch_ext/master/doc_img/explorer.png) <br>
※「ダウンロード」「デスクトップ」「ドキュメント」の直下では選択できないことがあるので、その場合はフォルダを作成してそこに入れるなどして対処しましょう。もちろん、別の方法でPowerShellを立ち上げて実行してもOKです。

#### 3 PowerShell実行ポリシーを変更（スクリプトの実行に必要です）

```
PS C:\Users\darekasan\Downloads> Set-ExecutionPolicy Bypass
```
※Bypassにしたくない人はダウンロードしたあとにスクリプトファイルのプロパティを開いて、「このファイルへのアクセスはブロックされます」を「許可する」にチェックを入れてあげればRemoteSignedでも動きます。

#### 4 スクリプトを実行

```
PS C:\Users\darekasan\Downloads> .\inf_launch_ext.ps1
currently command: "C:\Games\beatmania IIDX INFINITAS\\launcher\modules\bm2dx_launcher.exe" "%1"

script path: C:\Users\darekasan\Downloads\inf_launch_ext.ps1
game path: C:\Games\beatmania IIDX INFINITAS\

0 : revert to default
1 : copy script file to game directory and set to new script path
number->:
```
「1」と入力してEnter。done.と表示されたら閉じます<br>
スクリプトファイルがINFINITASのインストール先にコピーされ、bm2dxinfのURLスキームのコマンドがランチャーではなくこのスクリプトに変更されます。<br>

## 使用方法

いつもどおりWebページから起動すると、オプション選択画面が表示されるので数字を入力してEnterキーを押します。<br>
アップデートが必要なときは0を選んでランチャーを起動します。
```
Please select option.
0 : Launcher
1 : Normal
2 : Normal + window mode
3 : ASIO
4 : ASIO + window mode
5 : Run from Steam
number(last time: 2):
```
なにも指定しないでEnterを押すと前回起動時のオプションで起動します。<br>
もし、bm2dx.exeのプロパティの互換性タブで「管理者としてこのプログラムを実行する」にチェックを入れているなら外してください。うまく動きません。

### ウィンドウモードの使い方

ウィンドウモードでは実行中にウィンドウの位置やサイズの変更、ボーダーレス化などの設定が行えます。<br>
120Hzで出力可能なモニターを使っている場合(144Hzなども含む)はWindowsのディスプレイ設定でリフレッシュレートを「120Hz」にしたほうがよさげです。<br>
```
window mode setting
example:
window size -> 1280x720
window position -> 100,100
Press enter key to switch to Borderless window.
 : 854x480
 : 10,10
 :
```
ウィンドウのサイズや位置の指定はそれぞれ「1280x720」「100,100」といった書式で行うことができます。<br>
何も入力せずEnterを押すとボーダーレスウィンドウになります。これらの設定は次回起動時に引き継がれます。

ボーダーレスウィンドウをモニターの解像度と同じ大きさにすると「排他じゃないイマドキのフルスクリーン」にできていい感じ。

### Steamから起動する方法

INFINITASを非Steamゲームとして追加し、Steamオーバーレイや入力のリマップなどの機能が使えるようになりました。上級者向けの機能です。

ブラウザでゲーム起動クリック→inf_launch_ext→InfProxy.exe→（SteamのURLスキーム）→Steam→InfProxy.exe→inf_launch_ext→INFINITAS　という仕組みになっています。

Webページから起動して「5 : Run from Steam」を選ぶと初期設定に入り、INFINITASのインストール先にInfProxy.exeが作成されます。このInfProxy.exeを非SteamゲームとしてSteamに追加してください。そして、デスクトップにショートカットを作成して、ショートカットのプロパティを開き「steam://rungameid/」から始まるURLをコピーしてinf_launch_extに貼り付けると初期設定が完了し、Steam経由でinf_launch_extを起動します。

次回以降は「5 : Run from Steam」を選ぶと、Steam経由でinf_launch_extが再び起動します。

## アンインストール

**この手順を踏まずにスクリプトファイルを削除してしまうとランチャーが起動できなくなって詰みます。**<br>
「1 : copy script file to game directory and set to new script path」を選んでインストールした場合はINFINITASのインストール先（C:\Games\beatmania IIDX INFINITASとか）にスクリプトファイルがあるはずです。<br>
管理者権限のPowerShellでスクリプトを実行して、「0 : revert to default」を選ぶとレジストリを元に戻します。<br>
それが済んだらinf_launch_ext.ps1とconfig.jsonを削除しても大丈夫です。

※どうにもならなくなったときはお手数ですがINFINITASを再インストールしてください。

## 既知の問題

- ウィンドウサイズを縦横整数倍以外にすると汚い（補間処理がないため）<br>
補間処理を入れようと思うと間に挟まってレンダリング結果横取りして別のウィンドウに表示するくらいしか方法が無いので、気になる方は~~DxWndとかで窓化したほうがいいです。~~ DxWndは64bitバイナリ非対応なので新INFINITASじゃ使えないんですね
- 導入がむずい<br>
「何をやってるのか全然わからん」って人は手を出さないほうが無難？
- 120FPS出ない
  - 外部ツール要る模様
