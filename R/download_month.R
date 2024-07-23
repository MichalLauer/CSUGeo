download_month <- function(year, month, path = "data-downloaded", comlex = TRUE) {
  date <- get_date(year, month)

  path <- glue("{path}/{year}/{month}")
  if (!dir.exists(path)) {
    dir.create(path, recursive = T)
  } else {
    # Předpokládám, že když existuje složka, data jsou v pohodě stáhlá
      x <- list.files(path = path, pattern = "\\.csv$", full.names = T)
      return(x)
  }

  base_url <- glue(
    "https://vdp.cuzk.cz/vymenny_format/csv/{format(date, '%Y%m%d')}_OB_ADR_csv.zip"
  )

  hd <- HEAD(base_url)
  if (status_code(hd) == 200) {
    tryCatch({
      file <- glue("{path}/data.zip")
      download.file(url = base_url,
                    destfile = file,
                    quiet = T)
      unzip(zipfile = file,
            exdir = path,
            junkpaths = TRUE)
      file.remove(file)
    })
  } else {
    cli_alert_warning(glue("Datum {date} nelze stáhnout."))
  }

  csvs <- list.files(path = path, pattern = "\\.csv$", full.names = T)

  if (complex) {
    return(list(
      year = year,
      month = month,
      csvs = csvs
    ))
  } else {
    return(csvs)
  }
}