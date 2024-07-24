bind_rows_fast <- function(..., save_file = NULL) {

  r <-
    list(...) |>
    furrr::future_map(data.table::as.data.table) |>
    data.table::rbindlist(fill = TRUE) |>
    dplyr::as_tibble()

  if (!is.null(save)) {
    dir <- dirname(save_file)
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = T)
    }

    pl$DataFrame(r)$write_parquet(save_file)
  }
  return(r)
}