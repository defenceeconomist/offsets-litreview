#!/usr/bin/env Rscript
# Compress PDFs in a directory using ps2pdf -dPDFSETTINGS=/ebook.

find_tool <- function(name) {
  path <- Sys.which(name)
  if (path == "") {
    stop(paste("Missing required tool:", name))
  }
  path
}

compress_pdf <- function(input, output) {
  system2(
    "ps2pdf",
    args = c("-dPDFSETTINGS=/ebook", shQuote(input), shQuote(output)),
    stdout = NULL,
    stderr = NULL
  )
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  in_dir <- ifelse(length(args) >= 1, args[1], "books/economics_offsets_chapters")
  out_dir <- ifelse(length(args) >= 2, args[2], file.path(in_dir, "compressed"))

  invisible(find_tool("ps2pdf"))

  if (!dir.exists(in_dir)) stop("Input directory does not exist: ", in_dir)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  files <- list.files(in_dir, pattern = "\\.pdf$", full.names = TRUE)
  if (length(files) == 0) stop("No PDFs found in: ", in_dir)

  for (input in files) {
    output <- file.path(out_dir, basename(input))
    if (file.exists(output)) {
      message("Skipping existing: ", basename(output))
      next
    }
    message("Compressing: ", basename(input))
    compress_pdf(input, output)
  }
}
