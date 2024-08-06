#' Vytvoř měsíční tabulku
#'
#' Spojí několik .csv souborů do jedné tabulky.
#'
#' @param dir Adresa, kde se nacházejí .csv soubory
#' @param year Rok, který se spojuje
#' @param month Měséc. která se spojuje
#' @param save_dir Kam spojený měsíc uložit. V případe `NULL` se neuloží.
#'
#' @return Spojená [tibble::tibble()] tabulka.
month_merge <- function(zip) {

  # Unzip
  dir <- dirname(zip)
  unzip(zip,
        junkpaths = TRUE,
        overwrite = T,
        exdir = dir)

  # Read
  date <- as.Date(tools::file_path_sans_ext(basename(zip)))
  cols <- get_schema(date, type = "csv")
  csvs <- list.files(dir, full.names = T, pattern = "\\.csv$")

  # Join
  joined <-
    csvs |>
    vroom(delim = ";",
          col_types = cols,
          locale = locale(encoding = "Windows-1250"),
          show_col_types = F,
          .name_repair = function(x) {
            x |>
              snakecase::to_snake_case() |>
              iconv(from = 'UTF-8', to = 'ASCII//TRANSLIT')
          }) |>
    mutate(source = date,
           plati_od = as.Date(plati_od))

  # Remove csvs
  # Háže Permission denied, unlink nepomohl
  walk(csvs, file.remove)

  return(joined)
}
