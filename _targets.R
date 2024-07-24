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

tgt_combined <- tar_map(
  values = data_df,
  unlist = FALSE,
  tar_target(url, month_url(year=year, month=month), format="url",
             description = "URL odkazující na portál vdp.cuzk.cz"),
  tar_target(source, month_download(year=year, month=month, url=url),
             description = "Stáhnutí dat a rozbalení do .csv"),
  tar_target(data, month_get(year=year, month=month, path=source),
             description = "Spojení všech dat do jedné tabulky"),
  tar_target(correct, month_correct(data),
             description = "Oprava nekonzistencí mezi lety")
)

# tgt_joined <- tar_combine(
#   combined,
#   tgt_combined[["correct"]],
#   command = bind_rows_fast(!!!.x, save_file="data-joined/all.parquet")
# )

list(
  tgt_combined
)