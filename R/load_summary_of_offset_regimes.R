#' Load Summary of Offsets Regimes from Yaml
#'
#' @param path_to_yaml Path to the yaml fiel that contains the data
#'
#' @returns A tibble
#'
#' @export
#' @examples 
#' load_summary_of_offset_regimes()
load_summary_of_offset_regimes <- function(
  path_to_yaml = "reports/comparative_summary_of_defence_offset_regimes.yml"
) {
  

  headers <- yaml::read_yaml(path_to_yaml) |>
    purrr::pluck("headers") |>
    purrr::map_df(~.x)

  yaml::read_yaml(path_to_yaml) |>
    purrr::pluck("body") |>
    purrr::map_df(~.x) |>
    dplyr::rename(
      dplyr::any_of(setNames(headers$field, headers$label))
    )
}

