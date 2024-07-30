get_date <- function(year, month) {
  assert_int(year, lower = 2013)
  assert_int(month, lower = 1, upper = 12)

  if (month == 12) {
    date <- as.Date(glue("{year}-{month}-31"))
  } else {
    date <-
      "%d-%02d-01" |> 
      sprintf(year, month %% 12 + 1) |> 
      as.Date() |> 
      (\(x) {
        x - 1
      })()
  }
  
  return(as.Date(date))
}
