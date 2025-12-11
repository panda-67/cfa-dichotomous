# ============================================================
# setup.R — Global Settings for CFA Automation System
# ============================================================
# This file controls EVERYTHING the CFA engine does.
# Adjust settings here, never in the main code.
# ============================================================


# ------------------------------------------------------------
# 1) INPUT DATA FILE
# ------------------------------------------------------------
# The Excel file containing multiple sheets (PRETEST, POSTTEST, etc.)
DATA_FILE <- "~/Documents/Daily/Kelas Analisis/ANALISIS PRETEST POST TEST.xlsx"



# ------------------------------------------------------------
# 2) RUN MODE
# ------------------------------------------------------------
# Determines which sheets to extract and what label to use.
# Accepted values:
#   "PRETEST"
#   "POST TEST"
RUN_MODE <- "POST TEST"



# ------------------------------------------------------------
# 3) MODEL TYPE SELECTION
# ------------------------------------------------------------
# MASTER SWITCH: how the model should be built.
#
# Priority hierarchy:
#   1) USE_MODEL_FILE == TRUE      → load model from file
#   2) USE_EFA == TRUE             → generate model via EFA
#   3) otherwise                   → use the manual item grouping
#
# NOTE: These flags DO NOT fight each other because the CFA engine
#       evaluates them in strict order.
# ------------------------------------------------------------

# 3a. Use model file? (highest priority)
USE_MODEL_FILE <- FALSE     # TRUE = load model from disk (recommended for finalized models)

# 3b. Use EFA-based structure?
USE_EFA <- TRUE            # TRUE = generate EFA model unless overridden by file

# 3c. Use manual model if EFA is disabled or EFA fails
USE_MANUAL_MODEL <- TRUE   # TRUE = fallback manual grouping allowed, will always be TRUE



# ------------------------------------------------------------
# 4) EFA OPTIONS
# ------------------------------------------------------------
# Only used when USE_EFA = TRUE and no model file is loaded.
#
# EFA_THRESHOLD = minimum absolute loading to keep an item.
# Typical values: 0.25–0.40
EFA_THRESHOLD <- 0.30



# ------------------------------------------------------------
# 5) VERBOSITY
# ------------------------------------------------------------
# TRUE = print all steps to console
# FALSE = silent mode (for batch runs)
VERBOSE <- TRUE



# ------------------------------------------------------------
# 6) MODEL FILE (Auto-Linked to RUN_MODE)
# ------------------------------------------------------------
# You do NOT need to change this path manually.
# It automatically selects:
#   Models/cfa_PRETEST_model.txt   OR
#   Models/cfa_POSTTEST_model.txt
#
# If you *really* want a custom file, override MODEL_FILE_PATH manually.
# ------------------------------------------------------------
MODEL_FILE_PATH <- sprintf("Models/cfa_%s_model.txt", RUN_MODE)

