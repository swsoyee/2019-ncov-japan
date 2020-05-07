# COVID-19 BULLETIN BOARD

![language](https://img.shields.io/github/languages/top/swsoyee/2019-ncov-japan?style=flat-square)
![last commit](https://img.shields.io/github/last-commit/swsoyee/2019-ncov-japan?style=flat-square)
![page views](https://img.shields.io/badge/dynamic/json?url=https://stg.covid-2019.live/ncov-static/stats.json&label=pv&query=$.result.totals.pageviews.all&color=orange&style=flat-square)

[`🇯🇵日本語`](https://github.com/swsoyee/2019-ncov-japan/blob/master/README.md) | [`🇨🇳中文`](https://github.com/swsoyee/2019-ncov-japan/blob/master/README.cn.md) | `🇺🇸English`

The project is a website for real-time visualization of the COVID-19 epidemic in Japan, developed mainly using the `R` language with `shiny` and other open-source packages. It mainly shows various indicators including, but not limited to, PCR test, positive confirmed, hospital discharge and death, as well as trends in each prefecture in Japan, and there are also a variety of charts such as cluster network, new confirmed case in log scale for users' reference.

## Online Access Links

1. [🇺🇸English Version](https://covid-2019.live/en)
2. [🇨🇳中文版](https://covid-2019.live/cn)
3. [🇯🇵日本語バージョン](https://covid-2019.live)

## Snapshot

![index](https://cdn.covid-2019.live/static/capture.jpg)

## About the data

The data used on this site are all public data sets, mainly divided into the following three categories:

1. Real-time data are collected based on the news media: the number of confirmed diagnoses and deaths are from [News Digest](https://newsdigest.jp/pages/coronavirus/) and the values are consistent with the above-mentioned website.
2. Aggregated data announced by the [Ministry of Health, Labour and Welfare](https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html), such as number of PCR tests conducted, hospital discharges, calls to the novel coronavirus call center, etc.
3. Company（[SIGNATE COVID-19 Dataset](https://drive.google.com/drive/folders/1EcVW5JQKMB6zoyfHm8_zLVj---t_hccF)）, dataset collected by other volunteers（[@kenmo_economics](https://twitter.com/kenmo_economics)）and data from open source projects derived from the [Tokyo COVID-19 Information](https://github.com/tokyo-metropolitan-gov/covid19/blob/development/FORKED_SITES.md) (those dataset are updated by the official or the maintainers based on information from the municipality), etc.

Due to the complexity of the data, differences in aggregation time periods or standard issues, there are more or less minor differences in values. Statistical standards vary from media to media, so it is normal for values to vary from site to site. Therefore, all charts and values on this site are for reference only. Please be aware that this website and its management team are not responsible for any problems arising from the secondary use of the contents and materials published on this website.

## Member

### Project Creators

- Data collection, Visualization development: [@swsoyee](https://github.com/swsoyee)  
- Server setting, O & M: [@Bob-Fu](https://github.com/Bob-FU)  

### Contributors

- R-related technical support: [@uribo](https://github.com/uribo)  
- Data automation updates: [@emckk](https://github.com/emc-kk)  

All interested parties are welcome to join this open source project!
