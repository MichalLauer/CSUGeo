suppressMessages({
  suppressWarnings({
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
  })
})

crew_local <- crew_controller_local(
  name = "local",
  workers = 1,
  seconds_idle = Inf
)

crew_download <- crew_controller_local(
  name = "download",
  workers = 3,
  seconds_idle = 3*60
)

tar_option_set(
  controller = crew_controller_group(crew_local, crew_download),
  garbage_collection = TRUE,
  resources = tar_resources(
    parquet = tar_resources_parquet(),
    crew = tar_resources_crew(controller = "local")
  )
)

options(warn = 1)
invisible(lapply(X = list.files(path = "R", full.names = TRUE), FUN = source))

# Data která stáhnout
date_range <- seq(
  from = config::get("date_from"),
  to = config::get("date_to"),
  by = "month"
)

known_broken <- tribble(
  ~"year", ~"month",
  2019,    2,
  2018,    11
)

data_df <- tibble(
  raw_date = date_range,
  year     = as.integer(format(raw_date, "%Y")),
  month    = as.integer(format(raw_date, "%m")),
  date     = get_date(year = year, month = month)
) |>
  anti_join(known_broken, by = join_by(year, month))


# data_df <-
#   data_df |> 
#   filter(
#     (year == 2017 & month %in% c(9, 10, 11, 12)) |
#     (year == 2020 & month >= 11) |
#     (year == 2021 & month <= 2)
#   )

tgt_combined <- tar_map(
  values = data_df,
  names = c(year, month),
  unlist = FALSE,
  tar_target(url, month_url(date), format = "url",
             deployment = "main"),
  tar_target(zip, month_download(url, date, year, month),
             error = "continue",
             resources = tar_resources(
               crew = tar_resources_crew(controller = "download")
             )),
  tar_target(data, month_merge(zip)),
  tar_target(correct, month_correct(data))
)


# tgt_enums <- list(
#   tar_combine(enums, tgt_combined[["correct"]],
#               command = month_prepare_enums(!!!.x)),
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
