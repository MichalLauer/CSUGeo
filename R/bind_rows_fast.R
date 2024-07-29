bind_rows_fast <- function(..., save_file = NULL) {

  dots <- rlang::list2(...)
  if (length(dots) == 1 && rlang::is_bare_list(dots[[1]])) {
    dots <- dots[[1]]
  }

  r <-
    dots |>
    furrr::future_map(polars::pl$LazyFrame) |>
    (\(x) {
      pl$with_string_cache({
        polars::pl$concat(x)$collect() 
      })
    })()

  if (!is.null(save_file)) {
    dir <- dirname(save_file)
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = T)
    }

    pl$DataFrame(r)$write_parquet(save_file)
  }

  r <- as_tibble(r)
  return(r)
}
