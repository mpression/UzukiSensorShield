# UzukiSensorShield サンプルコード
UzukiSensorShield サンプルコードは、Konashi2.0のアップデートに対応した、Uzuki-IoT Sensor Shield for Konashi & Arduino用のObjective-Cサンプルコードです。
このサンプルコードで、以下の３つのセンサのデータを取得、表示します。

## ソースの取得・ビルド方法
```
git clone https://github.com/mpression/UzukiSensorShield
cd UzukiSensorShield/konashiSensorShield
pod install
open konashiSensorShield.xcworkspace
# xcode上でビルド、実行
```

## Si1145近接センサのメソッドを追加しました。

  ・Si1145 : 近接・照度
  ・Si7013 : 温度・湿度
  ・ADXL345 : ３軸加速度

## Uzuki-IoT Sensor Shield for Konashi & Arduino
![](http://www.m-pression.com/image/image_gallery?uuid=2c604bd7-a94c-410a-84ec-3b17d5175fa2&groupId=10157&t=1417437915653)

Uzuki - IoT Sensor Shield for Konashi & Arduino は、ユカイ工学株式会社が開発したiPhone/iPadのためのフィジカル・コンピューティングツールキット Konashi(こなし)にI2Cで接続できる、マクニカが開発したIoTセンサーシールドです。Uzukiは、Konashiだけでなく、ArduinoのシールドとしてもI2Cで接続することができます。
Uzukiには、3軸加速度センサ、温湿度センサ、近接照度UV指数センサが搭載されています。これによりシールドを設置した周囲の温度、湿度、照度、赤外線レベル、UV指数等の環境変数や、振動・衝撃の検知や近接センサによる物体検出等の情報を、Konashi経由でiOSデバイスで利用できます。また、Groveコネクタを介して、市販されている各種I2Cセンサを外部接続することもできます。
Konashiは、iOSからハードウェアにアクセスする開発環境を提供し、マイコン側のファームウェア開発をすることなくソフトウェアエンジニア・デザイナ・アーティストが手軽にプロトタイピングを行うツールとして開発されました。
KonashiのシールドとしてIoT Sensor Shield Uzukiを接続すれば、はんだ付けなしに、各種センサデータを取得するアプリケーションで容易に利用することができます。
Konashiの詳細については、ユカイ工学が提供しているWebページ http://konashi.ux-xu.com/documents
をご参照ください。
