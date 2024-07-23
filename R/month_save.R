month_save <- function(year, month, df, save_dir = "data-joined") {
  date <- get_date(year, month)
  if (!dir.exists(save_dir)) {
    dir.create(save_dir)
  }
  path <- glue("{save_dir}/{year}_{month}.parquet")

  df$write_parquet(path)
}