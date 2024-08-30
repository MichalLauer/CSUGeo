source("renv/activate.R")
cat('*** Nastavení custom repositářů\n')
repos <- c(
  "Posit" = "https://cran.rstudio.com",
  "Multiverse" = "https://community.r-multiverse.org"
)
Sys.setenv(NOT_CRAN = "true")
options(
  renv.config.repos.override = repos,
  repos = repos
)
rm(repos)
