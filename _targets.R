# Main calls
library(targets)
library(tarchetypes)

# Reading
library(httr)
library(vroom)

# Wrangling
library(purrr)
library(furrr)
library(dplyr)
library(polars)

# Misc
library(checkmate)
library(glue)
library(cli)

tar_option_set(
  resources = tar_resources(
    parquet = tar_resources_parquet()
  ),
  memory = "transient",
  garbage_collection = TRUE
)

invisible(lapply(X = list.files(path = "R", full.names = T), FUN = source))
plan(multisession, workers = availableCores() - 1)

data_df <- dplyr::tibble(
  year = c(2015, 2023),
  month = c(3, 5)
)

list(
  tar_map(
    values = data_df,
    tar_target(url, month_url(year=year, month=month), format="url",
               description = "URL odkazující na portál vdp.cuzk.cz"),
    tar_target(source, month_download(year=year, month=month, url=url),
               description = "Stáhnutí dat a rozbalení do .csv")
  )
)

# tgt_joined <- tar_combine(
#   combined,
#   tgt_combined[["correct"]],
#   command = bind_rows_fast(!!!.x, save_file="data-joined/all.parquet")
# )

lsts <- list.files("data-downloaded/2023/5/", pattern = "\\.csv$", full.names = T)
lsts <- lsts[2:101]

microbenchmark::microbenchmark(
  "map" = {
    lsts |>
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
      })
  },
  "one" = {
    vroom(file = lsts[-1],
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
  }
  times = 1
)
