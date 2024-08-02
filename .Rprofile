source("renv/activate.R")
cat('*** Nastavení custom repositářů\n')
repos <- c(
  "Posit" = "https://cran.rstudio.com",
  "Multiverse" = "https://community.r-multiverse.org"
)
options(
  renv.config.repos.override = repos,
  repos = repos
)
rm(repos)

# Cesty
superPC <- TRUE
if (superPC) {
  options("path_data_downloaded" = "F:/geo/data_downloaded")
  options("path_data_joined" = "F:/geo/data_joined")
  options("path_data_enums" = "F:/geo/data_enums")
  options("file_data_joined" = "F:/gep/data_joined/all.parquet")
} else {

}
