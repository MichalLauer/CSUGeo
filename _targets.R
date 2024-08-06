suppressMessages({suppressWarnings({
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
})})

tar_option_set(
  resources = tar_resources(
    parquet = tar_resources_parquet()
  ),
  # memory = "transient",
  # garbage_collection = TRUE,
  # controller = crew_controller_local(
  #   workers = 1,
  #   seconds_idle = 1,
  #   launch_max = 5
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
options(warn = 1)
known_broken <- tribble(
  ~"year", ~"month",
  2019,    2,
  2018,    11
)

data_df <-
  data_df |>
  filter(
    (year == 2017 & month == 10) |
    (year == 2017 & month == 11) |
    (year == 2017 & month == 12) |
    (year == 2018 & month == 1) |
    (year == 2018 & month == 2)
  ) |> 
  anti_join(known_broken, by = join_by(year, month)) |>
  mutate(date = get_date(year, month),
         zip = glue("D:/geo/data_downloaded/{year}/{month}/{date}.zip"))

tgt_combined <- tar_map(
  values = data_df,
  names = 1:2,
  unlist = FALSE,
  tar_target(url, month_url(date), format = "url"),
  tar_target(data, month_get(url, zip)),
  tar_target(correct, month_correct(data))
)


# tgt_enums <- list(
#   tar_combine(enums, tgt_combined[["correct"]], command = month_prepare_enums(!!!.x)),
#   tar_target(enum_obce, month_enum(enums, variable = "obce")),
#   tar_target(enum_momc, month_enum(enums, variable = "momc")),
#   tar_target(enum_obvodu_prahy, month_enum(enums, variable = "obvodu_prahy")),
#   tar_target(enum_casti_obce, month_enum(enums, variable = "casti_obce")),
#   tar_target(enum_ulice, month_enum(enums, variable = "ulice"))
# )

tgt_joined <- tar_combine(
  combined,
  tgt_combined[["correct"]],
  command = month_join(!!!.x)
)

list(tgt_combined, tgt_joined)
