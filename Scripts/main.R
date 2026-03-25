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

# ---- Load SEM Reporting ------------------------------------
source("R/02_sem_reporting.R")

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
sem_tables(result)

if (PDF_REPORT) {
  cat(">> Generating FINAL REPORT...\n")
  generate_report_pdf()
}

if (VERBOSE) {
  cat(">> Finished.\n")
}

# End of file ===============================================
