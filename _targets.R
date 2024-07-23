library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("rvest", "httr",
               "checkmate", "glue",
               "purrr", "furrr", "dplyr",
               "polars", "data.table", "vroom",
               "cli"),
  resources = tar_resources(
    parquet = tar_resources_parquet()
  )
)

invisible(lapply(X = list.files(path = "R", full.names = T), FUN = source))
# plan(multisession, workers = availableCores() - 1)

data <- dplyr::tibble(
  year = c(2015, 2023),
  month = c(3, 5)
)

list(
  tar_map(
    values = data,
    names = "source",
    tar_files(paths, download_month(year=year, month=month))
  )
)



# pl$read_parquet("data-joined/2015_3.parquet")$schema |> names()
# # v obojim: kod_adm
# #   kod_obce, nazev_obce
# #           , nazev_momc
# #           , nazev_mop
# #   kod_casti_obce, nazev_casti_obce,
# #   nazev_ulice, typ_so, cislo_domovni, cislo_orientacni
# #   znak_cisla_orientacniho, psc, souradnice, plati_od

# x$schema |> names()
# # v obojim: kod_adm
# #   kod_obce, nazev_obce
# #   *kod_momc*, nazev_momc
# #   *kod_obvodu_prahy*, nazev_mop/*nazev_obvody_prahy*
# #   kod_casti_obce, nazev_casti_obce,
# #   kod_ulice, nazev_ulice, typ_so, cislo_domovni, cislo_orientacni
# #   znak_cisla_orientacniho, psc, souradnice, plati_od

# # momc = městský obvod, městská část
# # 1) kod_momc nejspíš půjde historicky doplnit
# # 2) obvod_prahy == mop ??
# # 3) kod_ulice nejspíš půjde historicky doplnit
