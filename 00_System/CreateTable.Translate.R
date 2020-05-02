library(jsonlite)
library(purrr)

lang <- jsonlite::read_json(paste0("www/lang/translation.json"))

data <- fread(file = paste0(DATA_PATH, "Generated/resultSummaryTable.ja.csv"), sep = "@", quote = F)

ja <- lang$translation %>% map_chr(1)
cn <- lang$translation %>% map_chr(2)
en <- lang$translation %>% map_chr(3)

for (language in c("en", "cn")) {
  dt <- copy(data)
  for (i in unique(data$group)) {
    dt[group == i, group := eval(as.name(language))[which(i == ja)]]
  }
  fwrite(x = dt, file = paste0(DATA_PATH, paste0("Generated/resultSummaryTable.", language, ".csv")), sep = "@", quote = F)
}
