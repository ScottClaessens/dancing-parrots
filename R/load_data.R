#' Load and wrangle data for parrot species
#'
#' The functions loads various datasets from the /data directory, wrangles them,
#' and joins them together to produce the primary dataset for the study.
#'
#' @param file_species_names Path to data on species names.
#' @param file_sociality_birdbase Path to data on social behaviour from
#'   BIRDBASE.
#' @param file_sociality_tobias Path to data on social behaviour from Tobias
#'   et al. (2016).
#' @param file_sociality_beauchamp Path to data on foraging group size from
#'   Beauchamp (2024).
#' @param file_vocal_production_learning Path to data on vocal production
#'   learning.
#' @param file_sexual_dichromatism Path to data on sexual dichromatism.
#' @param file_sexual_size_dimorphism Path to data on sexual size dimorphism.
#' @param file_brain_size_hooper Path to data on brain size from Hooper et al.
#'   (2022).
#' @param file_brain_size_hardie Path to data on brain size from Hardie and
#'   Cooney (2023).
#' @param file_brain_size_tsuboi Path to data on brain size from Tsuboi et al.
#'   (2018).
#'
#' @returns A tibble with 406 rows and 19 columns:
#'   \describe{
#'     \item{scientific_name}{Character. The scientific name (genus and species
#'       names) for the species.}
#'     \item{common_name}{Character. Common name for the species.}
#'     \item{order}{Character. Taxonomic order name.}
#'     \item{family}{Character. Taxonomic family name.}
#'     \item{genus}{Character. Taxonomic genus name.}
#'     \item{species}{Character. Taxonomic species name.}
#'     \item{colonial}{Factor. Absence/presence of colonial nesting. Taken from
#'       BIRDBASE.}
#'     \item{social}{Factor. Absence/presence of sociality (i.e., living with
#'       large numbers of birds, mixed species flocks, seasonal flocks of the
#'       same species). Taken from BIRDBASE.}
#'     \item{pairs_and_family_groups}{Factor. Absence/presence of living in
#'       pairs and family groups. Taken from BIRDBASE.}
#'     \item{singly_and_pairs}{Factor. Absence/presence of living singly and in
#'       pairs. Taken from BIRDBASE.}
#'     \item{solitary}{Factor. Absence/presence of solitary living. Taken from
#'       BIRDBASE.}
#'     \item{social_bonds}{Ordered factor. Degree of social bonds (solitary,
#'       short-term pair/group bond, or long-term pair/group bond). Taken from
#'       Tobias et al. (2016).}
#'     \item{log_foraging_group_size}{Positive real. Log geometric mean of
#'       foraging group size. Taken from Beauchamp (2024).}
#'     \item{foraging_group_research_effort}{Integer. Number of sources with
#'       available information on flock sizes. Taken from Beauchamp (2024).}
#'     \item{vocal_production_learning}{Factor. Presence/absence of vocal
#'       production learning. Taken from Krasheninnikova et al. (2024).}
#'     \item{sexual_dichromatism}{Positive real. Amount of sexual dichromatism,
#'       proxied as the Euclidean distance in CIELAB colour space between
#'       homologous body patches in males and females, averaged across body
#'       patches for each species. 0 indicates no dichromatism, increasingly
#'       positive numbers indicate larger colour differences between males and
#'       females. Taken from Carballo et al. (2020).}
#'     \item{sexual_size_dimorphism}{Positive real. Amount of sexual dimorphism
#'       in body size, proxied as absolute differences between male and female
#'       values on a principal component capturing wing size, tarsus size, and
#'       tail size. 0 indicates no dimorphism, increasingly positive numbers
#'       indicate larger differences in body size between males and females.}
#'     \item{log_neuron_count}{Numeric. Estimated (or observed) neuron counts
#'       for species on the log scale. Neuron counts are estimated by converting
#'       brain mass measurements following a scaling equation outlined in
#'       Olkowicz et al. (2016). Brain mass data taken from Hooper et al.
#'       (2022), Hardie and Cooney (2023), or Tsuboi et al. (2018) in that
#'       order. In other words, if data are missing from Hooper, we take data
#'       from Hardie and Cooney.}
#'     \item{log_neuron_count_sd}{Positive real. Measurement error for the log
#'       neuron count estimate, represented as a standard deviation. The
#'       standard deviation encodes variation across brain size datasets,
#'       variation across specimens, and/or error due to uncertainty in the
#'       exponent from the scaling equation in Olkowicz et al. (2016). SDs are
#'       set to 1e-07 for 11 species with observed neuronal counts.}
#'   }
#'
load_data <- function(file_species_names, file_sociality_birdbase,
                      file_sociality_tobias, file_sociality_beauchamp,
                      file_vocal_production_learning, file_sexual_dichromatism,
                      file_sexual_size_dimorphism, file_brain_size_hooper,
                      file_brain_size_hardie, file_brain_size_tsuboi) {

  # get bootstrapped exponent for brain volume to neuron count conversion
  # (see Table S2 in Olkowicz et al. https://doi.org/10.1073/pnas.1517131113)
  withr::with_seed(1, {
    e <- rnorm(1000, 1.144, (1.144 - 1.020) / 1.96)
  })

  # load datasets
  species_names <- load_species_names(file_species_names)
  sociality_birdbase <- load_sociality_birdbase(file_sociality_birdbase)
  sociality_tobias <- load_sociality_tobias(file_sociality_tobias)
  sociality_beauchamp <- load_sociality_beauchamp(file_sociality_beauchamp)
  sexual_dichromatism <- load_sexual_dichromatism(file_sexual_dichromatism)
  neuron_counts_hooper <- load_brain_size_hooper(file_brain_size_hooper, e)
  neuron_counts_hardie <- load_brain_size_hardie(file_brain_size_hardie, e)
  neuron_counts_tsuboi <- load_brain_size_tsuboi(file_brain_size_tsuboi, e)
  vocal_production_learning <-
    load_vocal_production_learning(file_vocal_production_learning)
  sexual_size_dimorphism <-
    load_sexual_size_dimorphism(file_sexual_size_dimorphism)

  # join datasets
  species_names |>
    left_join(sociality_birdbase, by = "scientific_name") |>
    join_datasets(sociality_tobias,
                  variable = "social_bonds") |>
    join_datasets(sociality_beauchamp,
                  variable = "log_foraging_group_size") |>
    join_datasets(sociality_beauchamp,
                  variable = "foraging_group_research_effort") |>
    join_datasets(vocal_production_learning,
                  variable = "vocal_production_learning") |>
    join_datasets(sexual_dichromatism,
                  variable = "sexual_dichromatism") |>
    join_datasets(sexual_size_dimorphism,
                  variable = "sexual_size_dimorphism") |>
    join_datasets(neuron_counts_hooper,
                  variable = "log_neuron_count_hooper") |>
    join_datasets(neuron_counts_hooper,
                  variable = "log_neuron_count_sd_hooper") |>
    join_datasets(neuron_counts_hardie,
                  variable = "log_neuron_count_hardie") |>
    join_datasets(neuron_counts_hardie,
                  variable = "log_neuron_count_sd_hardie") |>
    join_datasets(neuron_counts_tsuboi,
                  variable = "log_neuron_count_tsuboi") |>
    join_datasets(neuron_counts_tsuboi,
                  variable = "log_neuron_count_sd_tsuboi") |>

    # remove fallback matching column
    dplyr::select(!genus_and_species) |>

    # edit genus and species names to match scientific name
    mutate(
      genus = stringr::word(scientific_name, 1),
      species = stringr::word(scientific_name, 2)
    ) |>

    # edit categorical columns to reflect (ordered) factor levels
    mutate(
      colonial                  = convert_binary(colonial),
      social                    = convert_binary(social),
      pairs_and_family_groups   = convert_binary(pairs_and_family_groups),
      singly_and_pairs          = convert_binary(singly_and_pairs),
      solitary                  = convert_binary(solitary),
      social_bonds              = convert_ordered(social_bonds),
      vocal_production_learning = convert_binary(vocal_production_learning)
    ) |>

    # for neuronal count data, prioritise Hooper et al. (2022), else use Hardie
    # and Cooney (2023), else use Tsuboi et al. (2018)
    mutate(
      log_neuron_count = case_when(
        !is.na(log_neuron_count_hooper) ~ log_neuron_count_hooper,
        !is.na(log_neuron_count_hardie) ~ log_neuron_count_hardie,
        !is.na(log_neuron_count_tsuboi) ~ log_neuron_count_tsuboi,
        TRUE ~ NA
      ),
      log_neuron_count_sd = case_when(
        !is.na(log_neuron_count_sd_hooper) ~ log_neuron_count_sd_hooper,
        !is.na(log_neuron_count_sd_hardie) ~ log_neuron_count_sd_hardie,
        !is.na(log_neuron_count_sd_tsuboi) ~ log_neuron_count_sd_tsuboi,
        TRUE ~ NA
      )
    ) |>
    dplyr::select(
      !(ends_with("_hooper") | ends_with("hardie") | ends_with("tsuboi"))
    )

}
