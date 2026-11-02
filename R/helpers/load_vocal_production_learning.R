#' Load data on vocal production learning
#'
#' @param file_vocal_production_learning Path to data on vocal production
#'   learning.
#'
#' @returns Tibble
#'
load_vocal_production_learning <- function(file_vocal_production_learning) {

  readxl::read_xlsx(
    path = file_vocal_production_learning
  ) |>
    transmute(
      scientific_name = standardise_scientific_names(
        str_replace(scinam, "_", " ")
      ),
      vocal_production_learning = vocal
    )

}
