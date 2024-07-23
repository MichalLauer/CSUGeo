join_month <- function(csvs, complex = TRUE) {
  joined <-
    csvs$csvs |>
    future_map(\(x) {
      vroom(file = x,
            delim = ";",
            col_types = cols(
              .default = col_character()
            ),
            locale = locale(encoding = "Windows-1250"),
            show_col_types = F,
            .name_repair = function(x) {
              x |>
                snakecase::to_snake_case() |>
                 iconv(from = 'UTF-8', to = 'ASCII//TRANSLIT')
            })
      }) |>
    bind_rows_fast()

  schema <- get_schema(csvs$year, csvs$month)
  joined <- pl$DataFrame(joined)

  if (complex) {
    return(list(
      data = joined,
      year = csvs$year,
      month = csvs$month
    ))
  } else {
    return(joined)
  }
}
