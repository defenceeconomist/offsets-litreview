get_theme_labels <- function(input_yml = "data/mechanism_themes/proto_themes.yml") {
  if (!file.exists(input_yml)) {
    stop(sprintf("Input file not found: %s", input_yml))
  }

  data <- yaml::read_yaml(input_yml)
  themes <- data$proto_mechanism_themes
  if (is.null(themes) || length(themes) == 0) {
    return(data.frame(theme_id = character(), theme_label = character(), stringsAsFactors = FALSE))
  }

  out <- lapply(themes, function(t) {
    data.frame(
      theme_id = as.character(t$theme_id),
      theme_label = as.character(t$theme_label),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, out)
}
