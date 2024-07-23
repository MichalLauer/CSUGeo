month_get <- function(year, month, path) {
  csvs <- list.files(path=path, pattern="\\.csv$", full.names = T)

  merged <- month_merge(csvs=csvs, year=year, month=month)
  month_save(year=year, month=month, df=merged)
  merged <- as_tibble(merged)
  
  return(merged)
}