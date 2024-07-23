month_correct <- function(df) {
  cols <- colnames(df)

  if ("nazev_mop" %in% cols) {
    df <- rename(df, "nazev_obvodu_prahy" = "nazev_mop")
  }
  
  new_cols <- setdiff(c("kod_momc", "kod_obvodu_prahy", "kod_ulice"), cols)
  for (new_col in new_cols) {
    df[[new_col]] <- NA
  }
  
  correct_order <- c("kod_adm",
                     "kod_obce", "nazev_obce",
                     "kod_momc", "nazev_momc",
                     "kod_obvodu_prahy", "nazev_obvodu_prahy",
                     "kod_casti_obce", "nazev_casti_obce",
                     "kod_ulice", "nazev_ulice",
                     "typ_so", "cislo_domovni", "cislo_orientacni", 
                     "znak_cisla_orientacniho", "psc",
                     "souradnice_y", "souradnice_x", "plati_od")
  
  df <- relocate(df, all_of(correct_order))

  return(df)
}