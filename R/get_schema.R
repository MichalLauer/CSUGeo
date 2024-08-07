#' Schéma pro data
#'
#' Vrací různé typy schéma podle toho, z jakého datumu jsou data sebraná.
#'
#' @param year Rok
#' @param month Měsíc
#' @param type Typ schéma, které vrátit.
#'   - polars - schéma pro polars [polars::pl$DataFrame()]/[polars::pl$LazyFrame()]
#'   - csv - schéma pro [vroom::vroom()]
#'
#' @return Zvolené schéma
get_schema <- function(date, type = c("polars", "csv")) {
  date <- as.Date(date)
  type <- match.arg(type)

  # Mezi 2017-10 a 2017-11
  if (date <= as.Date("2017-11-01")) {
    return(.get_schema_short(type))
  } else if (date <= as.Date("2021-01-01")) {
    return(.get_schema_middle(type))
  } else {
    return(.get_schema_long(type))
  }

}

#' Krátké schéma
#'
#' Krátké schéma pro datové soubory generované před 2018-01-01
#'
#' @param type Typ schéma, které vrátit.
#'   - polars - schéma pro polars [polars::pl$DataFrame()]/[polars::pl$LazyFrame()]
#'   - csv - schéma pro [vroom::vroom()]
#'
#' @return Zvolené schéma
.get_schema_short  <- function(type = c("polars", "csv")) {
  type <- match.arg(type)
  if (type == "polars") {
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
      plati_od = pl$Date
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

#' Střední schéma
#'
#' Střední schéma pro datové soubory generované mezi 2018-01-01 a 2021-01-01
#'
#' @param type Typ schéma, které vrátit.
#'   - polars - schéma pro polars [polars::pl$DataFrame()]/[polars::pl$LazyFrame()]
#'   - csv - schéma pro [vroom::vroom()]
#'
#' @return Zvolené schéma
.get_schema_middle  <- function(type = c("polars", "csv")) {
  if (type == "polars") {
    return(list(
      kod_adm = pl$String,
      kod_obce = pl$Categorical(),
      nazev_obce = pl$Categorical(),
      kod_momc = pl$Categorical(), # Navíc
      nazev_momc = pl$Categorical(),
      kod_mop = pl$Categorical(), # Navíc
      nazev_mop = pl$Categorical(),
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
      plati_od = pl$Date
    ))
  } else {
    return(cols(
      kod_adm = col_character(),
      kod_obce = col_factor(),
      nazev_obce = col_factor(),
      kod_momc = col_factor(), # Navíc
      nazev_momc = col_factor(),
      kod_mop = col_factor(), # Navíc
      nazev_mop = col_factor(),
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


#' Dlouhé schéma
#'
#' Dlouhé schéma pro datové soubory generované po 2018-01-01
#'
#' @param type Typ schéma, které vrátit.
#'   - polars - schéma pro polars [polars::pl$DataFrame()]/[polars::pl$LazyFrame()]
#'   - csv - schéma pro [vroom::vroom()]
#'
#' @return Zvolené schéma
.get_schema_long  <- function(type = c("polars", "csv")) {
  if (type == "polars") {
    return(list(
      kod_adm = pl$String,
      kod_obce = pl$Categorical(),
      nazev_obce = pl$Categorical(),
      kod_momc = pl$Categorical(),
      nazev_momc = pl$Categorical(),
      kod_obvodu_prahy = pl$Categorical(), # Přejmenováno
      nazev_obvodu_prahy = pl$Categorical(), # Přejmenováno
      kod_casti_obce = pl$Categorical(),
      nazev_casti_obce = pl$Categorical(),
      kod_ulice = pl$Categorical(),
      nazev_ulice = pl$Categorical(),
      typ_so = pl$Categorical(),
      cislo_domovni = pl$Int32,
      cislo_orientacni = pl$Int32,
      znak_cisla_orientacniho = pl$Categorical(),
      psc = pl$Int32,
      souradnice_y = pl$Float32,
      souradnice_x = pl$Float32,
      plati_od = pl$Date
    ))
  } else {
    return(cols(
      kod_adm = col_character(),
      kod_obce = col_factor(),
      nazev_obce = col_factor(),
      kod_momc = col_factor(),
      nazev_momc = col_factor(),
      kod_obvodu_prahy = col_factor(),
      nazev_obvodu_prahy = col_factor(), # Přejmenováno
      kod_casti_obce = col_factor(), # Přejmenováno
      nazev_casti_obce = col_factor(),
      kod_ulice = col_factor(),
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
