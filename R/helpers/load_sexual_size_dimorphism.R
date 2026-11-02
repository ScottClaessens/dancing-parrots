#' Load data on sexual size dimorphism
#'
#' @param file_sexual_size_dimorphism Path to data on sexual size dimorphism.
#'
#' @returns Tibble
#'
load_sexual_size_dimorphism <- function(file_sexual_size_dimorphism) {

  read_csv(
    file = file_sexual_size_dimorphism,
    show_col_types = FALSE
  ) |>
    mutate(scientific_name = standardise_scientific_names(scientific_name))

}
