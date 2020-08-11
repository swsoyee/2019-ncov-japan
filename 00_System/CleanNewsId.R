library(data.table)
file_path <- "50_Data/mhlw_houdou.csv"
news <- fread(input = file_path)
news[, id := 1:.N]
fwrite(x = news, file = file_path)
