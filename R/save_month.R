save_month <- function(joined, save_dir = "data-joined") {
  date <- get_date(joined$year, joined$month)
  if (!dir.exists(save_dir)) {
    dir.create(save_dir)
  }
  path <- glue("{save_dir}/{joined$year}_{joined$month}.parquet")

  joined$data$write_parquet(path)

}