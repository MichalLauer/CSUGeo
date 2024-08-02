month_prepare_enums <- function(...) {

  # Umožňuje přijímat jak list(...), tak jenom ... od targets
  dots <- rlang::list2(...)
  if (length(dots) == 1 && rlang::is_bare_list(dots[[1]])) {
    dots <- dots[[1]]
  }

  schema <- get_schema(2030, 1)
  valid_df <-
    dots |>
    keep(function(x) {
      src <- unique(pull(x, "source"))

      as.Date(src) > as.Date("2018-01-01")
    }) |>
    map(\(x) {
      pl$
        LazyFrame(x, schema = schema)$
        select("kod_obce",         "nazev_obce",
               "kod_momc",         "nazev_momc",
               "kod_obvodu_prahy", "nazev_obvodu_prahy",
               "kod_casti_obce",   "nazev_casti_obce",
               "kod_ulice",        "nazev_ulice")
    }) |>
    (\(x) {
      pl$with_string_cache({
        pl$
          concat(x)$
          unique()$
          collect()
      })
    })()

    return(dplyr::as_tibble(valid_df))
}
