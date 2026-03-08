# ============================================================
# 02_sem_tables.R — Reliability & Validity Tables
# ============================================================

# ------------------------------------------------------------
# Extract standardized loadings
# ------------------------------------------------------------

get_loadings <- function(fit) {
  std <- standardizedSolution(fit)

  loadings <- std %>%
    filter(op == "=~") %>%
    select(latent = lhs, item = rhs, loading = est.std)

  return(loadings)
}

# ------------------------------------------------------------
# Composite Reliability (CR) and AVE
# ------------------------------------------------------------

compute_cr_ave <- function(loadings) {
  loadings %>%
    group_by(latent) %>%
    summarise(
      CR = (sum(loading)^2) /
        ((sum(loading)^2) + sum(1 - loading^2)),
      AVE = mean(loading^2),
      .groups = "drop"
    )
}

# ------------------------------------------------------------
# Cronbach Alpha
# ------------------------------------------------------------

compute_alpha <- function(data, loadings) {
  constructs <- unique(loadings$latent)

  map_df(constructs, function(con) {
    items <- loadings %>%
      filter(latent == con) %>%
      pull(item)

    alpha_val <- tryCatch(
      {
        item_data <- data[, items]

        item_data <- item_data %>%
          mutate(across(everything(), ~ as.numeric(as.character(.))))

        psych::alpha(item_data)$total$raw_alpha
      },
      error = function(e) NA
    )

    tibble(
      latent = con,
      alpha = alpha_val
    )
  })
}

# ------------------------------------------------------------
# Reliability Table
# ------------------------------------------------------------

reliability_table <- function(fit, data) {
  loadings <- get_loadings(fit)

  cr_ave <- compute_cr_ave(loadings)
  alpha <- compute_alpha(data, loadings)

  alpha %>%
    left_join(cr_ave, by = "latent")
}

# ------------------------------------------------------------
# Fornell-Larcker Table
# ------------------------------------------------------------

fornell_larcker <- function(fit) {
  std <- standardizedSolution(fit)

  cor_mat <- std %>%
    filter(op == "~~", lhs != rhs) %>%
    select(lhs, rhs, est.std)

  constructs <- unique(std$lhs[std$op == "=~"])

  ave_vals <- std %>%
    filter(op == "=~") %>%
    group_by(lhs) %>%
    summarise(AVE = mean(est.std^2), .groups = "drop")

  sqrt_ave <- sqrt(ave_vals$AVE)

  names(sqrt_ave) <- ave_vals$lhs

  cor_matrix <- inspect(fit, "cor.lv")

  diag(cor_matrix) <- sqrt_ave[names(diag(cor_matrix))]

  return(cor_matrix)
}

# ------------------------------------------------------------
# CFA Loading Table
# ------------------------------------------------------------

cfa_table <- function(fit) {
  std <- standardizedSolution(fit)

  std %>%
    filter(op == "=~") %>%
    select(
      Construct = lhs,
      Item = rhs,
      Loading = est.std,
      SE = se,
      z = z,
      p = pvalue
    )
}
