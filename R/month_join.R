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
month_join <- function(A, B) {

  # Tohle funguje, pl$with_string_cache nepoužívat
  pl$with_string_cache({
    dA <- pl$read_parquet(A)
    dB <- pl$read_parquet(B)

    d <- pl$
      concat(dA, dB)$
      sort(c("kod_adm", "plati_od"), descending = TRUE)$
      with_columns(
        pl$col("plati_od")$shift(1)$dt$offset_by("-1d")
        $over(c("kod_adm"))
        $fill_null(pl$col("zdroj"))
        $alias("plati_do")
      )

  })

  correct_order <- c("kod_adm",
                     "kod_obce", "nazev_obce",
                     "kod_momc", "nazev_momc",
                     "kod_obvodu_prahy", "nazev_obvodu_prahy",
                     "kod_casti_obce", "nazev_casti_obce",
                     "kod_ulice", "nazev_ulice",
                     "typ_so", "cislo_domovni", "cislo_orientacni",
                     "znak_cisla_orientacniho", "psc",
                     "souradnice_x", "souradnice_y",
                     "plati_od", "plati_do", "zdroj")

  df <- df$select(correct_order)

  return(df)
}
