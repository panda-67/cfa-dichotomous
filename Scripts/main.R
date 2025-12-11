# ---- Load library ------------------------------------------
source("R/00_utils.R") 

# ---- Load required packages here only -----------------------
load_or_install(c( "lavaan", "readxl", "stringr",
  "purrr", "dplyr", "psych", "semPlot"
))

# ---- Load engine (contains cfa_engine() only) --------------
source("R/01_cfa_engine.R")

# ---- Load setup switches -----------------------------------
source("Scripts/setup.R")

# ============================================================
# main.R — Script Runner
# ============================================================
if (VERBOSE) cat(">> RUN MODE:", RUN_MODE, "\n")

result <- cfa_engine(
  file_path       = DATA_FILE,
  pattern         = RUN_MODE,
  efa             = ENABLE_EFA,
  thresh          = EFA_THRESHOLD,
  use_model_file  = USE_MODEL_FILE,
  model_file_path = MODEL_FILE_PATH
)

if (VERBOSE) cat(">> Finished.\n")
