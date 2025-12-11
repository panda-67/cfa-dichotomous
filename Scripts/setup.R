# ============================================================
# setup.R — Global Settings For CFA System
# ============================================================

DATA_FILE <- "~/Documents/Daily/Kelas Analisis/ANALISIS PRETEST POST TEST.xlsx"

RUN_MODE <- "PRETEST"  
# PRETEST / POSTTEST / MANUAL

ENABLE_EFA <- FALSE
# TRUE = use EFA-driven model
# FALSE = use manual item groups

EFA_THRESHOLD <- 0.30

VERBOSE <- TRUE

# Manual model toggle
USE_MANUAL_MODEL <- TRUE

# Model from file
USE_MODEL_FILE <- TRUE     # TRUE = load model.txt, FALSE = generate via EFA
MODEL_FILE_PATH <- "Models/cfa_PRETEST_model.txt"
