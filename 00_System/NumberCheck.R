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
  20220711,389593,67580,39862,97600,32930,31751,68619,169200,96528,101516,589937,481896,1668931,811609,712,78249,42013,62772,41215,36031,80424,112713,187327,593940,92068,99209,220772,1053734,461287,98464,47885,18705,25801,107811,174673,51871,25693,52709,49422,32431,472187,62942,70767,149,124660,63077,63201,101050,273893,14,20064
)
number_check(cases_sum_source, "50_Data/byDate.csv")

# death_sum_source <- c(
#   20220607,2072,104,92,198,68,94,223,439,274,321,1625,1780,4524,2209,0,91,93,196,45,68,203,341,416,2076,305,219,721,5085,2234,387,117,20,15,248,489,178,85,127,139,113,1262,106,124,0,294,162,144,202,466,0,8
# )
# number_check(death_sum_source, "50_Data/death.csv")

