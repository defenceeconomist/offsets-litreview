#!/usr/bin/env Rscript

count_bibtex_articles <- function(path = "path/to/file"){

  if (!file.exists(path)) {
    cat("File not found:", path, "\n")
    quit(status = 1)
  }

  lines <- readLines(path, warn = FALSE)
  entry_lines <- grepl("^\\s*@", lines)
  entry_headers <- lines[entry_lines]

  types <- tolower(gsub("^\\s*@([^\\{\\(]+).*$", "\\1", entry_headers))
  type_counts <- sort(table(types), decreasing = TRUE)

  cat("Total entries:", length(entry_headers), "\n")
  if (length(type_counts) > 0) {
    cat("Entries by type:\n")
    print(type_counts)
  }

}

count_bibtex_relevant <- function(path = "path/to/file"){

  if (!file.exists(path)) {
    cat("File not found:", path, "\n")
    quit(status = 1)
  }

  lines <- readLines(path, warn = FALSE)
  entry_start_idx <- which(grepl("^\\s*@", lines))

  if (length(entry_start_idx) == 0) {
    cat("Total entries: 0\n")
    cat("Relevant entries: 0\n")
    return(invisible(0))
  }

  entry_end_idx <- c(entry_start_idx[-1] - 1, length(lines))
  entries <- mapply(
    function(s, e) paste(lines[s:e], collapse = "\n"),
    entry_start_idx,
    entry_end_idx,
    SIMPLIFY = TRUE
  )

  relevant_pattern <- "(?i)\\brelevant\\s*=\\s*(\\{\\s*true\\s*\\}|\"\\s*true\\s*\"|true)(?=\\s*[,\\n\\r}]|$)"
  relevant_flags <- grepl(relevant_pattern, entries, perl = TRUE)

  cat("Total entries:", length(entries), "\n")
  cat("Relevant entries:", sum(relevant_flags), "\n")

  invisible(sum(relevant_flags))
}
