get_date <- function(year, month) {
  assert_int(year, lower = 2013)
  assert_int(month, lower = 1, upper = 12)

  date <-
    "%d-%02d-01" |> 
    sprintf(year, month %% 12 + 1) |> 
    as.Date() |> 
    (\(x) x - 1)()

  return(invisible(date))
}