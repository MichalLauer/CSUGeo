month_download <- function(date, p = NULL) {
  if (!is.null(p)) {
    p()
  }
  checkmate::assert_date(date)
  year  <- year(date)
  month <- month(date)

  destfile <- glue("{config::get('download_to')}/{year}/{month}/{date}.zip")
  if (file.exists(destfile)) {
    fsize <- file.size(destfile)
    if (fsize > 0) {
      return(destfile)
    }
  }

  # Před stáhnutím musí existovat prázdná složka
  destdir <- dirname(destfile)
  unlink(destdir, recursive = T, force = T)
  dir.create(destdir, recursive = T)

  # CUZK má občas problémy a stačí to jenom zkusit víckrát, s nějakým delayem
  url <- month_url(date)
  result <- tryCatch({
    download.file(url = url,
                  destfile = destfile,
                  quiet = T,
                  mode = "wb")
  }, error = identity, warning = identity)

  if (inherits(result, "error") | inherits(result, "warning") ) {
    print(result)
    file.remove(destfile)
    return(NULL)
  } else {
    return(destfile)
  }
}