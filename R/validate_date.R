#' Validace datumu
#'
#' Funkce kontroluje jednotlivé části datumu a to, že pro něj máme
#' dostupná data.
#'
#' @param year Rok se kterým pracujem.
#' @param month Měsíc se kterým pracujem.
#'
#' @return Vytvořené datum (neviditelné)
validate_date <- function(year, month) {
  assert_int(year, lower = 2012)
  assert_int(month, lower = 1, upper = 12)

  source_date <- as.Date(glue("{year}-{month}-01"))
  assert_date(source_date, lower = "2012-12-01")

  return(invisible(source_date))
}