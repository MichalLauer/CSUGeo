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

tar_option_set(
  resources = tar_resources(
    parquet = tar_resources_parquet()
  )
  # memory = "transient",
  # garbage_collection = TRUE,
  # controller = crew_controller_local(
  #   workers = 1,
  #   seconds_idle = 1,
  #   launch_max = 5
  # )
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
  date     = get_date(year = year, month = month),
  zip      = glue("{config::get('download_to')}/{year}/{month}/{date}.zip")
) |>
  anti_join(known_broken, by = join_by(year, month))

tgt_combined <- tar_map(
  values = data_df,
  names = 1:2,
  unlist = FALSE,
  tar_target(url, month_url(date), format = "url"),
  tar_target(data, month_get(url, zip)),
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
