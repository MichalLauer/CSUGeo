month_get <- function(url, zip) {
  # Stáhni .zip soubor
  month_download(url = url, destfile = zip)
  # Rozbal .csv a spoj
  joined <- month_merge(zip)
  # Vrať target
  return(joined)
}
