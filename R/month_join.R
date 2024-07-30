month_join <- function(..., save_file = NULL) {

  dots <- rlang::list2(...)
  if (length(dots) == 1 && rlang::is_bare_list(dots[[1]])) {
    dots <- dots[[1]]
  }

  r <-
    dots |>
    future_map(pl$LazyFrame) |>
    (\(x) {
      pl$with_string_cache({
        pl$
          concat(x)$
            with_columns(
              pl$col("source")$max()$over("kod_adm")$alias("latest_source")
            )$
            drop("source")$
            unique()$
            sort("kod_adm", "plati_od", descending = T)$
            with_columns(
              pl$col("plati_od")$shift(1)$over("kod_adm")$alias("plati_do")
            )$
            with_columns(
              pl$col("plati_do") - pl$duration(days=1)
            )$
            with_columns(
              pl$col("plati_do")$fill_null(pl$col("latest_source"))
            )$
            collect()
      })
    })()

  if (!is.null(save_file)) {
    dir <- dirname(save_file)
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = T)
    }

    r$write_parquet(save_file)
  }

  r <- as_tibble(r)
  return(r)
}
