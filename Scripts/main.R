# ---- Load library ------------------------------------------
source("R/00_utils.R")

# ---- Load required packages here only -----------------------
load_or_install(c(
  "here",
  "readxl",
  "rmarkdown",
  "stringr",
  "purrr",
  "dplyr",
  "psych",
  "lavaan",
  "semPlot"
))

# ---- Load engine (contains cfa_engine() only) --------------
source("R/01_cfa_engine.R")

# ---- Load SEM table utilities ------------------------------
source("R/02_sem_tables.R")

# ---- Load SEM Reporting ------------------------------------
source("R/03_sem_reporting.R")

# ---- Load setup switches -----------------------------------
source("Scripts/setup.R")

# ============================================================
# main.R — Script Runner
# ============================================================
library(here)

if (VERBOSE) {
  cat(">> RUN MODE:", RUN_MODE, "\n")
}

result <- cfa_engine(
  file_path = DATA_FILE,
  pattern = RUN_MODE,
  efa = USE_EFA,
  thresh = EFA_THRESHOLD,
  use_model_file = USE_MODEL_FILE,
  model_file_path = MODEL_FILE_PATH
)

# ============================================================
# Reliability and Validity Tables
# ============================================================

fit <- result$fit
data <- result$data

reliability <- reliability_table(fit, data)

fornell <- fornell_larcker(fit)

cfa_results <- cfa_table(fit)

if (VERBOSE) {
  cat("\n--- Reliability Table ---\n")
  print(reliability)

  cat("\n--- Fornell-Larcker Matrix ---\n")
  print(fornell)

  cat("\n--- CFA Results Table ---\n")
  print(cfa_results)
}

sem_tables(result)

if (PDF_REPORT) {
  cat(">> Generating FINAL REPORT...\n")
  generate_report_pdf()
}

if (VERBOSE) {
  cat(">> Finished.\n")
}

# End of file ===============================================
