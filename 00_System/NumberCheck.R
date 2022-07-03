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
  20220703,383644,64597,38310,94610,32182,30781,66953,165888,94386,98709,573260,467269,1609781,785470,712,76151,40428,60575,39381,34751,78084,108503,180665,574660,88160,95978,213801,1020867,447349,95159,45263,16883,20770,105120,170317,49796,24727,51180,45554,31010,452748,58087,66973,149,113634,58976,59413,94964,257993,14,19894
)
number_check(cases_sum_source, "50_Data/byDate.csv")

# death_sum_source <- c(
#   20220607,2072,104,92,198,68,94,223,439,274,321,1625,1780,4524,2209,0,91,93,196,45,68,203,341,416,2076,305,219,721,5085,2234,387,117,20,15,248,489,178,85,127,139,113,1262,106,124,0,294,162,144,202,466,0,8
# )
# number_check(death_sum_source, "50_Data/death.csv")

