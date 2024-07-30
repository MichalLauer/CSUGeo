#' Získej datum
#'
#' Jednotlivé .zip soubory jsou generované vždy k poslednímu dni v měsíci. Funkce
#' proto z vybraného roku a měsíce vrátí poslední den v daném měsíci
#'
#' Funkce vrací datum neviditelně, protože
#'
#' @param year Rok
#' @param month Měsíc
#'
#' @return Poslední den v měsíci
get_date <- function(year, month) {
  validate_date(year, month)

  if (month == 12) {
    date <- as.Date(glue("{year}-{month}-31"))
  } else {
    date <-
      "%d-%02d-01" |>
      sprintf(year, month %% 12 + 1) |>
      as.Date() |>
      (\(x) {
        x - 1
      })()
  }

  return(invisible(as.Date(date)))
}

