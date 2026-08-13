#' Load and wrangle data for parrot species
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
#' @param file_brain_size Path to data on brain size.
#'
#' @returns A tibble
#'
load_data <- function(file_species_names, file_sociality_birdbase,
                      file_sociality_tobias, file_vocal_production_learning,
                      file_sexual_dichromatism, file_sexual_size_dimorphism,
                      file_brain_size) {

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

  # load sociality data from tobias et al. 2016
  sociality_tobias <-
    readxl::read_xlsx(
      path = file_sociality_tobias
    ) |>
    transmute(
      scientific_name = Species,
      social_bonds = `Social bond`
    ) |>
    mutate(
      sci = scientific_name,
      scientific_name = case_when(
        sci == "Amazona mercenaria"          ~ "Amazona mercenarius",
        sci == "Nandayus nenday"             ~ "Aratinga nenday",
        sci == "Lophochroa leadbeateri"      ~ "Cacatua leadbeateri",
        sci == "Aratinga aurea"              ~ "Eupsittula aurea",
        sci == "Aratinga cactorum"           ~ "Eupsittula cactorum",
        sci == "Aratinga canicularis"        ~ "Eupsittula canicularis",
        sci == "Aratinga nana"               ~ "Eupsittula nana",
        sci == "Aratinga pertinax"           ~ "Eupsittula pertinax",
        sci == "Guarouba guarouba"           ~ "Guaruba guarouba",
        sci == "Psephotus chrysopterygius"   ~ "Psephotellus chrysopterygius",
        sci == "Psephotus dissimilis"        ~ "Psephotellus dissimilis",
        sci == "Psephotus varius"            ~ "Psephotellus varius",
        sci == "Aratinga brevipes"           ~ "Psittacara brevipes",
        sci == "Aratinga erythrogenys"       ~ "Psittacara erythrogenys",
        sci == "Aratinga euops"              ~ "Psittacara euops",
        sci == "Aratinga finschi"            ~ "Psittacara finschi",
        sci == "Aratinga wagleri"            ~ "Psittacara wagleri",
        sci == "Psitteuteles iris"           ~ "Trichoglossus iris",
        sci == "Calyptorhynchus baudinii"    ~ "Zanda baudinii",
        sci == "Calyptorhynchus latirostris" ~ "Zanda latirostris",
        TRUE ~ sci
      )
    )

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

  # get bootstrapped exponent for brain volume to neuron count conversion
  # (see Table S2 in https://doi.org/10.1371/journal.pone.0009617)
  withr::with_seed(1, {
    exponent <- rnorm(1000, 1.144, (1.144 - 1.020) / 1.96)
  })

  # load brain size data and calculate neuronal counts
  neuron_counts <-
    read_csv(
      file = file_brain_size,
      show_col_types = FALSE
    ) |>
    mutate(scientific_name = str_replace(Species, "_", " ")) |>
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
    join_datasets(
      sociality_tobias,
      variable = "social_bonds"
    ) |>
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
    join_datasets(
      neuron_counts,
      variable = "log_neuron_count"
    ) |>
    join_datasets(
      neuron_counts,
      variable = "log_neuron_count_sd"
    ) |>

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
    )

}
