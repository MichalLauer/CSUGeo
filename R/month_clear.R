month_clear <- function(year, month) {
  date <- ym(glue("{year}-{month}")) %m+% months(1) - days(1)

  f <- glue("{config::get('download_to')}/{year}/{month}")
  if (dir.exists(f)) {
    unlink(f, recursive = TRUE)
  }

  f <- glue("{config::get('extract_to')}/{date}.parquet")
  if (file.exists(f)) {
    file.remove(f)
  }

  f <- glue("{config::get('correct_to')}/{date}.parquet")
  if (file.exists(f)) {
    file.remove(f)
  }
}

month_clear(2015, 6)