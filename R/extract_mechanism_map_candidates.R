#!/usr/bin/env Rscript

`%||%` <- function(x, y) if (is.null(x)) y else x

stopifnot(requireNamespace("yaml", quietly = TRUE))

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default = NULL) {
  idx <- match(flag, args)
  if (is.na(idx)) return(default)
  if (idx == length(args)) return(default)
  args[[idx + 1]]
}

cmo_file <- get_arg("--cmo_file", "cmo/arms_trade_offsets_chapters.yml")
mechanism_map_file <- get_arg("--mechanism_map_file", "cmo/mechanism_map.yml")
normalized_tags_file <- get_arg("--normalized_tags_file", "cmo/normalized_tags.yml")
top_n <- as.integer(get_arg("--top_n", "50"))
out_file <- get_arg("--out", "")

if (!file.exists(cmo_file)) stop("Missing --cmo_file: ", cmo_file)
if (!file.exists(mechanism_map_file)) stop("Missing --mechanism_map_file: ", mechanism_map_file)
if (!file.exists(normalized_tags_file)) stop("Missing --normalized_tags_file: ", normalized_tags_file)

mm <- yaml::read_yaml(mechanism_map_file)
mapped <- names(mm$tag_to_theme %||% list())

spec <- yaml::read_yaml(normalized_tags_file)
alias <- spec$aliases %||% list()

normalize_tag <- function(tag) {
  if (is.null(tag) || is.na(tag) || tag == "") return(NA_character_)
  tag <- tolower(tag)
  tag <- gsub("[^a-z0-9]+", "_", tag)
  tag <- gsub("_+", "_", tag)
  tag <- gsub("^_|_$", "", tag)
  if (!is.null(alias[[tag]])) tag <- alias[[tag]]
  tag
}

raw_counts <- list()     # raw_tag -> count
canonical_counts <- list() # canonical_tag -> count
canonical_examples <- list() # canonical_tag -> list of examples

add_count <- function(map, k) {
  map[[k]] <- (map[[k]] %||% 0L) + 1L
  map
}

add_example <- function(tag, doc, cmo_id, mechanism, quote) {
  if (is.null(canonical_examples[[tag]])) canonical_examples[[tag]] <<- list()
  if (length(canonical_examples[[tag]]) >= 3) return()
  canonical_examples[[tag]] <<- append(canonical_examples[[tag]], list(list(
    doc = doc,
    cmo_id = cmo_id,
    mechanism = mechanism %||% "",
    supporting_evidence = quote %||% ""
  )))
}

x <- yaml::read_yaml(cmo_file)
for (doc in names(x)) {
  cmos <- x[[doc]]$cmos
  if (is.null(cmos)) next
  for (cmo_id in names(cmos)) {
    cmo <- cmos[[cmo_id]]
    mt <- cmo$mechanism_tags
    if (is.null(mt)) next
    mt <- as.character(unlist(mt, use.names = FALSE))
    mt <- mt[mt != ""]
    if (length(mt) == 0) next
    for (raw_tag in mt) {
      raw_counts <- add_count(raw_counts, raw_tag)
      can <- normalize_tag(raw_tag)
      if (is.na(can) || can == "") next
      canonical_counts <- add_count(canonical_counts, can)
      add_example(can, doc, cmo_id, cmo$mechanism, cmo$supporting_evidence)
    }
  }
}

canonical_counts_vec <- sort(unlist(canonical_counts), decreasing = TRUE)
unmapped <- setdiff(names(canonical_counts_vec), mapped)
if (length(unmapped) == 0) {
  out <- list(
    mechanism_map_yaml = mm,
    normalized_tags_yaml = spec,
    candidate_mechanism_tags = list()
  )
} else {
  keep <- head(unmapped, top_n)
  candidates <- lapply(keep, function(tag) {
    exs <- canonical_examples[[tag]] %||% list()
    default_desc <- ""
    if (length(exs) > 0 && !is.null(exs[[1]]$mechanism) && nzchar(exs[[1]]$mechanism)) {
      default_desc <- exs[[1]]$mechanism
    } else {
      default_desc <- "TODO: write 1–3 sentence definition of this mechanism."
    }
    examples <- lapply(exs, function(e) {
      out <- list(
        doc = e$doc,
        cmo_id = e$cmo_id,
        mechanism = e$mechanism
      )
      if (!is.null(e$supporting_evidence) && nzchar(e$supporting_evidence)) {
        out$supporting_evidence <- e$supporting_evidence
      }
      out
    })
    list(
      raw_tag = tag,
      count = as.integer(canonical_counts_vec[[tag]]),
      description = default_desc,
      examples = examples
    )
  })

  out <- list(
    mechanism_map_yaml = mm,
    normalized_tags_yaml = spec,
    candidate_mechanism_tags = candidates
  )
}

yaml_text <- yaml::as.yaml(out)
if (!is.null(out_file) && nzchar(out_file)) {
  writeLines(yaml_text, out_file, useBytes = TRUE)
} else {
  cat(yaml_text)
}
