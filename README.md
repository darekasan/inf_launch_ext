# inf_launch_ext
INFINITASの起動オプションをいじる

## 注意
このスクリプトを使用することによって生じる問題等の責任を一切負いません<br>
このスクリプトを作成するにあたってゲーム本体の改造やリバースエンジニアリング等の利用規約違反となる行為は行っていませんが、なにがあるかわからないので自己責任にて使用してください。<br>
タスクマネージャーの詳細タブの「コマンドライン」列を見ながらと、あてずっぽうで見つけたコマンドラインオプションをもとに作りました。<br>
<br>
これはランチャーの代わりにこのスクリプトを立ち上げるようにレジストリを変更します。<br>
**スクリプトファイルを削除する前に必ずアンインストール方法をお読みください。**

## なにこれ
INFINITASの起動ページからランチャーを起動せず、このスクリプトを起動することであれこれできます。
- 通常のランチャーの起動
- ランチャーを介さずゲーム本体を起動
- ASIO出力やウィンドウモードを使用して起動

## ウィンドウモード
ウィンドウサイズは1280x720固定のため、ウィンドウサイズを変更するには別の細工が必要です（やり方知ってる人は投げてください）。<br>
あと120Hzにならないらしいですこれも方法知ってる人は（ｒｙ

## ASIO出力について
たぶんARESPEAR用だと思うんですがINFINITASにはASIO出力が付いてるみたいです。<br>
ASUS XONAR AEサウンドカードを使っているならASIOでのオーディオ出力ができます。<br>
ASIOがオープンできなかった場合は「オーディオデバイス作成失敗」というエラーが出るので、**このスクリプトでASIOを選んで正常に起動して音が出ていればASIOで出力できているはず**です。<br>
<br>
他のオーディオインターフェイスでもレジストリのHKLM\SOFTWARE\ASIO\XONAR SOUND CARD(64)にASIOドライバーのCLSIDを入れるとオープンしてくれますが、データフォーマットが固定なのか雑音しか鳴りません。<br>
2ch出力で44.1khzで24bit(ASIOSTInt24LSB)でレイテンシが8ms(352sample)に対応しているものならうまくいくかもしれません。

## インストール
#### 1 [inf_launch_ext.ps1](https://github.com/darekasan/inf_launch_ext/blob/master/inf_launch_ext.ps1)をダウンロード
どこでもいいです。
#### 2 PowerShellを管理者として開く
ダウンロードしたフォルダで「ファイル > Windows PowerShellを開く > Windows PowerShellを管理者として開く」とするとそのフォルダがカレントディレクトリになるので楽です。
#### 3 PowerShell実行ポリシーを変更（スクリプトの実行に必要です）
```
PS C:\Users\darekasan\Downloads> Set-ExecutionPolicy Bypass
```
ダウンロードしたあとにスクリプトファイルのプロパティを開いて、「このファイルへのアクセスはブロックされます」を「許可する」にチェックを入れてあげればRemoteSignedでも動きます。
#### 4 スクリプトを実行
```
PS C:\Users\darekasan\Downloads> .\inf_launch_ext.ps1
currently command: "C:\Games\beatmania IIDX INFINITAS\\launcher\modules\bm2dx_launcher.exe" "%1"

script path: C:\Users\darekasan\Downloads\inf_launch_ext.ps1
game path: C:\Games\beatmania IIDX INFINITAS\

0 : revert to default
1 : set to this script path
3 : copy script file to game directory and set to new script path (recommended)
number->:
```
「3」と入力してEnter。done.と表示されたら閉じます<br>
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
number->:
```

## アンインストール
**この手順を踏まずにスクリプトファイルを削除してしまうとランチャーが起動できなくなって詰みます。**<br>
「3 : copy script file to game directory and set to new script path (recommended)」を選んでインストールした場合はINFINITASのインストール先（C:\Games\beatmania IIDX INFINITASとか）にスクリプトファイルがあるはずです。<br>
管理者権限のPowerShellでスクリプトを実行して、「0 : revert to default」を選ぶとレジストリを元に戻します。<br>
それが済んだらスクリプトファイルを削除しても大丈夫です。<br>
<br>
※どうにもならなくなったときはお手数ですがINFINITASを再インストールしてください。

## 既知の問題
- ウィンドウモードだと120FPS出ないらしい？
- ウィンドウサイズを変更できない（何か別の細工が必要）
