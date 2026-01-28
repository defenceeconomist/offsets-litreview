#' load cmo
#' @examples
#' load_cmo()
load_cmo <- function(yaml_file = "cmo/articles.yml"){
  yaml::read_yaml(yaml_file)
}

