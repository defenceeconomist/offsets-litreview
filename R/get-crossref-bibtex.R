library(rcrossref)
dois <- readr::read_csv("data/defence_offsets_dois.csv")
cn <- dois |>
  dplyr::pull(DOI) |>
  rcrossref::cr_cn()

unlist(cn) |>
  paste(collapse = "\n") |>
  write("crossref.bib")
