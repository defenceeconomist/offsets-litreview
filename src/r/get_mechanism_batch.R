get_mechanism_batch <- function(input_csv = "data/cmo_statements.csv",
                                n = 20,
                                offset = 0) {
  if (!is.numeric(n) || length(n) != 1 || n < 1) {
    stop("n must be a single number >= 1.")
  }
  if (!is.numeric(offset) || length(offset) != 1 || offset < 0) {
    stop("offset must be a single number >= 0.")
  }
  if (!file.exists(input_csv)) {
    stop(sprintf("Input file not found: %s", input_csv))
  }

  df <- utils::read.csv(input_csv, stringsAsFactors = FALSE)
  required_cols <- c("chunk_id", "mechanism_statement")
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(sprintf("Missing required columns: %s", paste(missing_cols, collapse = ", ")))
  }

  start_idx <- offset + 1
  if (start_idx > nrow(df)) {
    out <- df[0, required_cols, drop = FALSE]
    rownames(out) <- NULL
    return("")
  }

  end_idx <- min(offset + n, nrow(df))
  out <- df[start_idx:end_idx, required_cols, drop = FALSE]
  rownames(out) <- NULL
  blocks <- lapply(seq_len(nrow(out)), function(i) {
    chunk_id <- as.character(out$chunk_id[i])
    mechanism_statement <- as.character(out$mechanism_statement[i])
    paste0(
      "chunk_id: ", chunk_id, "\n",
      "mechanism_statement: ", mechanism_statement, "\n",
      "---"
    )
  })
  paste(unlist(blocks), collapse = "\n")
}
