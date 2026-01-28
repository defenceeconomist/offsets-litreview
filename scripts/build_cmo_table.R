suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
  library(purrr)
  library(readr)
  library(tidyr)
  library(tibble)
  library(yaml)
})

source("R/load_cmo_yaml.R")

combine_parts <- function(...) {
  parts <- c(...)
  parts <- parts[!is.na(parts) & nzchar(parts)]
  if (length(parts) == 0) return("")
  paste(parts, collapse = "; ")
}

auto_tag <- function(text) {
  t <- str_to_lower(text %||% "")
  tags <- character(0)

  if (str_detect(t, "interoperab|standardis|standardiz|readiness|security of supply|supply security|alliance|nato")) {
    tags <- c(tags, "RQ1")
  }
  if (str_detect(t, "co-development|codevelopment|co-production|coproduction|joint venture|partnership|collaboration|industrial cooperation|sustainment|mro|supply chain|technology transfer|licensed production")) {
    tags <- c(tags, "RQ2")
  }
  if (str_detect(t, "corruption|opacity|rent|delay|overcost|cost|inflation|market distortion|fragmentation|export-control|itar|governance|risk|penalt")) {
    tags <- c(tags, "RQ3")
  }
  if (str_detect(t, "success|benefit|positive|durable|integration|capability|collaboration")) {
    tags <- c(tags, "RQ4")
  }
  if (str_detect(t, "negative|inefficien|failure|distortion|corrupt|delay|overcost|problem|controvers")) {
    tags <- c(tags, "RQ5")
  }

  if (length(tags) == 0 && str_detect(t, "offset")) {
    tags <- c(tags, "RQ2")
  }
  if (length(tags) == 0) return("")
  paste(unique(tags), collapse = "; ")
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- YAML records ----

yaml_df <- cmo_folder_to_table("cmo") %>%
  mutate(
    source_type = "yaml",
    context_text = purrr::pmap_chr(
      list(C_offset_policy_design, C_procurement_context),
      ~ combine_parts(
        if (nzchar(.x)) paste0("offset_policy_design: ", .x) else "",
        if (nzchar(.y)) paste0("procurement_context: ", .y) else ""
      )
    ),
    mechanism_text = M_mechanism_narrative,
    outcome_text = purrr::pmap_chr(
      list(O_outcomes_positive, O_outcomes_negative),
      ~ combine_parts(
        if (nzchar(.x)) paste0("positive: ", .x) else "",
        if (nzchar(.y)) paste0("negative: ", .y) else ""
      )
    ),
    narrative_text = ""
  )

# ---- QMD narrative notes ----

parse_qmd_notes <- function(path) {
  lines <- readLines(path, warn = FALSE)
  lines <- gsub("\t", " ", lines)

  heading_idx <- grep("^###\\s+", lines)
  if (length(heading_idx) == 0) return(tibble())

  heading_idx <- c(heading_idx, length(lines) + 1)
  map_dfr(seq_len(length(heading_idx) - 1), function(i) {
    start <- heading_idx[i]
    end <- heading_idx[i + 1] - 1
    title <- str_trim(str_remove(lines[start], "^###\\s+"))
    segment <- lines[start:end]

    extract_line <- function(pattern) {
      line <- segment[grepl(pattern, segment)]
      if (length(line) == 0) return("")
      str_trim(str_remove(line[1], pattern))
    }

    context <- extract_line("^\\* \\*\\*Context(?: \\([Cc]\\))?:\\*\\*\\s*")
    mechanism <- extract_line("^\\* \\*\\*Mechanism(?: \\([Mm]\\))?:\\*\\*\\s*")
    outcome <- extract_line("^\\* \\*\\*Outcome(?: \\([Oo]\\))?:\\*\\*\\s*")
    narrative <- extract_line("^\\* \\*\\*Narrative:\\*\\*\\s*")

    chapter_slug <- str_replace_all(str_to_lower(title), "[^a-z0-9]+", "_")
    chapter_slug <- str_replace_all(chapter_slug, "^_+|_+$", "")

    tibble(
      cmo_id = paste0(tools::file_path_sans_ext(basename(path)), "_", chapter_slug, "_note"),
      citekey = tools::file_path_sans_ext(basename(path)),
      country = "",
      programme = "",
      locator = title,
      quote = "",
      paraphrase = "",
      C_offset_policy_design = "",
      C_procurement_context = "",
      M_mechanism_label = "",
      M_mechanism_narrative = "",
      O_outcomes_positive = "",
      O_outcomes_negative = "",
      rq_tags = "",
      relevance_score = NA_integer_,
      confidence = NA_real_,
      evidence_type = "narrative_summary",
      direction = "",
      source_file = basename(path),
      context_text = context,
      mechanism_text = mechanism,
      outcome_text = outcome,
      narrative_text = narrative,
      source_type = "qmd_note"
    )
  })
}

qmd_files <- list.files("cmo", pattern = "\\.qmd$", full.names = TRUE)
qmd_files <- qmd_files[!basename(qmd_files) %in% c("cmo-statements.qmd", "artlcles.qmd")]

qmd_df <- map_dfr(qmd_files, parse_qmd_notes)

# ---- Tagging ----

all_df <- bind_rows(yaml_df, qmd_df) %>%
  mutate(
    text_for_tagging = str_squish(paste(context_text, mechanism_text, outcome_text, narrative_text, paraphrase, quote))
  ) %>%
  mutate(
    rq_tag_source = ifelse(nzchar(rq_tags), "existing", "auto"),
    rq_tags = ifelse(nzchar(rq_tags), rq_tags, purrr::map_chr(text_for_tagging, auto_tag))
  ) %>%
  select(-text_for_tagging)

# ---- Export ----

ordered_cols <- c(
  "cmo_id", "citekey", "country", "programme", "locator", "quote", "paraphrase",
  "C_offset_policy_design", "C_procurement_context",
  "M_mechanism_label", "M_mechanism_narrative",
  "O_outcomes_positive", "O_outcomes_negative",
  "rq_tags", "relevance_score", "confidence", "evidence_type", "direction", "source_file",
  "context_text", "mechanism_text", "outcome_text", "narrative_text", "source_type", "rq_tag_source"
)

all_df <- all_df %>%
  mutate(across(all_of(ordered_cols), ~ ifelse(is.na(.x), "", .x))) %>%
  select(all_of(ordered_cols))

readr::write_csv(all_df, "data/cmo_statement.csv", na = "")
