#' Oprava nekonzistencí
#'
#' Funkce opravuje potenciální datové nekonzistence, které mohli v čase vzniknout.
#' Nekonzistence jsou dokumentované v README
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
month_correct <- function(pq, p) {
  if (!is.null(p)) {
    p()
  }

  cpq_file <- glue("{config::get('correct_to')}/{basename(pq)}")
  if (file.exists(cpq_file)) {
    return(cpq_file)
  }

  df <- pl$scan_parquet(pq)
  cols <- df$columns

  if ("nazev_mop" %in% cols) {
    df <- df$rename("nazev_mop" = "nazev_obvodu_prahy")
  }

  if ("kod_mop" %in% cols) {
    df <- df$rename("kod_mop" = "kod_obvodu_prahy")
  }

  new_cols <- setdiff(c("kod_momc", "kod_obvodu_prahy", "kod_ulice"), cols)
  for (new_col in new_cols) {
    df <- df$with_columns(
      pl$lit(NA)$cast(pl$Categorical())$alias(new_col)
    )
  }


  correct_order <- c("kod_adm",
                     "kod_obce", "nazev_obce",
                     "kod_momc", "nazev_momc",
                     "kod_obvodu_prahy", "nazev_obvodu_prahy",
                     "kod_casti_obce", "nazev_casti_obce",
                     "kod_ulice", "nazev_ulice",
                     "typ_so", "cislo_domovni", "cislo_orientacni",
                     "znak_cisla_orientacniho", "psc",
                     "souradnice_x", "souradnice_y",
                     "plati_od", "source")

  df <- df$select(correct_order)
  df <- df$rename("source" = "zdroj")

  df$collect()$write_parquet(file = cpq_file)
  rm(df)
  gc()

  return(cpq_file)
}