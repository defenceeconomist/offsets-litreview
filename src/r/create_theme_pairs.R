create_theme_pairs <- function(input_yml = "data/mechanism_themes/proto_themes.yml",
                               output_csv = "data/mechanism_themes/theme_pairs.csv") {
  if (!file.exists(input_yml)) {
    stop(sprintf("Input file not found: %s", input_yml))
  }

  data <- yaml::read_yaml(input_yml)
  themes <- data$proto_mechanism_themes
  if (is.null(themes) || length(themes) < 2) {
    out <- data.frame(
      pair_id = character(),
      theme_a_id = character(),
      theme_a_label = character(),
      theme_a_explanation = character(),
      theme_b_id = character(),
      theme_b_label = character(),
      theme_b_explanation = character(),
      stringsAsFactors = FALSE
    )
    utils::write.csv(out, output_csv, row.names = FALSE)
    return(out)
  }

  ids <- vapply(themes, function(t) as.character(t$theme_id), character(1))
  labels <- vapply(themes, function(t) as.character(t$theme_label), character(1))
  expls <- vapply(themes, function(t) as.character(t$mechanism_explanation), character(1))

  pairs <- list()
  idx <- 1
  for (i in seq_len(length(ids) - 1)) {
    for (j in (i + 1):length(ids)) {
      pairs[[idx]] <- data.frame(
        pair_id = sprintf("P%03d", idx),
        theme_a_id = ids[i],
        theme_a_label = labels[i],
        theme_a_explanation = expls[i],
        theme_b_id = ids[j],
        theme_b_label = labels[j],
        theme_b_explanation = expls[j],
        stringsAsFactors = FALSE
      )
      idx <- idx + 1
    }
  }

  out <- do.call(rbind, pairs)
  utils::write.csv(out, output_csv, row.names = FALSE)
  out
}
