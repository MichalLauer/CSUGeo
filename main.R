suppressMessages({
  suppressWarnings({
    # Čtení dat
    library(httr)
    library(vroom)

    # Manipulace s daty
    library(stringr)
    library(purrr)
    library(furrr)
    library(progressr)
    library(dplyr)
    library(polars)
    library(lubridate)

    # Ostatní
    library(checkmate)
    library(glue)
  })
})

# Načtení funkcí
rm(list = ls())
functions <- list.files(path = "R/", full.names = TRUE, pattern = ".*\\.R$")
invisible(lapply(X = functions, FUN = source))
rm(functions)

# Data která stáhnout
date_range <- seq(
  from = config::get("date_from"),
  to = config::get("date_to"),
  by = "month"
)
date_range <- ymd(date_range)
# Poslední den v daném měsíci
date_range <- date_range %m+% months(1) - days(1)

# Data co vůbec nefungují
known_broken <- ym(c("2018-11", "2019-02"))
known_broken <- known_broken %m+% months(1) - days(1)

# Všechny datumy co zpracovat
dates <- date_range[!date_range %in% known_broken]
# dates <- dates[year(date_range) == 2014]

# Stáhnutí .zip souborů
plan(multisession, workers = 3)
if (!dir.exists(config::get('download_to'))) {
  dir.create(config::get('download_to'))
}
zip_files <- c()
while (length(dates) != length(zip_files)) {
  print(glue("Downloading urls; got {length(zip_files)}/{length(dates)}"))
  with_progress({
    p <- progressor(along = dates)
    zip_files <-
      dates |>
      future_map(month_download, p = p) |>
      reduce(c)
  })
}

# Transformace .zip souboru do .parquet souboru
plan(multisession, workers = availableCores() - 1)
if (!dir.exists(config::get('extract_to'))) {
  dir.create(config::get('extract_to'))
}
with_progress({
  p <- progressor(along = zip_files)
  pq_files <- future_map_chr(zip_files, month_extract, p = p)
})

# Oprava jednotlivých .pq souborů
plan(multisession, workers = availableCores() - 1)
if (!dir.exists(config::get('correct_to'))) {
  dir.create(config::get('correct_to'))
}
with_progress({
  p <- progressor(along = pq_files)
  cpq_files <- future_map_chr(pq_files, month_correct, p = p)
})

# Spojení do jednoho souboru
plan(multisession, workers = availableCores() - 1)
# if (!dir.exists(config::get('merge_to'))) {
#   dir.create(config::get('merge_to'))
# }
# with_progress({
#   p <- progressor(along = cpq_files)
#   pl$enable_string_cache()
#   # merged <- future_map_chr(cpq_files, ___, p = p)
#   pl$disable_string_cache()
# })

# ---
# pl$with_string_cache({
#   # dA <- pl$read_parquet("data_corrected/2012-12-31.parquet")
#   # dB <- pl$read_parquet("data_corrected/2024-06-30.parquet")
#   pl$
#     concat(dA, dB)$
#     filter(
#       (
#         pl$col("zdroj")$eq(pl$col("zdroj")$max())
#       )$over("kod_adm", "plati_od")
#     )
# })

# x$
#   select("kod_adm", "plati_od", pl$len()$over("kod_adm", "plati_od"))$
#   filter(pl$col("len")$eq(1)$not())
#
# x$filter(pl$col("kod_adm")$eq("4192575"))
#
# a <- Sys.time()
# x$
#   sort(c("kod_adm", "plati_od"), descending = TRUE)$
#   with_columns(
#     pl$col("plati_od")$shift(1)$dt$offset_by("-1d")
#       $over(c("kod_adm"))
#       $fill_null(pl$col("zdroj"))
#       $alias("plati_do")
#   )
# b <- Sys.time()
# print(b - a)

l <- list()
pl$disable_string_cache()
for (i in seq_along(cpq_files)) {
  file <- cpq_files[i]
  # pl$read_parquet(file)
  l[[i]] <- pl$scan_parquet(file)
}

a <- Sys.time()
pl$
  concat(l)$
  filter(
    pl$col("zdroj")$eq(pl$col("zdroj")$max())$over("kod_adm", "plati_od")
  )$
  sort(c("kod_adm", "plati_od"), descending = TRUE)$
  with_columns(
    pl$col("plati_od")$shift(1)$dt$offset_by("-1d")
    $over(c("kod_adm"))
    $fill_null(pl$col("zdroj"))
    $alias("plati_do")
  )$
  unique()$
  collect(streaming=TRUE)$
  write_parquet("test.pq")
b <- Sys.time()
print(b - a)
# month_clear(2022, 9)
