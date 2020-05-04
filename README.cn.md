# 新型冠状病毒疫情速报

![language](https://img.shields.io/github/languages/top/swsoyee/2019-ncov-japan?style=flat-square)
![last commit](https://img.shields.io/github/last-commit/swsoyee/2019-ncov-japan?style=flat-square)
![page views](https://img.shields.io/badge/dynamic/json?url=https://stg.covid-2019.live/ncov-static/stats.json&label=pv&query=$.result.totals.pageviews.all&color=orange&style=flat-square)

[`日本語`]() | [`中文`]() | [`English`]()

该项目主要使用`R`语言与`shiny`以及其他软件包开发的用于实时可视化COVID-19在日本的疫情的网站。主要展示包括但不限于检测、确诊、出院和死亡等各项指标以及数据的走势在日本各个都道府县的情况，同时还有密切接触网络图等各种丰富图表供普通用户和轻度的学术研究。

## 在线访问链接

1. [中文版](https://covid-2019.live/cn)
2. [日本語バージョン](https://covid-2019.live)
3. [English Version](https://covid-2019.live/en)

## 网站截屏

![index](https://stg.covid-2019.live/ncov-static/capture.png)

## 关于本站的数据

本站所用数据全为公开数据集，主要分为以下三类：

1. 基于新闻媒体收集的实时数据：确诊数和死亡数来源于[JX通讯社](https://newsdigest.jp/pages/coronavirus/)，速报值和上述网站保持一致；
2. 来源于[厚生劳动省](https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html)发布的汇总数值，如PCR检查、出院人数、咨询热线数等；
3. 公司（如 [SIGNATE COVID-19 Dataset](https://drive.google.com/drive/folders/1EcVW5JQKMB6zoyfHm8_zLVj---t_hccF)）、个人整理而成的数据集（如[@kenmo_economics](https://twitter.com/kenmo_economics)）和各种由[东京都新冠肺炎对策网站](https://github.com/tokyo-metropolitan-gov/covid19/blob/development/FORKED_SITES.md)所衍生出来的开源项目中的数据（这部分数据由自治体官方或衍生网站的作者直接根据自治体的信息进行更新）等

由于各种数据错综复杂，汇总时间周期的不同或者是标准问题，数值方面或多或少存在着些许差异。各家媒体的数据统计标准也各不相同，因此各网站间数值如有不同是个极为正常的现象。因此本站所有图表数值仅供参考使用，超出**参考**的各项其他用途所产生的问题本人概不负责。

## 开发人员

### 项目主创

- 数据搜集、基于`shiny`的可视化开发：[@swsoyee](https://github.com/swsoyee)  
- 搭建服务器、线上网站运维：[@Bob-Fu](https://github.com/Bob-FU)  

### 贡献者

- R相关技术支持：[@uribo](https://github.com/uribo)  
- 数据的自动化更新：[@emckk](https://github.com/emc-kk)  

欢迎各方有志人士加入到本开源项目中。
