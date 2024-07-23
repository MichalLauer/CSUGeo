bind_rows_fast <- function(x) {
  if (!is.list(x)) {
    x <- list(x)
  }

  r <-
    x |>
    furrr::future_map(data.table::as.data.table) |>
    data.table::rbindlist(fill = TRUE) |>
    dplyr::as_tibble()

  return(r)
}