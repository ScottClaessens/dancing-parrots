#' Load data on foraging group size from Beauchamp (2024)
#'
#' @param file_sociality_beauchamp Path to data on foraging group size from
#'   Beauchamp (2024).
#'
#' @returns Tibble
#'
load_sociality_beauchamp <- function(file_sociality_beauchamp) {

  readxl::read_xlsx(
    path = file_sociality_beauchamp
  ) |>
    transmute(
      scientific_name = standardise_scientific_names(
        str_replace(`Old species name`, "_", " ")
      ),
      log_foraging_group_size = `Geometric mean group size`,
      foraging_group_research_effort = as.integer(`Research effort`)
    )

}
