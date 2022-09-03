library(data.table)

number_check <- function(cases_sum_source, path) {
  cases_sum_source <- cases_sum_source[2:length(cases_sum_source)]
  
  cases <- fread("50_Data/byDate.csv")
  cases_sum_project <- colSums(cases, na.rm = TRUE)
  cases_sum_project <- cases_sum_project[2:length(cases_sum_project)]
  
  # クルーズ船
  cases_sum_project <- append(cases_sum_project, cases_sum_project[length(cases_sum_project)-1], after = 14)
  # 伊客船 
  cases_sum_project <- append(cases_sum_project, cases_sum_project[length(cases_sum_project)], after = 43)
  cases_sum_project <- cases_sum_project[2:length(cases_sum_project) - 2]
  
  names(cases_sum_source) <- names(cases_sum_project)
  
  cases_sum_source - cases_sum_project
}

cases_sum_source <- c(
  20220903,667125,146585,94160,231620,84636,86625,158787,325174,199653,209093,1084089,862418,2965044,1375229,712,202476,111620,142252,99247,87281,179599,257264,436218,1237320,222274,207424,436568,1947736,924259,199307,119055,55581,72265,239575,376819,144131,82116,125932,143393,87856,1003768,143661,191960,149,300786,158041,173574,266624,480655,14,21660
)
number_check(cases_sum_source, "50_Data/byDate.csv")

# death_sum_source <- c(
#   20220607,2072,104,92,198,68,94,223,439,274,321,1625,1780,4524,2209,0,91,93,196,45,68,203,341,416,2076,305,219,721,5085,2234,387,117,20,15,248,489,178,85,127,139,113,1262,106,124,0,294,162,144,202,466,0,8
# )
# number_check(death_sum_source, "50_Data/death.csv")

