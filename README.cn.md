# 新型冠状病毒疫情速报

![language](https://img.shields.io/github/languages/top/swsoyee/2019-ncov-japan?style=flat-square&logo=r)
![last commit](https://img.shields.io/github/last-commit/swsoyee/2019-ncov-japan?style=flat-square)
[![eRum2020::CovidR](https://badgen.net/https/runkit.io/erum2020-covidr/badge/branches/master/bulletin-board-japan?cache=300)](https://milano-r.github.io/erum2020-covidr-contest/bulletin-board-japan.html)
[![DOI](https://img.shields.io/badge/DOI-10.3233%2FSHTI210629-blue)](https://doi.org/10.3233/SHTI210629)

[`🇯🇵日本語`](https://github.com/swsoyee/2019-ncov-japan/blob/master/README.md) | `🇨🇳中文` | [`🇺🇸English`](https://github.com/swsoyee/2019-ncov-japan/blob/master/README.en.md)

该项目主要使用`R`语言与`shiny`以及其他的开源软件包开发的用于实时可视化COVID-19在日本的疫情的网站。主要展示包括但不限于检测、确诊、出院和死亡等各项指标以及数据的走势在日本各个都道府县的情况，同时还有密切接触网络图等各种丰富图表供用户参考。

## 在线访问链接

由于日本政府不再强行要求地方自治体完整上报新冠感染人数，我们已经很难把握真实的感染情况。因此我们在2022年12月17日下线了在线版网站。

## 网站截屏

![index](resources/cp_screenshot.png)

## 关于本站的数据

本站所用数据全为公开数据集，主要分为以下三类：

1. 基于新闻媒体收集的实时数据：确诊数和死亡数来源于[JX通讯社](https://newsdigest.jp/pages/coronavirus/)，速报值和上述网站保持一致；
2. 来源于[厚生劳动省](https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html)发布的汇总数值，如PCR检查、出院人数、咨询热线数等；
3. 公司（如 [SIGNATE COVID-19 Dataset](https://drive.google.com/drive/folders/1EcVW5JQKMB6zoyfHm8_zLVj---t_hccF)）、个人整理而成的数据集（如[@kenmo_economics](https://twitter.com/kenmo_economics)）和各种由[东京都新冠肺炎对策网站](https://github.com/tokyo-metropolitan-gov/covid19/blob/development/FORKED_SITES.md)所衍生出来的开源项目中的数据（这部分数据由自治体官方或衍生网站的作者直接根据自治体的信息进行更新）等。

由于各种数据错综复杂，汇总时间周期的不同或者是标准问题，数值方面或多或少存在着些许差异。各家媒体的数据统计标准也各不相同，因此各网站间数值如有不同是个极为正常的现象。因此本站所有图表数值仅供参考使用。此外，对于本站所发表内容和资料等进行的二次使用所产生的各项问题，本站以及运营团队概不负责，敬请知悉。

## Message from the Team

Since COVID-19 was reported to the World Health Organization in December of 2019, the pandemic has spread globally, causing an unprecedented social, behavioral, and economic impact across the world. In Japan, the first COVID-19 case was identified on 15 Jan 2020 and subsequently the disease has since transmitted across different prefectures to the entire country.  
In response to this public health emergency, this COVID-19 dashboard has been made available to the Japanese population since 1 February 2020.  Featuring multi-dimensional data visualization tools, this platform allows the general public to easily understand the evolution of the pandemic. As of 1 year of this site’s operation, it has already attracted more than 20 million visits (98% of them were initiated from Japan locally).  
We believe that being able to efficiently inform the public about COVID-19 case situation allows the public to be vigilant, and that plays an essential role in containing and controlling the pandemic (WHO prevention guide). As efforts toward mass vaccination unfold, there are hopeful signs of an improvement in the situation. In the meantime, our site will continue to serve as essential disease communication tool and information hub until the pandemic ends.

## 开发人员

### 项目主创

- 数据搜集、基于 `shiny` 的可视化开发：[@swsoyee](https://github.com/swsoyee)  
- 搭建服务器、线上网站运维：[@Bob-Fu](https://github.com/Bob-FU)  
- 学术顾问：黄穗儿博士，[Twitter: @zoiesywong](https://twitter.com/zoiesywong) / [Github: @zoiewong](https://github.com/zoiewong)

### 贡献者

- R相关技术支持：[@uribo](https://github.com/uribo)  
- 数据的自动化更新：[@emckk](https://github.com/emc-kk)  
- 日语本地化：[@kilisame4](https://github.com/kilisame4)  

欢迎各方有志人士加入到本开源项目中。

### [引用](./CITATION.cff)

Su, W., Fu, W., Kato, K., & Wong, Z. S. (2021). “Japan LIVE Dashboard” for COVID-19: A Scalable Solution to Monitor Real-Time and Regional-Level Epidemic Case Data. Studies in Health Technology and Informatics, 286(1), 21–25. https://doi.org/10.3233/SHTI210629
