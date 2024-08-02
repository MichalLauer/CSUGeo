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
  assert_true(length(year) == length(month))
  walk2(year, month, .validate_date)

  dates <-
    map2_vec(year, month, function(y, m) {
      if (m == 12) {
        date <- as.Date(glue("{y}-{m}-31"))
      } else {
        date <-
          "%d-%02d-01" |>
          sprintf(y, m %% 12 + 1) |>
          as.Date() |>
          (\(x) {
            x - 1
          })()
      }

      return(date)
    })

  return(invisible(as.Date(dates)))
}

#' Validace datumu
#'
#' Funkce kontroluje jednotlivé části datumu a to, že pro něj máme
#' dostupná data.
#'
#' @param year Rok se kterým pracujem.
#' @param month Měsíc se kterým pracujem.
#'
#' @return Vytvořené datum (neviditelné)
.validate_date <- function(year, month) {
  assert_int(year, lower = 2012)
  assert_int(month, lower = 1, upper = 12)

  source_date <- as.Date(glue("{year}-{month}-01"))
  assert_date(source_date, lower = "2012-12-01")

  return(invisible(source_date))
}