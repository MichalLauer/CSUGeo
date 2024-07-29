# Vyčisti pamět
gc()
rm(list = ls())

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
    rep(2015, times = 12)
  ),
  month = c(
    rep(1:12, times = 1)
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
  command = bind_rows_fast(!!!.x, save_file="data_joined/all.parquet")
)

list(tgt_combined, tgt_joined)

# pl$
#   scan_parquet("data_joined/all.parquet")$
#   filter(pl$col("kod_adm")$eq("10007652"))$
#   select("kod_adm", "plati_od", "source")$
#   sort("source", descending = T)$
#   collect()$
#   head(n=12) |> 
#   as_tibble()

# pl$
#   scan_parquet("data_joined/all.parquet")$
#   select("kod_adm", "plati_od")$
#   unique()$
#   group_by("kod_adm")$
#   agg(
#     pl$len()
#   )$
#   filter(pl$col("len")$eq(1)$not())$
#   sort("kod_adm")$
#   collect()

# pl$
#   scan_parquet("data_joined/all.parquet")$
#   group_

# pl$
#   scan_parquet("data_joined/all.parquet")$
#   sort("kod_adm", "source", descending = T)$
#   collect()

# pl$
#   scan_parquet("data_joined/all.parquet")$
#   select("kod_adm", "souradnice_x", "souradnice_y", "plati_od", "source")$
#   filter(pl$col("kod_adm")$eq("10007652"),
#          (
#           pl$col("source")$eq( as.Date("2015-11-30")
#         )$or(
#           pl$col("source")$eq( as.Date("2015-10-31")
#         ) )))$collect() |> as_tibble()

# pl$
#   scan_parquet("data_joined/all.parquet")$
#   drop("source")$
#   unique()$
#   sort("kod_adm", "plati_od", descending = T)$
#   filter(pl$col("kod_adm")$eq("10007652"))$
#   with_columns(
#     pl$col("plati_od")$shift(1)$alias("plati_do")
#   )$
#   select("kod_adm", "plati_od", "plati_do")$
#   collect() |> as_tibble()
