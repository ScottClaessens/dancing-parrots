#' Load data on sexual dichromatism
#'
#' @param file_sexual_dichromatism Path to data on sexual dichromatism.
#'
#' @returns Tibble
#'
load_sexual_dichromatism <- function(file_sexual_dichromatism) {

  read_csv(
    file = file_sexual_dichromatism,
    show_col_types = FALSE
  ) |>
    transmute(
      scientific_name = standardise_scientific_names(scinam),
      sexual_dichromatism = sexdic
    )

}
