# ASIO出力について（書きかけ）
長くなりそうなのでREADMEから分けました。ASIOで出力するために必要な条件や、サウンドカード周りのお話を書きます。

## ASIO

簡単に言うと「WASAPI」や「DirectSound」とは別のオーディオ出力の規格です。オーディオ制作向けのオーディオインターフェースに広く採用され、一部のUSBDAC等のオーディオ機器でも対応しています。<br>
もともとがプロ向けの規格ということもあり、オーディオデバイスが持つ本来の性能を発揮できるほか、環境によってはWASAPI排他モード以上の低遅延や安定性を確保できる可能性があります。

ちなみに、ASIO対応のオーディオインターフェースでWASAPI排他モードのときに雑音しか鳴らない場合はバッファサイズを128samples以下にするといいらしい。[@db_chinpei](https://twitter.com/db_chinpei/status/1291380630236749824)氏

## Xonar AEについて

ASUS製の内蔵サウンドカード(PCIe接続)です。PCIe接続ではありますが、カード上のUSBホストチップを介して接続するので実質USBオーディオです。<br>
コナミ謹製ゲーミングPCであるARESPEARに採用されており、INFINITASの隠されたASIO出力モードはARESPEAR及びXonar AEのために搭載されているものと推測されます。<br>
Xonar AEが搭載されているPCであれば、inf_launch_extでASIO出力を選ぶだけでASIOで音を出すことができます。

## Xonar AE以外

Xonar AE以外のサウンドカードでも、レジストリを書き換えて他のASIOドライバーを「XONAR SOUND CARD(64)」に偽装するとINFINITASが読み込んでくれます。<br>
運良くXonar AEと同じデータフォーマットに対応していれば正常に音が鳴り、そうでない場合は雑音しか出ません。<br>
私の環境（Xonar AE）では44.1khzで24bit(ASIOSTInt24LSB)でレイテンシが8ms(352sample)でした。サンプリングレートとビット深度が合っていれば問題ないらしい（要検証）。

持ってるデバイスが対応してるフォーマットは[ASIO caps](https://web.archive.org/web/20190409235618/http://otachan.com:80/ASIO%20caps.html)で調べましょう。<br>
ビット深度などの設定がASIOコントロールパネルにある場合もあるようなので、ASIO capsやDAWなどから開いて確認してみましょう。

### レジストリを書き換える

レジストリエディタの使い方は自分で調べてください。
レジストリエディタで「HKEY_LOCAL_MACHINE\SOFTWARE\ASIO」を開くと、インストールされているASIOドライバーの名前が表示されると思います。<br>
![レジストリエディタ](https://raw.githubusercontent.com/darekasan/inf_launch_ext/master/doc_img/regedit1.png) <br>
ここでは「BRAVO-HD」をINFINITASから使えるようにしてみます。他のASIOドライバーを偽装させるときはここを読み替えてください。

まず、キー「ASIO」の中にキーを作成します。名前は「XONAR SOUND CARD(64)」とします。
※既に「XONAR SOUND CARD(64)」が存在する場合は既存のキーの名前を「_XONAR SOUND CARD(64)」などにしてよけておきます（削除・上書きしてしまうと元に戻す時に困ります！）。

作成したキーに値を2つ追加します。CLSIDのデータには「BRAVO-HD」のCLSIDを書いておきます。
|名前|種類|データ|
|----|----|----|
|CLSID|REG_SZ(文字列値)|(ここにBRAVO-HDのCLSID)|
|Description|REG_SZ(文字列値)|XONAR SOUND CARD(64)|

これでinf_launch_extでASIOを選ぶと、INFINITASがBRAVO-HDを使ってくれるはずです。データフォーマット不一致などによる**大音量の雑音に備えて音量は予め絞っておきましょう。**

前述の通り、運が良けりゃ音が出ます。音が出なかったり「オーディオデバイス作成失敗」で起動できなかったりした場合は仕様と設定を確認しましょう。



## サウンドカード
同じチップを採用する別の製品のドライバを流用することでASIOが使えるパターンがあるようです。情報求む！<br>
ドライバーの入手先や設定方法、ハマったところなども書くとよき。
|サウンドカード|ドライバ|動作|備考|
|----|----|----|----|
|Realtek HD Audio|？|？|設定にコツがいるみたい？|
|Pioneer LX-89|公式|OK|AVアンプ ASIOコンパネでビット深度24bit指定 [@db_chinpei](https://twitter.com/db_chinpei/status/1295021180718444544/)氏|
|エレコム EHP-AHR192|[DS-200 ソフトウェア・パッケージ](https://www.soundfort.jp/download/)|OK|バッファサイズ3msで安定動作 SA9123チップ microUSB(OTG)接続 [CSスレpart679 >>353](https://medaka.5ch.net/test/read.cgi/otoge/1596990646/353)|
|MOTU 828mk2FW|公式|OK|FireWire接続|
|SoundBlaster X-Fi XtremeGamer|公式|？|PCI接続|
|NI Komplete Audio 6無印|公式|NG||
|Roland DUO-CAPTURE|公式|NG||
|Roland UA-25|公式|？|Win10では要inf書き換え&署名無効|
|Roland UA-101|公式|NG|[@db_chinpei](https://twitter.com/db_chinpei/status/1295021180718444544/)氏|
|Roland JD-Xi|公式|？|USBオーディオ付きのシンセ|
|Griffin iMic|[非公式](https://www.usb-audio.com/download/)|NG||


## 遅延について
いくつかのサウンドカードでASIO/排他/共有の3つのモードで遅延を検証したそうです。環境構築の参考にしてみては？<br>
特にXonar AEの結果は興味深いです。

[https://twitter.com/db_chinpei/status/1297600581758926848](https://twitter.com/db_chinpei/status/1297600581758926848)<br>
[https://twitter.com/db_chinpei/status/1304114822133420033](https://twitter.com/db_chinpei/status/1304114822133420033)
