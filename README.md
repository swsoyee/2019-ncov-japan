# 新型コロナウイルス感染速報

![language](https://img.shields.io/github/languages/top/swsoyee/2019-ncov-japan?style=flat-square)
![last commit](https://img.shields.io/github/last-commit/swsoyee/2019-ncov-japan?style=flat-square)
![page views](https://img.shields.io/badge/dynamic/json?url=https://cdn.covid-2019.live/static/stats.json&label=pv&query=$.result.totals.pageviews.all&color=orange&style=flat-square)

`🇯🇵日本語` | [`🇨🇳中文`](https://github.com/swsoyee/2019-ncov-japan/blob/master/README.cn.md) | [`🇺🇸English`](https://github.com/swsoyee/2019-ncov-japan/blob/master/README.en.md)

このプロジェクトは、`R言語`で`shiny`および他のオープンソースパッケージを用いて、日本のCOVID-19発生状況をリアルタイムで可視化しているサイトです。主に検査人数・感染数・退院数・死亡数などの各種指標およびその傾向を、全国または都道府県別で示しており、クラスターネットワーク、対数グラフなど多数のグラフが用意されております。

## オンラインアクセスリンク

1. [🇯🇵日本語バージョン](https://covid-2019.live)
2. [🇨🇳中文版](https://covid-2019.live/cn)
3. [🇺🇸English Version](https://covid-2019.live/en)

## スクリーンショット

![index](https://cdn.covid-2019.live/static/capture.jpg)

### サイトのデータについて

当サイトで使用しているデータは全て公開されているデータで、主に以下の3つに分類されます。

1. ニュースメディアによるリアルタイムデータ：感染者数・死亡者数の速報値は[JX通信社](https://newsdigest.jp/pages/coronavirus/)と一致しています；
2. PCR検査人数、退院者数、コールセンターの受付回数などのデータは[厚生労働省](https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html)の毎日更新しているページからデータを取得しています；
3. 会社（[SIGNATE COVID-19 Dataset](https://drive.google.com/drive/folders/1EcVW5JQKMB6zoyfHm8_zLVj---t_hccF)）、個人が整理しているデータセット（[@kenmo_economics](https://twitter.com/kenmo_economics)）または[東京都新型コロナウイルス対策サイト](https://github.com/tokyo-metropolitan-gov/covid19/blob/development/FORKED_SITES.md)から派生した自治体または個人がメンテナンスをしているサイトから自治体のデータを取得し、本サイトで異なる可視化手法でデータの再利用しています。

各種データセットの集計時間や、集計標準など異なるため、数値周りには多少のズレが発生する可能性があります。各メディアの集計方法も異なるため、サイトの間にデータが一致しないことも珍しくない。従って、掲載された情報の内容の正確性については一切保証しません。また、当サイトに掲載された情報・資料を利用、使用、ダウンロードするなどの行為に関連して生じたあらゆる損害等についても、理由の如何に関わらず、本サイトおよび運営メンバーは一切責任を負いません。予めご了承してください。

## 開発メンバー

### 主催者

- データ収集、`shiny`を利用した可視化開発：[@swsoyee](https://github.com/swsoyee)  
- インフラ、サーバーのメンテナンス：[@Bob-Fu](https://github.com/Bob-FU)  

### 貢献者

- Rの技術サポート：[@uribo](https://github.com/uribo)  
- データの自動化更新：[@emckk](https://github.com/emc-kk)  

協力できる有志がいればご気軽に連絡してください。Rのことがわからなくても貢献できることは必ずありますmm。  
> 例えば日本語の文言の修正、データセットの収集など。
