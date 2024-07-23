get_schema <- function(year, month) {

  .short_schema <- list(
    kod_adm = pl$Int32,
    kod_obce = pl$Int32,
    nazev_obce = pl$String,
    nazev_momc = pl$String,
    nazev_mop = pl$String,
    kod_casti_obce = pl$Int32,
    nazev_casti_obce = pl$String,
    nazev_ulice = pl$String,
    typ_so = pl$String,
    cislo_domovni = pl$Int32,
    cislo_orientacni = pl$Int32,
    psc = pl$Int32,
    souradnice_y = pl$Float32,
    souradnice_x = pl$Float32,
    plati_od = pl$Datetime()
  )


  .long_schema <- list(
    kod_adm = pl$Int32,
    kod_obce = pl$Int32,
    nazev_obce = pl$String,
    kod_momc = pl$Int32, # Navíc
    nazev_momc = pl$String,
    kod_obvodu_prahy = pl$Int32, # Navíc
    nazev_obvodu_prahy = pl$String, # Přejmenováno z nazev_mop
    kod_casti_obce = pl$Int32,
    nazev_casti_obce = pl$String,
    kod_ulice = pl$Int32, # Navíc
    nazev_ulice = pl$String,
    typ_so = pl$String,
    cislo_domovni = pl$Int32,
    cislo_orientacni = pl$Int32,
    psc = pl$Int32,
    souradnice_y = pl$Float32,
    souradnice_x = pl$Float32,
    plati_od = pl$Datetime()
  )
    
  date <- get_date(year, month)
  if (date <= as.Date("2018-01-01")) {
    return(.short_schema)
  } else {
    return(.long_schema)
  }

}

