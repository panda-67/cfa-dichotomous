# ============================================================
# 03_sem_reporting.R
# SEM Reporting Tables
# ============================================================
#
# ------------------------------------------------------------
# Reliability Table
# ------------------------------------------------------------

sem_reliability <- function(fit, data) {
  std <- standardizedSolution(fit)

  loadings <- std %>%
    filter(op == "=~") %>%
    select(latent = lhs, item = rhs, loading = est.std)

  constructs <- unique(loadings$latent)

  results <- lapply(constructs, function(con) {
    items <- loadings$item[loadings$latent == con]
    lambdas <- loadings$loading[loadings$latent == con]

    alpha_val <- tryCatch(
      {
        item_data <- data[, items]

        item_data <- item_data %>%
          mutate(across(everything(), ~ as.numeric(as.character(.))))

        psych::alpha(item_data)$total$raw_alpha
      },
      error = function(e) NA
    )

    CR <- (sum(lambdas)^2) /
      ((sum(lambdas)^2) + sum(1 - lambdas^2))

    AVE <- mean(lambdas^2)

    data.frame(
      Construct = con,
      Alpha = round(alpha_val, 3),
      CR = round(CR, 3),
      AVE = round(AVE, 3)
    )
  })

  bind_rows(results)
}

# ------------------------------------------------------------
# Fornell-Larcker Table
# ------------------------------------------------------------

sem_fornell <- function(fit) {
  cor_mat <- inspect(fit, "cor.lv")

  std <- standardizedSolution(fit)

  ave <- std %>%
    filter(op == "=~") %>%
    group_by(lhs) %>%
    summarise(AVE = mean(est.std^2))

  sqrt_ave <- sqrt(ave$AVE)
  names(sqrt_ave) <- ave$lhs

  diag(cor_mat) <- sqrt_ave

  round(cor_mat, 3)
}

# ------------------------------------------------------------
# HTMT
# ------------------------------------------------------------

sem_htmt <- function(fit, data) {
  lavaan::lavInspect(fit, "cor.lv")
}

# ------------------------------------------------------------
# CFA Loading Table
# ------------------------------------------------------------

sem_loadings <- function(fit) {
  standardizedSolution(fit) %>%
    filter(op == "=~") %>%
    select(
      Construct = lhs,
      Item = rhs,
      Loading = est.std,
      SE = se,
      z = z,
      p = pvalue
    ) %>%
    mutate(
      Loading = round(Loading, 3),
      p = round(p, 4)
    )
}

# ------------------------------------------------------------
# Model Fit Table
# ------------------------------------------------------------

sem_fit <- function(fit) {
  fitMeasures(
    fit,
    c(
      "chisq",
      "df",
      "pvalue",
      "cfi",
      "tli",
      "rmsea",
      "srmr"
    )
  ) %>%
    round(3)
}

# ------------------------------------------------------------
# MASTER FUNCTION
# ------------------------------------------------------------

sem_tables <- function(result) {
  fit <- result$fit
  data <- result$data

  cat("\n==============================\n")
  cat("MODEL FIT\n")
  cat("==============================\n")
  print(sem_fit(fit))

  cat("\n==============================\n")
  cat("RELIABILITY (Alpha CR AVE)\n")
  cat("==============================\n")
  print(sem_reliability(fit, data))

  cat("\n==============================\n")
  cat("FORNELL-LARCKER\n")
  cat("==============================\n")
  print(sem_fornell(fit))

  cat("\n==============================\n")
  cat("HTMT\n")
  cat("==============================\n")
  print(sem_htmt(fit, data))

  cat("\n==============================\n")
  cat("CFA LOADINGS\n")
  cat("==============================\n")
  print(sem_loadings(fit))
}
