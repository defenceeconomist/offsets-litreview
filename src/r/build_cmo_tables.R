build_cmo_tables <- function(data_dir = "data/cmo",
                             output_csv = "data/cmo_statements.csv") {
  files <- list.files(data_dir, pattern = "\\.ya?ml$", full.names = TRUE)
  if (length(files) == 0) {
    empty <- tibble::tibble(
      file_id = character(),
      chunk_id = character(),
      context_statement = character(),
      mechanism_statement = character(),
      outcome_statement = character(),
      confidence = character(),
      confidience_justification = character(),
      evidence_paraphrase = character(),
      evidence_quote = character(),
      evidence_type = character(),
      evidence_type_narrative = character(),
      research_questions_mapped = character(),
      country = character(),
      programme = character()
    )
    utils::write.csv(empty, output_csv, row.names = FALSE)
    return(empty)
  }

  result <- purrr::map_dfr(files, function(path_to_file) {
    yaml_data <- yaml::read_yaml(path_to_file)
    if (length(yaml_data) == 0) {
      return(NULL)
    }

    purrr::imap_dfr(yaml_data, function(entry, file_id) {
      cmos <- purrr::pluck(entry, "cmos", .default = list())
      if (length(cmos) == 0) {
        return(NULL)
      }

      purrr::imap_dfr(cmos, function(cmo, chunk_id) {
        tibble::tibble(
          file_id = file_id,
          chunk_id = chunk_id,
          context_statement = purrr::pluck(cmo, "context", .default = NA_character_),
          mechanism_statement = purrr::pluck(cmo, "mechanism", .default = NA_character_),
          outcome_statement = purrr::pluck(cmo, "outcome", .default = NA_character_),
          confidence = purrr::pluck(cmo, "confidence", .default = NA_character_),
          confidience_justification = purrr::pluck(cmo, "confidence_justification", .default = NA_character_),
          evidence_paraphrase = purrr::pluck(cmo, "supporting_evidence_paraphrase", .default = NA_character_),
          evidence_quote = purrr::pluck(cmo, "supporting_evidence", .default = NA_character_),
          evidence_type = purrr::pluck(cmo, "evidence_type", .default = NA_character_),
          evidence_type_narrative = purrr::pluck(cmo, "evidence_type_narrative", .default = NA_character_),
          research_question_mapped = purrr::pluck(cmo, "research_questions_mapped", .default = NA_character_) |> paste(collapse = "; "),
          country = purrr::pluck(cmo, "country", .default = NA_character_) |> paste(collapse = "; "),
          programme = purrr::pluck(cmo, "programme", .default = NA_character_) |> paste(collapse = "; ")
        )
      })
    })
  })

  utils::write.csv(result, output_csv, row.names = FALSE)
  result
}
