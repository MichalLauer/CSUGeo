month_download <- function(year, month, url, path = "data-downloaded") {
  date <- get_date(year, month)

  path <- glue("{path}/{year}/{month}")
  if (dir.exists(path)) {
    unlink(path, recursive = T, force=T)
  }
  dir.create(path, recursive = T)
  
  hd <- HEAD(url)
  if (status_code(hd) == 200) {
    tryCatch({
      file <- glue("{path}/data.zip")
      download.file(url = url,
                    destfile = file)
      unzip(zipfile = file,
            junkpaths = TRUE,
            overwrite = T,
            exdir = path)
      return(path)
    })
  } else {
    cli_alert_warning(glue("Datum {date} nelze stáhnout."))
  }
}