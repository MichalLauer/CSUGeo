bind_rows_fast <- function(..., save_file = NULL) {

  r <-
    list(...) |>
    furrr::future_map(polars::pl$LazyFrame) |>
    (\(x) polars::pl$concat(x)$collect() )()

  if (!is.null(save_file)) {
    dir <- dirname(save_file)
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = T)
    }

    pl$DataFrame(r)$write_parquet(save_file)
  }
  return(r)
}