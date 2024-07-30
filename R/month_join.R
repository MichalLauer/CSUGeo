#' Spoj měsíce
#'
#' Funkce vezme několik tabulek reprezentující různé měsíce a spojí je do jedné.
#'
#' Při spojování se kontroluje schéma a podle toho, z jakého datumu tabulka je,
#' se bere schéma. Proto různé datumy mohou vrátit různé struktury.
#'
#' Data se redukují a vzniká struktura, kde pro každý kod_adm známe jeho historii
#' a od kdy do kdy platil. Pro každý nejnovější záznam je proměnná plati_do
#' nastavená na datum, kdy jsme záznam naposledy získali. Pokud je např. kod_adm
#' naposledy vykazován v 2021-05, jeho plati_do je nastavené na 2021-05-31.
#'
#' @param ... Jednotlivé [tibble::tibble()] tabulky
#' @param save_file kam spojené tabulky uložit. V případe `NULL` se tabulka neuloží.
#'
#' @return Spojená [tibble::tibble()]
month_join <- function(..., save_file = NULL) {

  # Umožňuje přijímat jak list(...), tak jenom ... od targets
  dots <- rlang::list2(...)
  if (length(dots) == 1 && rlang::is_bare_list(dots[[1]])) {
    dots <- dots[[1]]
  }

  # Potřebuju to nejnovější schema
  schema <- get_schema(2030, 1)

  r <-
    dots |>
    future_map(\(x) {
      pl$LazyFrame(x, schema = schema)
    }) |>
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
    if (!dir.exists(dir) && dir != ".") {
      dir.create(dir, recursive = T)
    }

    r$write_parquet(save_file)
  }

  r <- as_tibble(r)
  return(r)
}
