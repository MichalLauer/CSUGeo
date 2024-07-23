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
  )
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
    tar_target(url, month_url(year=year, month=month), format="url"),
    tar_target(source, month_download(year=year, month=month, url=url)),
    tar_target(data, month_get(year=year, month=month, path=source)),
    tar_target(correct, month_correct(data))
  )
)
