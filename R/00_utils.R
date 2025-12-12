library(here)

# Load and install library
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

# Create efa model template
create_efa_guided_template <- function(items, n_factors = 4, thresh = .30, file) {

  cat(">> Running EFA to generate guidance...\n")

  dir.create("Models", showWarnings = FALSE)

  items_num <- as.data.frame(lapply(items, function(x) as.numeric(as.character(x))))

  efa <- psych::fa(items_num, nfactors = n_factors, fm = "minres")  # safer

  load <- as.matrix(efa$loadings)

  lines <- c("# ============================================================",
             "# EFA-Guided Template Model",
             "# Edit this file to finalize your MANUAL CFA model.",
             "# Items kept because they loaded ≥ threshold.",
             paste0("# Threshold: ", thresh),
             "# ============================================================\n")

  for (f in 1:n_factors) {
    vars <- names(which(abs(load[, f]) >= thresh))

    if (length(vars) == 0) next

    lines <- c(lines,
               paste0("\n# Suggested Factor F", f),
               paste0("F", f, " =~ ", paste(vars, collapse = " + "))
    )
  }

  writeLines(lines, file)

  cat(">> EFA-guided template written to:", file, "\n")
  return(paste(lines, collapse = "\n"))
}

generate_report_pdf <- function() {
  rmarkdown::render(
    input = here::here("R/Rmd/report_wlsmv.Rmd"),
    output_file   = OUTPUT_FILE,
    output_format = "pdf_document",
    output_dir = "Reports"
  )
}

to_snake <- function(x) {
  x |>
    tolower() |>
    gsub("[^a-z0-9]+", "_", x = _) |>
    gsub("^_|_$", "", x = _)
}
