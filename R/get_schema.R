get_schema <- function(year, month, type = c("parquet", "csv")) {
  type <- match.arg(type)
  date <- get_date(year, month)
  if (date <= as.Date("2018-01-01")) {
    return(.get_schema_short(type))
  } else {
    return(.get_schema_long(type))
  }

}

.get_schema_short  <- function(type = c("parquet", "csv")) {
  type <- match.arg(type)
  if (type == "parquet") {
    return(list(
      kod_adm = pl$String,
      kod_obce = pl$Categorical(),
      nazev_obce = pl$Categorical(),
      nazev_momc = pl$Categorical(),
      nazev_mop = pl$Categorical(),
      kod_casti_obce = pl$Categorical(),
      nazev_casti_obce = pl$Categorical(),
      nazev_ulice = pl$Categorical(),
      typ_so = pl$Categorical(),
      cislo_domovni = pl$Int32,
      cislo_orientacni = pl$Int32,
      znak_cisla_orientacniho = pl$Categorical(),
      psc = pl$Int32,
      souradnice_y = pl$Float32,
      souradnice_x = pl$Float32,
      plati_od = pl$Datetime()
    ))
  } else {
    return(cols(
      kod_adm = col_character(),
      kod_obce = col_factor(),
      nazev_obce = col_factor(),
      nazev_momc = col_factor(),
      nazev_mop = col_factor(),
      kod_casti_obce = col_factor(),
      nazev_casti_obce = col_factor(),
      nazev_ulice = col_factor(),
      typ_so = col_factor(),
      cislo_domovni = col_integer(),
      cislo_orientacni = col_integer(),
      znak_cisla_orientacniho = col_factor(),
      psc = col_integer(),
      souradnice_y = col_double(),
      souradnice_x = col_double(),
      plati_od = col_datetime()
    ))
  }
}

.get_schema_long  <- function(type = c("parquet", "csv")) {
  if (type == "parquet") {
    return(list(
      kod_adm = pl$String,
      kod_obce = pl$Categorical(),
      nazev_obce = pl$Categorical(),
      kod_momc = pl$Categorical(), # Navíc
      nazev_momc = pl$Categorical(),
      kod_obvodu_prahy = pl$Categorical(), # Navíc
      nazev_obvodu_prahy = pl$Categorical(), # Přejmenováno z nazev_mop
      kod_casti_obce = pl$Categorical(),
      nazev_casti_obce = pl$Categorical(),
      kod_ulice = pl$Categorical(), # Navíc
      nazev_ulice = pl$Categorical(),
      typ_so = pl$Categorical(),
      cislo_domovni = pl$Int32,
      cislo_orientacni = pl$Int32,
      znak_cisla_orientacniho = pl$Categorical(),
      psc = pl$Int32,
      souradnice_y = pl$Float32,
      souradnice_x = pl$Float32,
      plati_od = pl$Datetime()
    ))
  } else {
    return(cols(
      kod_adm = col_character(),
      kod_obce = col_factor(),
      nazev_obce = col_factor(),
      kod_momc = col_factor(), # Navíc
      nazev_momc = col_factor(),
      kod_obvodu_prahy = col_factor(), # Navíc
      nazev_obvodu_prahy = col_factor(), # Přejmenováno z nazev_mop
      kod_casti_obce = col_factor(),
      nazev_casti_obce = col_factor(),
      kod_ulice = col_factor(), # Navíc
      nazev_ulice = col_factor(),
      typ_so = col_factor(),
      cislo_domovni = col_integer(),
      cislo_orientacni = col_integer(),
      znak_cisla_orientacniho = col_factor(),
      psc = col_integer(),
      souradnice_y = col_double(),
      souradnice_x = col_double(),
      plati_od = col_datetime()
    ))
  }
}
