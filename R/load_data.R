#' Load and wrangle data for parrot species
#'
#' @param file_species_names Path to data on species names.
#' @param file_sociality Path to data on social behaviour from BIRDBASE.
#' @param file_vocal_production_learning Path to data on vocal production
#'   learning.
#' @param file_sexual_dichromatism Path to data on sexual dichromatism.
#' @param file_sexual_size_dimorphism Path to data on sexual size dimorphism.
#'
#' @returns A tibble
#'
load_data <- function(file_species_names, file_sociality,
                      file_vocal_production_learning, file_sexual_dichromatism,
                      file_sexual_size_dimorphism) {

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

  # load sociality data
  sociality <-
    read_csv(
      file = file_sociality,
      show_col_types = FALSE
    ) |>
    # create fallback column for matching
    mutate(genus_and_species = paste(genus, species))

  # load data on vocal production learning
  vocal_production_learning <-
    readxl::read_xlsx(
      path = file_vocal_production_learning
    ) |>
    transmute(
      scientific_name = str_replace(scinam, "_", " "),
      vocal_production_learning = vocal
    )

  # load sexual dichromatism data
  sexual_dichromatism <-
    read_csv(
      file = file_sexual_dichromatism,
      show_col_types = FALSE
    ) |>
    rename(
      scientific_name = scinam,
      sexual_dichromatism = sexdic
    )

  # load sexual size dimorphism data
  sexual_size_dimorphism <-
    read_csv(
      file = file_sexual_size_dimorphism,
      show_col_types = FALSE
    )

  # create function to join datasets - first, try linking by scientific name
  # if no match, try linking by genus and species names
  join_datasets <- function(left_df, right_df, variable) {

    right_df <- dplyr::select(right_df, scientific_name, !!sym(variable))

    left_df |>
      left_join(right_df, by = "scientific_name") |>
      rename(var1 = !!sym(variable)) |>
      left_join(right_df, by = c("genus_and_species" = "scientific_name")) |>
      rename(var2 = !!sym(variable)) |>
      mutate(!!sym(variable) := coalesce(var1, var2)) |>
      dplyr::select(!c(var1, var2))

  }

  # join datasets
  species_names |>
    left_join(sociality, by = "scientific_name") |>
    join_datasets(
      vocal_production_learning,
      variable = "vocal_production_learning"
    ) |>
    join_datasets(
      sexual_dichromatism,
      variable = "sexual_dichromatism"
    ) |>
    join_datasets(
      sexual_size_dimorphism,
      variable = "sexual_size_dimorphism"
    ) |>

    # remove fallback matching column
    dplyr::select(!genus_and_species)

}
