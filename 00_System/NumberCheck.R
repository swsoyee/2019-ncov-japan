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
  20220816,557638,113054,71124,178429,60664,58574,115918,263564,163130,169807,931097,746930,2614911,1223410,712,150326,79052,107422,76825,68169,136558,198184,343292,1000926,165841,166097,363000,1660850,760637,159761,90978,40879,55677,180334,280516,102391,49726,93346,101487,60702,825258,112721,137525,149,240704,122395,130205,200172,426798,14,21132
)
number_check(cases_sum_source, "50_Data/byDate.csv")

# death_sum_source <- c(
#   20220607,2072,104,92,198,68,94,223,439,274,321,1625,1780,4524,2209,0,91,93,196,45,68,203,341,416,2076,305,219,721,5085,2234,387,117,20,15,248,489,178,85,127,139,113,1262,106,124,0,294,162,144,202,466,0,8
# )
# number_check(death_sum_source, "50_Data/death.csv")

