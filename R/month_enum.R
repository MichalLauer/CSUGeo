month_enum <- function(enums,
                       variable = c("obce", "momc", "obvodu_prahy", "casti_obce", "ulice"),
                       save_dir = getOptions("path_data_enums")) {

  variable <- match.arg(variable)

  r <-
    pl$
    LazyFrame(enums)$
    select(
      paste0(c("kod_", "nazev_"), variable)
    )$
    unique()$
    collect()

  if (!is.null(save_dir)) {
    if (!dir.exists(save_dir)) {
      dir.create(save_dir)
    }
    r$write_parquet(glue("{save_dir}/{variable}.parquet"))
  }

  return(as_tibble(r))
}