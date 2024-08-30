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
month_extract <- function(zip, p = NULL) {
  if (!is.null(p)) {
    p()
  }
  checkmate::assert_file_exists(zip)

  # Zkontroluj, jestli už neexistuje
  date <- as.Date(tools::file_path_sans_ext(basename(zip)))
  pq_file <- glue("{config::get('extract_to')}/{date}.parquet")
  if (file.exists(pq_file)) {
    return(pq_file)
  }

  # Unzip
  dir <- dirname(zip)
  unzip(zip,
        junkpaths = TRUE,
        overwrite = T,
        exdir = dir)

  # Read
  schema <- get_schema(date)
  csvs <- list.files(dir, full.names = T, pattern = "ADR\\.csv$")

  # Join
  joined <-
    csvs |>
    vroom(delim = ";",
          col_types = schema$csv,
          locale = locale(encoding = "Windows-1250"),
          show_col_types = F,
          progress  = F,
          .name_repair = function(x) {
            x |>
              snakecase::to_snake_case() |>
              iconv(from = 'UTF-8', to = 'ASCII//TRANSLIT')
          }) |>
    mutate(source = date,
           plati_od = as.Date(plati_od)) %>%
    pl$DataFrame(schema = schema$pq)

  # Remove csvs
  walk(csvs, file.remove)

  # Save
  joined$write_parquet(file = pq_file)
  rm(joined)
  gc()

  return(pq_file)
}
