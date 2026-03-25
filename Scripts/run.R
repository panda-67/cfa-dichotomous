RUN_MODE <- "PRETEST"
source("Scripts/main.R")
pre <- result

RUN_MODE <- "POST TEST"
source("Scripts/main.R")
post <- result

model <- paste(readLines("Models/cfa_post_test_model.txt"), collapse = "\n")

pre_data <- pre$data |> mutate(time = "pre")
post_data <- post$data |> mutate(time = "post")

rmarkdown::render(
  input = here::here("R/Rmd/report.Rmd"),
  params = list(title = "CFA Pre–Post Singkil Report"),
  output_format = "pdf_document",
  output_file = "final_report.pdf",
  output_dir = "Reports"
)

rmarkdown::render(
  input = here::here("R/Rmd/descriptive_report.Rmd"),
  output_format = "pdf_document",
  output_file = "descriptive_report.pdf",
  output_dir = "Reports"
)

# ===== INVARIANTS ===================

combined <- bind_rows(pre_data, post_data)

fit_config <- lavaan::cfa(
  model,
  data = combined,
  group = "time",
  estimator = "WLSMV",
  ordered = names(pre$data)
)

fit_metric <- lavaan::cfa(
  model,
  data = combined,
  group = "time",
  group.equal = "loadings",
  estimator = "WLSMV",
  ordered = names(pre$data)
)

lavaan::fitMeasures(fit_config, c("cfi", "rmsea", "srmr"))
lavaan::fitMeasures(fit_metric, c("cfi", "rmsea", "srmr"))

# ====== LATENT DIFFERENT ==================

posttest_model <- "
F1 =~ i4 + i11 + i13
F2 =~ i9 + i10 + i12 + i15
"
items <- c("i4", "i11", "i13", "i9", "i10", "i12", "i15")

fit_scalar <- lavaan::cfa(
  posttest_model,
  data = combined,
  group = "time",
  estimator = "WLSMV",
  ordered = names(pre$data),
  group.equal = c("loadings", "thresholds"),
  meanstructure = TRUE
)


fit_post <- lavaan::cfa(
  posttest_model,
  data = subset(combined, time == "post"),
  estimator = "WLSMV",
  ordered = items
)

lavaan::inspect(fit_post, "cor.lv")


lavaan::lavInspect(fit_scalar, "cov.lv")
lavaan::fitMeasures(fit_scalar, c("cfi", "rmsea", "srmr"))

latent_means <- parameterEstimates(fit_scalar)
latent_means[latent_means$op == "~1", c("lhs", "est", "se", "z", "pvalue")]

parameterEstimates(fit_scalar) |>
  filter(op == "~1") |>
  select(Factor = lhs, Estimate = est, SE = se, Z = z, P = pvalue)

means <- lavInspect(fit_scalar, "mean.lv")

means_df <- data.frame(
  factor = names(means[[2]]),
  value = as.numeric(means[[2]])
)

semPlot::semPaths(fit_pre)
semPlot::semPaths(fit_post_1f)

library(ggplot2)

ggplot(means_df, aes(x = factor, y = value)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Latent Mean Differences (Group2 vs Group1)",
    y = "Latent Mean Difference"
  )
