library(here)

# load and install library
load_or_install <- function(pkgs, github = NULL) {
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) {
      if (!is.null(github) && p %in% names(github)) {
        remotes::install_github(github[[p]])
      } else {
        install.packages(p)
      }
    }
    library(p, character.only = TRUE)
  }
}
