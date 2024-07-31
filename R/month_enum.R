month_enum <- function(enums,
                       variable = c("obce", "momc", "obvodu_prahy", "casti_obce", "ulice")) {
  
  variable <- match.arg(variable)

  r <-
    pl$
    LazyFrame(enums)$
    select(
      paste0(c("kod_", "nazev_"), variable)
    )$
    unique()$
    collect()

  if (!dir.exists("data_enums")) {
    dir.create("data_enums")
  }

  r$write_parquet(glue("data_enums/{variable}.parquet"))

  return(as_tibble(r))
}