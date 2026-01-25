#' Convert BibTeX text or file to a tibble
#'
#' @param path Path to a .bib file. Use either `path` or `bibtext`.
#' @param bibtext BibTeX text as a single string or character vector.
#'
#' @returns A tibble with one row per entry.
#'
#' @export
bibtex_to_tibble <- function(path = NULL, bibtext = NULL, check = "warn") {
  if (is.null(path) && is.null(bibtext)) {
    stop("Provide either `path` or `bibtext`.", call. = FALSE)
  }
  if (!is.null(path) && !is.null(bibtext)) {
    stop("Use only one of `path` or `bibtext`.", call. = FALSE)
  }

  if (!is.null(path)) {
    if (!file.exists(path)) {
      stop("File not found: ", path, call. = FALSE)
    }
    raw <- readLines(path, warn = FALSE)
  } else {
    raw <- bibtext
  }

  if (length(raw) == 0) {
    return(tibble::tibble())
  }

  first_at <- match(TRUE, grepl("^\\s*@", raw))
  if (is.na(first_at)) {
    return(tibble::tibble())
  }
  raw <- raw[first_at:length(raw)]
  text <- paste(raw, collapse = "\n")

  bib <- if (requireNamespace("RefManageR", quietly = TRUE)) {
    tmp <- tempfile(fileext = ".bib")
    on.exit(unlink(tmp), add = TRUE)
    writeLines(text, tmp, useBytes = TRUE)
    RefManageR::ReadBib(file = tmp, check = check)
  } else if (requireNamespace("bibtex", quietly = TRUE)) {
    bibtex::read.bib(textConnection(text))
  } else {
    stop("Install RefManageR or bibtex to parse BibTeX.", call. = FALSE)
  }

  if (length(bib) == 0) {
    return(tibble::tibble())
  }

  entry_to_row <- function(entry) {
    if (inherits(entry, "BibEntry")) {
      fields <- unclass(entry)[[1]]
    } else {
      fields <- as.list(entry)
    }
    if (!is.null(names(fields))) {
      keep <- nzchar(names(fields))
      fields <- fields[keep]
    }
    fields <- lapply(fields, function(value) {
      if (inherits(value, "person")) {
        paste(format(value), collapse = " and ")
      } else if (is.list(value)) {
        paste(unlist(value), collapse = "; ")
      } else if (length(value) == 0) {
        NA_character_
      } else {
        as.character(value)
      }
    })

    fields$bibkey <- attr(entry, "key", exact = TRUE)
    fields$entry_type <- attr(entry, "bibtype", exact = TRUE)
    fields
  }

  entries <- lapply(bib, entry_to_row)
  all_names <- sort(unique(unlist(lapply(entries, names))))
  all_names <- all_names[nzchar(all_names)]

  rows <- lapply(entries, function(fields) {
    out <- setNames(vector("list", length(all_names)), all_names)
    for (nm in names(fields)) {
      out[[nm]] <- fields[[nm]]
    }
    out
  })

  dplyr::bind_rows(rows)
}
