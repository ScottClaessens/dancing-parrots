#' Load species names
#'
#' @param file_species_names Path to data on species names.
#'
#' @returns Tibble
#'
load_species_names <- function(file_species_names) {

  read_csv(
    file = file_species_names,
    show_col_types = FALSE
  ) |>
    transmute(
      scientific_name = `Scientific Name`,
      common_name = str_to_sentence(`English Common Name`)
    )

}
