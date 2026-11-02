#' Load data on social behaviour from Tobias et al. (2016)
#'
#' @param file_sociality_tobias Path to data on social behaviour from Tobias
#'   et al. (2016).
#'
#' @returns Tibble
#'
load_sociality_tobias <- function(file_sociality_tobias) {

  readxl::read_xlsx(
    path = file_sociality_tobias
  ) |>
    transmute(
      scientific_name = standardise_scientific_names(Species),
      social_bonds = `Social bond`
    ) |>
    suppressWarnings()

}
