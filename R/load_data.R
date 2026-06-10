#' Load and wrangle data for parrot species
#'
#' @param file_species_names Path to data on species names.
#' @param file_birdbase Path to data on social behaviour from BIRDBASE.
#' @param file_vocal_production_learning Path to data on vocal production
#'   learning.
#'
#' @returns A tibble
#'
load_data <- function(file_species_names, file_birdbase,
                      file_vocal_production_learning) {

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
    ) |>
    mutate(genus_and_species = paste(genus, species))

  # load data on vocal production learning
  vocal_production_learning <-
    readxl::read_xlsx(
      path = file_vocal_production_learning
    ) |>
    transmute(
      scientific_name = str_replace(scinam, "_", " "),
      vocal = vocal
    )

  # join datasets and return
  species_names |>
    left_join(birdbase, by = "scientific_name") |>
    left_join(
      vocal_production_learning,
      by = c("genus_and_species" = "scientific_name")
    ) |>
    dplyr::select(!genus_and_species)

}
