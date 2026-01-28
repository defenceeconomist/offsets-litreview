#' Consolidate CMO records into a single table with normalized tags.
#' @examples
#' consolidate_cmo()
consolidate_cmo <- function(
  cmo_dir = "cmo",
  output_csv = "data/cmo_statement.csv",
  normalized_tags_file = "cmo/normalized_tags.yml",
  mechanism_map_file = "cmo/mechanism_map.yml"
) {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Package 'yaml' is required.")
  }

  cmo_files <- list.files(cmo_dir, pattern = "\\.yml$", full.names = TRUE)
  cmo_files <- cmo_files[!basename(cmo_files) %in% c("normalized_tags.yml", "mechanism_map.yml")]
  if (length(cmo_files) == 0) {
    stop("No CMO YAML files found.")
  }

  alias_map <- list()
  if (file.exists(normalized_tags_file)) {
    spec <- yaml::read_yaml(normalized_tags_file)
    if (!is.null(spec$aliases)) {
      alias_map <- spec$aliases
    }
  }

  normalize_tag <- function(tag) {
    if (is.null(tag) || is.na(tag) || tag == "") return(NA_character_)
    tag <- tolower(tag)
    tag <- gsub("[^a-z0-9]+", "_", tag)
    tag <- gsub("_+", "_", tag)
    tag <- gsub("^_|_$", "", tag)
    if (!is.null(alias_map[[tag]])) {
      tag <- alias_map[[tag]]
    }
    tag
  }

  normalize_tags <- function(tags) {
    if (is.null(tags)) return(character())
    out <- vapply(tags, normalize_tag, character(1))
    out <- out[!is.na(out) & out != ""]
    unique(out)
  }

  paste_tags <- function(tags) {
    if (is.null(tags) || length(tags) == 0) return("")
    tags <- unlist(tags)
    if (length(tags) == 0) return("")
    paste(tags, collapse = ";")
  }

  records <- list()
  record_idx <- 0

  for (file in cmo_files) {
    source_yaml <- basename(file)
    data <- yaml::read_yaml(file)
    for (doc in names(data)) {
      entry <- data[[doc]]
      cmos <- entry$cmos
      if (is.null(cmos) || length(cmos) == 0) next
      for (cmo_id in names(cmos)) {
        cmo <- cmos[[cmo_id]]
        record_idx <- record_idx + 1
        records[[record_idx]] <- data.frame(
          source_yaml = source_yaml,
          source_file = doc,
          cmo_id = cmo_id,
          context = cmo$context %||% "",
          mechanism = cmo$mechanism %||% "",
          outcome = cmo$outcome %||% "",
          context_tags_raw = paste_tags(cmo$context_tags),
          mechanism_tags_raw = paste_tags(cmo$mechanism_tags),
          outcome_tags_raw = paste_tags(cmo$outcome_tags),
          context_tags = paste_tags(sort(normalize_tags(cmo$context_tags))),
          mechanism_tags = paste_tags(sort(normalize_tags(cmo$mechanism_tags))),
          outcome_tags = paste_tags(sort(normalize_tags(cmo$outcome_tags))),
          programme = cmo$programme %||% "",
          country = cmo$country %||% "",
          evidence_type = cmo$evidence_type %||% "",
          evidence_type_narrative = cmo$evidence_type_narrative %||% "",
          research_questions_mapped = paste_tags(cmo$research_questions_mapped),
          supporting_evidence = cmo$supporting_evidence %||% "",
          supporting_evidence_paraphrase = cmo$supporting_evidence_paraphrase %||% "",
          confidence = cmo$confidence %||% "",
          confidence_justification = cmo$confidence_justification %||% "",
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(records) == 0) {
    stop("No CMO records found.")
  }

  out <- do.call(rbind, records)

  # Optional mechanism tag -> theme mapping (for pathway summaries / mechanism map).
  if (!is.null(mechanism_map_file) && file.exists(mechanism_map_file)) {
    mm <- yaml::read_yaml(mechanism_map_file)
    tag_to_theme <- mm$tag_to_theme %||% list()
    themes <- mm$themes %||% list()

    split_tags_str <- function(x) {
      if (is.null(x) || is.na(x) || x == "") return(character())
      strsplit(x, ";", fixed = TRUE)[[1]]
    }

    map_themes_keys <- function(tags_str) {
      tags <- split_tags_str(tags_str)
      if (length(tags) == 0) return("")
      keys <- vapply(
        tags,
        function(t) tag_to_theme[[t]] %||% NA_character_,
        character(1)
      )
      keys <- keys[!is.na(keys) & keys != ""]
      if (length(keys) == 0) return("")
      paste(sort(unique(keys)), collapse = ";")
    }

    map_themes_labels <- function(tags_str) {
      keys_str <- map_themes_keys(tags_str)
      if (keys_str == "") return("")
      keys <- split_tags_str(keys_str)
      labels <- vapply(
        keys,
        function(k) themes[[k]]$label %||% k,
        character(1)
      )
      paste(labels, collapse = ";")
    }

    out$mechanism_theme_keys <- vapply(out$mechanism_tags, map_themes_keys, character(1))
    out$mechanism_theme_labels <- vapply(out$mechanism_tags, map_themes_labels, character(1))
  }

  dir.create(dirname(output_csv), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(out, output_csv, row.names = FALSE, na = "")
  invisible(out)
}

`%||%` <- function(x, y) if (is.null(x)) y else x
