# ============================================================
# cfa_engine.R
# ============================================================

# ------------------------------------------------------------
# 1) USER-DEFINED ITEM GROUPS (MANUAL MODEL)
# ------------------------------------------------------------

C1_items <- c(1,3,7,9,20,24,31,50,51,52,53,58,59,10,12)
C2_items <- c(2,4,5,6,14,15,18,19,26,27,32,47,54,60,11)
C3_items <- c(8,13,16,17,21,22,23,25,28,35,36,37,55,56)
C4_items <- c(57,29,30,33,34,38,39,40,41,42,43,44,45,46,48,49)

items_to_lavaan <- function(nums) paste0("i", nums)

generate_manual_model <- function() {
  paste(
    "C1 =~", paste(items_to_lavaan(C1_items), collapse = " + "),
    "C2 =~", paste(items_to_lavaan(C2_items), collapse = " + "),
    "C3 =~", paste(items_to_lavaan(C3_items), collapse = " + "),
    "C4 =~", paste(items_to_lavaan(C4_items), collapse = " + "),
    sep = "\n"
  )
}

# ------------------------------------------------------------
# 2) EFA MODEL GENERATOR
# ------------------------------------------------------------

generate_efa_model <- function(items, thresh = .30, nfactors = 4) {
  # Convert ordered factors → numeric for EFA only
  items_num <- as.data.frame(lapply(items, function(x) as.numeric(as.character(x))))

  efa <- psych::fa(items_num, nfactors = nfactors, fm = "minres")
  cat("here")

  lines <- c()
  for (f in 1:nfactors) {
    loads <- efa$loadings[, f]
    vars  <- names(loads[abs(loads) >= thresh])
    if (length(vars) == 0) next

    lines <- c(lines, paste0("F", f, " =~ ", paste(vars, collapse = " + ")))
  }
  
  paste(lines, collapse = "\n")
}

# ------------------------------------------------------------
# 3) SMART MODEL SELECTOR
# ------------------------------------------------------------

generate_initial_model <- function(items, efa_override = TRUE, thresh = .30) {
  manual <- generate_manual_model()
  if (!efa_override) return(manual)
 
  efa_model <- generate_efa_model(items, thresh = thresh, nfactors = 4)

  if (nchar(efa_model) < 10) return(manual)
  
  efa_model
}

# ------------------------------------------------------------
# 4) DATA LOADER
# ------------------------------------------------------------

load_dataset <- function(file_path, pattern = "PRETEST") {
  sheets <- excel_sheets(file_path)
  target_sheets <- sheets[str_detect(sheets, regex(pattern, ignore_case = TRUE))]
  
  df <- map_dfr(target_sheets, ~ {
    read_excel(
      file_path,
      sheet = .x,
      range = cell_limits(c(2,3), c(NA,62))
    )
  })
  
  if (tolower(names(df)[1]) %in% c("nama","name")) {
    df <- df[, -1]
  }
  
  names(df) <- paste0("i", seq_len(ncol(df)))
  df[] <- lapply(df, ordered)
  
  df
}

# ------------------------------------------------------------
# 5) RUN CFA + EXPORT EVERYTHING
# ------------------------------------------------------------

run_cfa <- function(items, model, label = "cfa_output") {
  fit <- cfa(
    model,
    data = items,
    estimator = "WLSMV",
    ordered = names(items)
  )
  
  dir.create("Reports", showWarnings = FALSE)
  
  # Summary
  sink(paste0("Reports/", label, "_summary.txt"))
  print(summary(fit, fit.measures = TRUE, standardized = TRUE))
  sink()
  
  # Lambda
  lambda <- inspect(fit, "std")$lambda
  capture.output(lambda, file = paste0("Reports/", label, "_lambda.txt"))
  
  # Covariances
  capture.output(lavInspect(fit, "cov.lv"), 
                 file = paste0("Reports/", label, "_covlv.txt"))
  
  # Fit indices
  fm <- fitMeasures(fit, c(
    "chisq","df","pvalue","cfi","tli","rmsea",
    "rmsea.ci.lower","rmsea.ci.upper","srmr"
  ))
  
  out <- paste0("Reports/", label, "_fit.txt")
  sink(out)
  maxn <- max(nchar(names(fm)))
  for (i in seq_along(fm))
    cat(sprintf("%-*s : %s\n", maxn, names(fm)[i], fm[i]))
  sink()
  
  # Top MIs
  mi <- modindices(fit, sort = TRUE)[1:50, ]
  capture.output(mi, file = paste0("Reports/", label, "_mi_top.txt"))
  
  # STD solution
  capture.output(standardizedSolution(fit),
                 file = paste0("Reports/", label, "_std_solution.txt"))
  
  # Diagram
  pdf(paste0("Reports/", label, "_diagram.pdf"), 10, 8)
  semPaths(fit, what = "std", whatLabels = "std",
           layout = "tree", edge.label.cex = .7)
  dev.off()
  
  fit
}

# ------------------------------------------------------------
# 6) MASTER ENGINE — DRIVEN BY setup.R
# ------------------------------------------------------------

cfa_engine <- function(file_path, pattern = "PRETEST",
                       efa = TRUE, thresh = .30, use_model_file = FALSE, model_file_path) {

  cat(">> Loading dataset...\n")
  items <- load_dataset(file_path, pattern)

  cat(">> Building model...\n")
  if (use_model_file && file.exists(model_file_path)) {
    cat(">> Using model from file:", model_file_path, "\n")
    model <- readLines(model_file_path)
    model <- paste(model, collapse = "\n")
  } else {
    cat(">> Generating model from EFA...\n")
    model <- generate_initial_model(items, efa_override = efa, thresh = thresh)
  }
  cat(">> Running CFA...\n")
  fit <- run_cfa(items, model, label = paste0("cfa_", pattern))

  cat(">> Done.\n")
  fit
}

