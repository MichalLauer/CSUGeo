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
month_merge <- function(dir, year, month, save_dir = "data_joined") {
  assert_string(dir)
  date <- get_date(year, month)
  assert_string(save_dir, null.ok = TRUE)

  csvs <- list.files(dir, pattern = "\\.csv$", full.names = T)
  cols <- get_schema(year, month, type = "csv")

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
    mutate(source = date)

  if (!is.null(save_dir)) {
    if (!dir.exists(save_dir)) {
      dir.create(save_dir, recursive = T)
    }

    schema <- get_schema(year, month)
    joined_pl <- pl$DataFrame(joined, schema = schema)
    path <- glue("{save_dir}/{year}_{month}.parquet")
    joined_pl$write_parquet(path)
  }

  return(joined)
}
