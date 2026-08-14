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
#' @returns A tibble with 406 rows and 17 columns:
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
#'       brain mass measurements following a scaling equation outlined in Sol et
#'       al. (2010). Taken from Hooper et al. (2022), Hardie and Cooney (2023),
#'       or Tsuboi et al. (2018).}
#'     \item{log_neuron_count_sd}{Positive real. Measurement error for the log
#'       neuron count estimate, represented as a standard deviation. The
#'       standard deviation encodes variation across brain size datasets,
#'       variation across specimens, and/or error due to uncertainty in the
#'       exponent from the scaling equation in Sol et al. (2010). SDs are set
#'       to 1e-07 for 11 species with observed neuronal counts.}
#'   }
#'
load_data <- function(file_species_names, file_sociality_birdbase,
                      file_sociality_tobias, file_vocal_production_learning,
                      file_sexual_dichromatism, file_sexual_size_dimorphism,
                      file_brain_size_hooper, file_brain_size_hardie,
                      file_brain_size_tsuboi) {

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

  # load sociality data from birdbase
  sociality_birdbase <-
    read_csv(
      file = file_sociality_birdbase,
      show_col_types = FALSE
    ) |>
    # create fallback column for matching
    mutate(genus_and_species = paste(genus, species))

  # load sociality data from Tobias et al. 2016
  sociality_tobias <-
    readxl::read_xlsx(
      path = file_sociality_tobias
    ) |>
    transmute(
      scientific_name = standardise_scientific_names(Species),
      social_bonds = `Social bond`
    )

  # load data on vocal production learning
  vocal_production_learning <-
    readxl::read_xlsx(
      path = file_vocal_production_learning
    ) |>
    transmute(
      scientific_name = standardise_scientific_names(
        str_replace(scinam, "_", " ")
      ),
      vocal_production_learning = vocal
    )

  # load sexual dichromatism data
  sexual_dichromatism <-
    read_csv(
      file = file_sexual_dichromatism,
      show_col_types = FALSE
    ) |>
    transmute(
      scientific_name = standardise_scientific_names(scinam),
      sexual_dichromatism = sexdic
    )

  # load sexual size dimorphism data
  sexual_size_dimorphism <-
    read_csv(
      file = file_sexual_size_dimorphism,
      show_col_types = FALSE
    ) |>
    mutate(scientific_name = standardise_scientific_names(scientific_name))

  # get bootstrapped exponent for brain volume to neuron count conversion
  # (see Table S2 in https://doi.org/10.1371/journal.pone.0009617)
  withr::with_seed(1, {
    exponent <- rnorm(1000, 1.144, (1.144 - 1.020) / 1.96)
  })

  # load brain size data from Hooper et al. (2022) and calculate neuronal counts
  neuron_counts_hooper <-
    read_csv(
      file = file_brain_size_hooper,
      show_col_types = FALSE
    ) |>
    mutate(
      scientific_name = standardise_scientific_names(
        str_replace(Species, "_", " ")
      )
    ) |>
    dplyr::select(!Species) |>
    pivot_longer(
      cols = !scientific_name,
      names_to = "dataset",
      values_to = "log_brain_volume"
    ) |>

    # convert from brain volume (ml) to brain mass (g) by multiplying
    # by the density of fresh brain tissue = 1.036 g ml–1
    # (see https://doi.org/10.1371/journal.pone.0009617)
    mutate(
      brain_volume = exp(log_brain_volume),
      brain_mass = brain_volume * 1.036
    ) |>

    # convert to log numbers of neurons by using scaling formula for parrots:
    # brain mass = 2.669 * 10^-10 * neurons^1.144
    # (see Table S2 in https://doi.org/10.1371/journal.pone.0009617)
    # we use bayesian-like bootstrapping to account for uncertainty in exponent
    rowwise() |>
    mutate(
      log_neuron_count = list(
        log((brain_mass / (2.669 * 10^-10))^(1 / exponent))
      )
    ) |>

    # calculate mean and SD by combining all brain size datasets, thereby
    # incorporating error in (1) the exponent value, and (2) the different
    # initial brain volume measurements
    group_by(scientific_name) |>
    summarise(
      log_neuron_count_mean = mean(unlist(log_neuron_count), na.rm = TRUE),
      log_neuron_count_sd = sd(unlist(log_neuron_count), na.rm = TRUE)
    ) |>
    ungroup() |>
    rename(log_neuron_count = log_neuron_count_mean) |>

    # manually add in observed average neuron counts for 11 parrot species
    # (see Table S1 in https://doi.org/10.1371/journal.pone.0009617)
    mutate(
      log_neuron_count = case_when(
        scientific_name == "Forpus passerinus"       ~ log(227.20  * 10^6),
        scientific_name == "Melopsittacus undulatus" ~ log(321.82  * 10^6),
        scientific_name == "Nymphicus hollandicus"   ~ log(452.77  * 10^6),
        scientific_name == "Platycercus eximius"     ~ log(641.88  * 10^6),
        scientific_name == "Myiopsitta monachus"     ~ log(696.77  * 10^6),
        scientific_name == "Psittacula eupatria"     ~ log(1096.26 * 10^6),
        scientific_name == "Psittacus erithacus"     ~ log(1565.93 * 10^6),
        scientific_name == "Cacatua galerita"        ~ log(2121.93 * 10^6),
        scientific_name == "Nestor notabilis"        ~ log(2148.67 * 10^6),
        scientific_name == "Ara ararauna"            ~ log(3135.79 * 10^6),
        TRUE ~ log_neuron_count
      ),
      log_neuron_count_sd = ifelse(
        scientific_name %in% c(
          "Forpus passerinus", "Melopsittacus undulatus",
          "Nymphicus hollandicus", "Platycercus eximius", "Myiopsitta monachus",
          "Psittacula eupatria", "Psittacus erithacus", "Cacatua galerita",
          "Nestor notabilis", "Ara ararauna"
        ),
        1e-07,
        log_neuron_count_sd
      )
    ) |>
    # add Cacatua goffiniana as it was not included in brain size dataset
    bind_rows(
      tibble(
        scientific_name = "Cacatua goffiniana",
        log_neuron_count = log(1160.59 * 10^6),
        log_neuron_count_sd = 1e-07
      )
    ) |>
    # rename columns for matching later
    rename_with(\(x) ifelse(x != "scientific_name", paste0(x, "_hooper"), x))

  # load brain size data from Hardie and Cooney (2023)
  # and calculate neuronal counts following the same process as above
  neuron_counts_hardie <-
    read_csv(
      file = file_brain_size_hardie,
      show_col_types = FALSE
    ) |>
    rowwise() |>
    transmute(
      scientific_name = standardise_scientific_names(
        str_replace(TipLabel, "_", " ")
      ),
      brain_mass = Brain_Size_mL * 1.036,
      log_neuron = list(
        log((brain_mass / (2.669 * 10^-10))^(1 / exponent))
      ),
      log_neuron_count = mean(unlist(log_neuron), na.rm = TRUE),
      log_neuron_count_sd = sd(unlist(log_neuron), na.rm = TRUE)
    ) |>
    dplyr::select(!log_neuron) |>
    rename_with(\(x) ifelse(x != "scientific_name", paste0(x, "_hardie"), x))

  # load brain size data from Tsuboi et al. (2018)
  # and calculate neuronal counts following the same process as above
  neuron_counts_tsuboi <-
    readxl::read_xlsx(
      path = file_brain_size_tsuboi
    ) |>
    rowwise() |>
    transmute(
      scientific_name = standardise_scientific_names(
        str_replace(Genus_Species, "_", " ")
      ),
      brain_mass = ifelse(
        Method == "Mass", `Brain mass (g)`, `Brain Volume (ml)` * 1.036
      ),
      log_neuron = list(
        log((brain_mass / (2.669 * 10^-10))^(1 / exponent))
      )
    ) |>
    group_by(scientific_name) |>
    summarise(
      log_neuron_count = mean(unlist(log_neuron), na.rm = TRUE),
      log_neuron_count_sd = sd(unlist(log_neuron), na.rm = TRUE)
    ) |>
    ungroup() |>
    rename_with(\(x) ifelse(x != "scientific_name", paste0(x, "_tsuboi"), x))

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

  # create function to convert binary variable to absent/present factor
  convert_binary <- function(x) {
    factor(
      ifelse(x == 0, "Absent", "Present"),
      levels = c("Absent", "Present")
    )
  }

  # create function to convert social_bonds variable to ordered factor
  convert_ordered <- function(x) {
    ordered(
      case_when(
        x == 1 ~ "Solitary",
        x == 2 ~ "Short-term pair/group bond",
        x == 3 ~ "Long-term pair/group bond",
        is.na(x) ~ NA
      ),
      levels = c("Solitary", "Short-term pair/group bond",
                 "Long-term pair/group bond")
    )
  }

  # join datasets
  species_names |>
    left_join(sociality_birdbase, by = "scientific_name") |>
    join_datasets(sociality_tobias,
                  variable = "social_bonds") |>
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
