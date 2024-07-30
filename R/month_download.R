#' Stáhnutí dat
#'
#' Funkce stáhne .zip soubor z url odkazu a rozbalí ho.
#'
#' @param year Rok, pro který se stahují data.
#' @param month Měsíc pro který se stahují data.
#' @param url Odkaz, ze kterého se stáhnou data.
#' @param path Kořenová složka, kde se rozbalí data. výsledné soubory budou ve
#' složce path/year/month.
#'
#' @return Cesta k souborům
month_download <- function(year, month, url, path = "data_downloaded") {
  validate_date(year, month)
  assert_string(url)
  assert_string(path)


  # Když už stahujeme (což rozhoduje {targets}, tak odznova)
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
      # Pomáhá od timeoutů
      Sys.sleep(1)
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