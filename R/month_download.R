month_download <- function(url, destfile, tries = 3, wait = 5, timeout = 180) {
  
  MAX_TRIES <- tries
  options(timeout = timeout)
  on.exit({
    options(timeout = 60)
  })

  # Před stáhnutím musí existovat prázdná složka
  destdir <- dirname(destfile)
  unlink(destdir, recursive = T, force = T)
  dir.create(destdir, recursive = T)

  # CUZK má občas problémy a stačí to jenom zkusit víckrát, s nějakým delayem
  while (tries > 0) {
    result <- tryCatch({
      cli_alert_info(glue("{url} {MAX_TRIES - tries + 1 }/{MAX_TRIES}..."))
      download.file(url = url,
                    destfile = destfile,
                    quiet = T,
                    mode = "wb")
    }, error = identity, warning = identity)

    if (!inherits(result, "error") && !inherits(result, "warning") ) {
      break;
    } else {
      Sys.sleep(tries)
      tries <- tries - 1
      cli_alert_info(glue("{url} selhala, {MAX_TRIES - tries}/{MAX_TRIES}"))
      cli_alert_info(result)
    }
  }

  if (tries == 0) {
    stop(glue("{url} nelze stáhnout."))
  } else {
    cli_alert_info(glue("{url} OK."))
  }
}