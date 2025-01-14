#' Získání URL
#'
#' Funke z roku a měsíce vytvoří odkaz na cuzk.cz
#'
#' @param year Rok, pro který získat data.
#' @param month Měsíc, pro který získat data.
#'
#' @return URL odkaz
month_url <- function(date) {
  date <- as.Date(date)

  base_url <- glue(
    "https://vdp.cuzk.cz/vymenny_format/csv/{format(date, '%Y%m%d')}_OB_ADR_csv.zip"
  )

  return(base_url)
}