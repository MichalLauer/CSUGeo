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
month_join <- function(...) {

  # Umožňuje přijímat jak list(...), tak jenom ... od targets
  dots <- rlang::list2(...)
  if (length(dots) == 1 && rlang::is_bare_list(dots[[1]])) {
    dots <- dots[[1]]
  }

  # Potřebuju to nejnovější schema
  schema <- get_schema("2030-01-01")
  
  pl$with_string_cache({
    # Prvotní spojení do jednoho
    lazy_joined <-
      dots |>
      map(\(x) {
        pl$LazyFrame(x, schema = schema)
      })

    # V případě, že je víc duplicitních záznamu kod_adm <-> plati_do, tak se vezme
    # řádek s méně NA hodnotamy. To nastává hlavně v r. 2017 kdy se přidá kód,
    # ale nezmění platnost
    lazy_joined <- 
      pl$
      concat(lazy_joined)$
      with_columns(
        pl$col("source")$max()$over("kod_adm")$alias("posledni_zaznam")
      )$
      drop("source")$
      unique()$
      with_columns(
        pl$sum_horizontal(pl$all()$is_null())$alias("missing_count")
      )$
      sort("missing_count")$
      collect()$
      group_by(c("kod_adm", "plati_od"))$
      first()$
      drop("missing_count")
  
    # Spočítej od-do kdy záznam platí
    lazy_joined <- 
      pl$
      LazyFrame(lazy_joined)$
      unique()$
      sort("kod_adm", "plati_od", descending = T)$
      with_columns(
        pl$col("plati_od")$shift(1)$over("kod_adm")$alias("plati_do")
      )$
      with_columns(
        pl$col("plati_do") - pl$duration(days=1)
      )$
      with_columns(
        pl$col("plati_do")$fill_null(pl$col("posledni_zaznam"))
      )$
      with_columns(
        pl$col("plati_od")$cast(pl$Date),
        pl$col("plati_do")$cast(pl$Date)
      )$
      collect()
  })
    
  r <-
    as_tibble(lazy_joined) |> 
    relocate(plati_od, .after = souradnice_x) |> 
    relocate(plati_do, .after = plati_od)

  return(r)
}
