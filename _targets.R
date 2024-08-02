# Hlavní balíčky
library(targets)
library(crew)
library(tarchetypes)

# Čtení dat
library(httr)
library(vroom)

# Manipulace s daty
library(purrr)
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
  # memory = "transient",
  # garbage_collection = TRUE
  # controller = crew_controller_local(
  #   workers = 50,
  #   seconds_idle = 1,
  #   launch_max = 100
  # )
)

invisible(lapply(X = list.files(path = "R", full.names = T), FUN = source))

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
  anti_join(known_broken, by = join_by(year, month)) |>
  mutate(date = get_date(year, month),
         url = month_url(date),
         zip = glue("F:/geo/data_downloaded/{year}/{month}/{date}.zip"))

data_df <- filter(data_df, year == 2015, month == 1)

tgt_combined <- list(
    tar_download(zip_file, data_df$url, data_df$url),
    tar_target(data, month_merge(zip_file), pattern = map(zip_file)),
    tar_target(corrected, month_correct(data), pattern = map(data))
)

# tgt_enums <- list(
#   tar_combine(enums, tgt_combined[["correct"]], command = month_prepare_enums(!!!.x)),
#   tar_target(enum_obce, month_enum(enums, variable = "obce")),
#   tar_target(enum_momc, month_enum(enums, variable = "momc")),
#   tar_target(enum_obvodu_prahy, month_enum(enums, variable = "obvodu_prahy")),
#   tar_target(enum_casti_obce, month_enum(enums, variable = "casti_obce")),
#   tar_target(enum_ulice, month_enum(enums, variable = "ulice"))
# )


# tgt_joined <- tar_combine(
#   combined,
#   tgt_combined[["correct"]],
#   command = month_join(!!!.x)
# )

list(tgt_combined)
