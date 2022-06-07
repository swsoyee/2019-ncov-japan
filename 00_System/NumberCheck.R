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
  20220607,365420,59056,35782,88631,30919,28959,64324,160380,91845,95377,554887,452943,1553637,760348,712,73081,37915,57042,36263,33230,74725,102601,173097,550308,83526,91892,205375,983890,429809,92041,42752,15480,17266,100190,160537,46073,22764,49037,40793,28268,431559,53168,60611,149,100717,55337,54432,85519,223910,14,19470
)
number_check(cases_sum_source, "50_Data/byDate.csv")

# death_sum_source <- c(
#   20220607,2072,104,92,198,68,94,223,439,274,321,1625,1780,4524,2209,0,91,93,196,45,68,203,341,416,2076,305,219,721,5085,2234,387,117,20,15,248,489,178,85,127,139,113,1262,106,124,0,294,162,144,202,466,0,8
# )
# number_check(death_sum_source, "50_Data/death.csv")

