#' Rerank and deduplicate BibTeX files in a directory using RRF
#'
#' @param dir Directory containing .bib files.
#' @param k RRF constant; higher values reduce the effect of rank position.
#'
#' @returns A tibble of deduplicated, reranked entries with RRF scores.
#'
#' @export
rrf_rerank_bibtex_dir <- function(dir, k = 60) {
  if (is.null(dir) || !nzchar(dir)) {
    stop("`dir` must be a non-empty directory path.", call. = FALSE)
  }
  if (!dir.exists(dir)) {
    stop("Directory not found: ", dir, call. = FALSE)
  }

  files <- list.files(dir, pattern = "\\.bib$", full.names = TRUE)
  if (length(files) == 0) {
    stop("No .bib files found in: ", dir, call. = FALSE)
  }

  normalize_str <- function(x) {
    x <- tolower(trimws(x))
    x <- gsub("[^a-z0-9]+", " ", x)
    trimws(gsub("\\s+", " ", x))
  }

  entries <- lapply(files, function(path) {
    tbl <- bibtex_to_tibble(path = path)
    if (!nrow(tbl)) {
      return(NULL)
    }
    dplyr::mutate(
      tbl,
      source_file = basename(path),
      rank_in_file = dplyr::row_number()
    )
  })

  entries <- dplyr::bind_rows(entries)
  if (!nrow(entries)) {
    return(tibble::tibble())
  }

  entries <- dplyr::mutate(
    entries,
    doi_norm = if ("doi" %in% names(entries)) normalize_str(doi) else NA_character_,
    title_norm = if ("title" %in% names(entries)) normalize_str(title) else NA_character_,
    year_norm = if ("year" %in% names(entries)) normalize_str(year) else NA_character_,
    author_norm = if ("author" %in% names(entries)) normalize_str(author) else NA_character_
  )

  entries <- dplyr::mutate(
    entries,
    dedup_key = dplyr::case_when(
      !is.na(doi_norm) & nzchar(doi_norm) ~ paste0("doi:", doi_norm),
      !is.na(title_norm) & nzchar(title_norm) ~ paste("ty:", title_norm, year_norm, author_norm, sep = "|"),
      TRUE ~ paste0("row:", dplyr::row_number())
    ),
    rrf_component = 1 / (k + rank_in_file)
  )

  entries |>
    dplyr::group_by(dedup_key) |>
    dplyr::mutate(
      rrf_score = sum(rrf_component, na.rm = TRUE),
      n_sources = dplyr::n_distinct(source_file),
      sources = paste(sort(unique(source_file)), collapse = "; ")
    ) |>
    dplyr::slice_max(order_by = rrf_component, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::arrange(dplyr::desc(rrf_score))
}
