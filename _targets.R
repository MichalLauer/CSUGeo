# Hlavní balíčky
library(targets)
library(crew)
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

# Cesty
superPC <- TRUE
if (superPC) {
  options("path_data_downloaded" = "F:/geo/data_downloaded")
  options("path_data_joined" = "F:/geo/data_joined")
  options("path_data_enums" = "F:/geo/data_enums")
  options("file_data_joined" = "F:/gep/data_joined/all.parquet")
} else {

}

tar_option_set(
  resources = tar_resources(
    parquet = tar_resources_parquet()
  ),
  # memory = "transient",
  # garbage_collection = TRUE
  controller = crew_controller_local(
    workers = availableCores() - 1,
  )
)

invisible(lapply(X = list.files(path = "R", full.names = T), FUN = source))
plan(multisession, workers = availableCores() - 1)

# Data která stáhnout
data_df <- dplyr::tibble(
  year = c(
    rep(2012, times = 1),
    rep(2013, times = 12),
    rep(2014, times = 12),
    rep(2015, times = 12),
    rep(2016, times = 12),
    rep(2017, times = 12),
    rep(2018, times = 12),
    rep(2019, times = 12),
    rep(2020, times = 12),
    rep(2021, times = 12),
    rep(2022, times = 12),
    rep(2023, times = 12),
    rep(2024, times = 6)
  ),
  month = c(
    12,
    rep(1:12, times = 11),
    1:6
  )
)

known_broken <- tribble(
  ~"year", ~"month",
  2019,    2,
  2018,    11
)

data_df <-
  data_df |>
  anti_join(known_broken, by = join_by(year, month))

tgt_combined <-
  tar_map(
    values = data_df,
    tar_target(url, month_url(year=year, month=month), format="url",
               description = "Vytvoř URL odkazující na portál vdp.cuzk.cz."),
    tar_target(source, month_download(year=year, month=month, url=url),
               deployment = "main", # Jinak by pořád padal server kvůli hodně dotazům
               description = "Stáhni .zip a rozbalení do .csv."),
    tar_target(data, month_merge(source, year, month),
               description = "Spoj všechny .csv do jednoho roku."),
    tar_target(correct, month_correct(data),
               description = "Sjednoť jednotlivé měsíce do stejného formátu.")
  )

tgt_enums <- list(
  tar_combine(enums, tgt_combined[["correct"]], command = month_align(!!!.x)),
  tar_target(enum_obce, month_enum(enums, variable = "obce")),
  tar_target(enum_momc, month_enum(enums, variable = "momc")),
  tar_target(enum_obvodu_prahy, month_enum(enums, variable = "obvodu_prahy")),
  tar_target(enum_casti_obce, month_enum(enums, variable = "casti_obce")),
  tar_target(enum_ulice, month_enum(enums, variable = "ulice"))
)


tgt_joined <- tar_combine(
  combined,
  tgt_combined[["correct"]],
  command = month_join(!!!.x)
)

list(tgt_combined, tgt_enums, tgt_joined)