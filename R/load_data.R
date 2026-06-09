#' Load and wrangle data for parrot species
#'
#' @param file_species_names Path to data on species names.
#' @param file_birdbase Path to data on social behaviour from BIRDBASE.
#'
#' @returns A tibble
#'
load_data <- function(file_species_names, file_birdbase) {

  # load species names
  species_names <-
    read_csv(
      file = file_species_names,
      show_col_types = FALSE
    ) |>
    transmute(
      scientific_name = `Scientific Name`,
      common_name = str_to_sentence(`English Common Name`)
    )

  # load birdbase data
  birdbase <-
    read_csv(
      file = file_birdbase,
      show_col_types = FALSE
    )

  # join datasets and return
  species_names |>
    left_join(birdbase, by = "scientific_name")

}
