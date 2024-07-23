month_merge <- function(csvs, year, month) {
  joined <-
    csvs |>
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

  schema <- get_schema(year, month)
  joined <- pl$DataFrame(joined, schema = schema)

  return(joined)
}
