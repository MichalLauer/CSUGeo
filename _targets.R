# Vyčisti pamět
gc()

# Hlavní balíčky
library(targets)
library(tarchetypes)

# Čtení dat
library(httr)
library(vroom)

# Manipulace s daty
library(purrr)
library(furrr)
library(dplyr)
library(polars)

# Ostatní
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
# plan(multisession, workers = availableCores() - 1)

# Data která stáhnout
data_df <- dplyr::tibble(
  year = c(
    rep(2015, times = 12),
    rep(2021, times = 12)
  ),
  month = c(
    rep(1:12, times = 2)
  )
)

tgt_combined <-
  tar_map(
    values = data_df,
    tar_target(url, month_url(year=year, month=month), format="url",
               description = "Vytvoř URL odkazující na portál vdp.cuzk.cz."),
    tar_target(source, month_download(year=year, month=month, url=url),
               description = "Stáhni .zip a rozbalení do .csv."),
    tar_target(data, month_merge(source, year, month),
               description = "Spoj všechny .csv do jednoho roku."),
    tar_target(correct, month_correct(data),
               description = "Sjednoť jednotlivé měsíce do stejného formátu.")
  )

tgt_joined <- tar_combine(
  combined,
  tgt_combined[["correct"]],
  command = month_join(!!!.x, save_file="data_joined/all.parquet")
)

list(tgt_combined, tgt_joined)