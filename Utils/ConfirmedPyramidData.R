ConfirmedPyramidData <- function(data) {
  # [todo] data.tableの次期バージョンがCRANに登録されたらfifelse()での処理を削除
  # data.table (remote::install_github('Rdatatable/data.table@b1b1832'))
  if (packageVersion("data.table") > "1.12.8") {
    data[, `:=`
    (
      年齢 = data.table::fcase(
        年齢 == "00代", "10歳未満",
        年齢 == "100代", "100歳以上",
        年齢 == 年齢, 年齢
      ),
      性別 = data.table::fcase(
        grepl("男", 性別), "男性",
        grepl("女", 性別), "女性",
        性別 == 性別, 性別
      )
    )]
  } else {
    data[, 年齢 := data.table::fifelse(
      年齢 == "00代",
      "10歳未満",
      年齢
    )]
    data[, 年齢 := data.table::fifelse(
      年齢 == "100代",
      "100歳以上",
      年齢
    )]
    data[, 性別 := data.table::fifelse(
      grepl("男", 性別),
      "男性",
      性別
    )]
    data[, 性別 := data.table::fifelse(
      grepl("女", 性別),
      "女性",
      性別
    )]
  }
  age_class <-
    c(
      "10歳未満",
      paste0(seq.int(10, 90, by = 10), "代"),
      "100歳以上"
    )
  # remove unknown and missing value
  dt <- data[年齢 %in% age_class,
    .SD,
    .SDcols = c("性別", "年齢")
  ]
  age_class <-
    age_class[age_class %in% unique(dt$年齢)]
  dt[, 年齢 := forcats::fct_relevel(年齢, age_class)]
  dt <- dt[, .(count = .N), by = c("性別", "年齢")]
  dt <- reshape(
    data = dt,
    idvar = "年齢",
    timevar = "性別",
    direction = "wide"
  )
  setorder(dt, 年齢)
  setnafill(dt,
    cols = c("count.女性", "count.男性", "count.不明"),
    fill = 0
  )
  dt
}