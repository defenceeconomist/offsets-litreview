
suppressPackageStartupMessages({
  library(yaml)
  library(dplyr)
  library(purrr)
  library(tidyr)
  library(tibble)
  library(stringr)
})

# ---- helpers ----

collapse_vec <- function(x, sep = "; ") {
  # Collapses character vectors; returns "" for NULL/empty.
  if (is.null(x) || length(x) == 0) return("")
  if (is.list(x) && !is.character(x)) x <- unlist(x, recursive = TRUE, use.names = FALSE)
  x <- as.character(x)
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0) return("")
  paste(unique(x), collapse = sep)
}

get_path <- function(x, path, default = NULL) {
  # Safe nested access for lists (e.g., path = c("C","offset_policy_design"))
  out <- x
  for (p in path) {
    if (is.null(out) || !is.list(out) || is.null(out[[p]])) return(default)
    out <- out[[p]]
  }
  out
}

normalise_record <- function(rec) {
  # Ensure required nested structures exist so downstream code doesn’t error
  rec$country  <- rec$country  %||% list()
  rec$programme <- rec$programme %||% list()
  rec$C <- rec$C %||% list(offset_policy_design = list(), procurement_context = list())
  rec$M <- rec$M %||% list(mechanism_label = list(), mechanism_narrative = "")
  rec$O <- rec$O %||% list(outcomes_positive = list(), outcomes_negative = list())
  rec$rq_tags <- rec$rq_tags %||% list()
  rec$evidence_type <- rec$evidence_type %||% list()
  rec
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- main ----

cmo_yaml_to_table <- function(yaml_path) {
  raw <- yaml::read_yaml(yaml_path)

  if (is.null(raw)) {
    stop("YAML is empty or could not be read: ", yaml_path)
  }

  # The schema expects a YAML list of records.
  if (!is.list(raw) || (length(raw) > 0 && !is.list(raw[[1]]))) {
    stop("Expected a YAML list of records. Check the file format: ", yaml_path)
  }

  recs <- map(raw, normalise_record)

  df <- tibble(
    cmo_id   = map_chr(recs, ~ .x$cmo_id %||% ""),
    citekey  = map_chr(recs, ~ .x$citekey %||% ""),
    country  = map_chr(recs, ~ collapse_vec(.x$country)),
    programme = map_chr(recs, ~ collapse_vec(.x$programme)),
    locator  = map_chr(recs, ~ .x$locator %||% ""),
    quote    = map_chr(recs, ~ .x$quote %||% ""),
    paraphrase = map_chr(recs, ~ .x$paraphrase %||% ""),

    C_offset_policy_design = map_chr(recs, ~ collapse_vec(get_path(.x, c("C","offset_policy_design"), list()))),
    C_procurement_context  = map_chr(recs, ~ collapse_vec(get_path(.x, c("C","procurement_context"),  list()))),

    M_mechanism_label      = map_chr(recs, ~ collapse_vec(get_path(.x, c("M","mechanism_label"), list()))),
    M_mechanism_narrative  = map_chr(recs, ~ get_path(.x, c("M","mechanism_narrative"), "") %||% ""),

    O_outcomes_positive    = map_chr(recs, ~ collapse_vec(get_path(.x, c("O","outcomes_positive"), list()))),
    O_outcomes_negative    = map_chr(recs, ~ collapse_vec(get_path(.x, c("O","outcomes_negative"), list()))),

    rq_tags         = map_chr(recs, ~ collapse_vec(.x$rq_tags)),
    relevance_score = map_int(recs, ~ as.integer(.x$relevance_score %||% NA_integer_)),
    confidence      = map_dbl(recs, ~ as.numeric(.x$confidence %||% NA_real_)),
    evidence_type   = map_chr(recs, ~ collapse_vec(.x$evidence_type)),
    direction       = map_chr(recs, ~ .x$direction %||% "")
  ) %>%
    mutate(
      source_file = basename(yaml_path)
    )

  df
}

# ---- optional: process a whole folder of YAML files ----

cmo_folder_to_table <- function(folder = "cmos", pattern = "\\.ya?ml$") {
  files <- list.files(folder, pattern = pattern, full.names = TRUE)
  if (length(files) == 0) stop("No YAML files found in: ", folder)

  bind_rows(lapply(files, cmo_yaml_to_table)) %>%
    arrange(citekey, cmo_id)
}

# ---- optional: quick export helpers ----

export_cmo_table <- function(df, out_csv = "data/cmo_table.csv") {
  dir.create(dirname(out_csv), showWarnings = FALSE, recursive = TRUE)
  write.csv(df, out_csv, row.names = FALSE, na = "")
  invisible(out_csv)
}


#cmo_yaml_to_table("cmo/cmo_book_1.yml") |>
 # View()


cmo_folder_to_table("cmo")
