#' Load neuronal count data from Hooper et al. (2022)
#'
#' @param file_brain_size_hooper Path to data on brain size from Hooper et al.
#'   (2022).
#' @param exponent Numeric vector. Bootstrapped exponent for brain volume to
#'   neuron count conversion.
#'
#' @returns Tibble
#'
load_brain_size_hooper <- function(file_brain_size_hooper, exponent) {

  read_csv(
    file = file_brain_size_hooper,
    show_col_types = FALSE
  ) |>
    mutate(
      scientific_name = standardise_scientific_names(
        str_replace(Species, "_", " ")
      )
    ) |>

    # fix data input issue for one species (Cyanoliseus patagonus)
    # brain volume = 80.23 ml, should be 8.23 ml
    mutate(
      IwaniukDeanNelsonLog = ifelse(
        scientific_name == "Cyanoliseus patagonus",
        log(8.23),
        IwaniukDeanNelsonLog
      )
    ) |>

    # pivot longer
    dplyr::select(!Species) |>
    pivot_longer(
      cols = !scientific_name,
      names_to = "dataset",
      values_to = "log_brain_volume"
    ) |>

    # convert from brain volume (ml) to brain mass (g) by multiplying
    # by the density of fresh brain tissue = 1.036 g ml–1
    # (see Methods in Sol et al. https://doi.org/10.1371/journal.pone.0009617)
    mutate(
      brain_volume = exp(log_brain_volume),
      brain_mass = brain_volume * 1.036
    ) |>

    # convert to log numbers of neurons by using scaling formula for parrots:
    # brain mass = 2.669 * 10^-10 * neurons^1.144
    # (see Table S2 in Olkowicz et al. https://doi.org/10.1073/pnas.1517131113)
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
      log_neuron_count_mean = mean(
        unlist(log_neuron_count),
        na.rm = TRUE
      ),
      log_neuron_count_sd = sd(unlist(log_neuron_count), na.rm = TRUE)
    ) |>
    ungroup() |>
    rename(log_neuron_count = log_neuron_count_mean) |>

    # manually add in observed average neuron counts for 11 parrot species
    # (see Table S1 in Olkowicz et al. https://doi.org/10.1073/pnas.1517131113)
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

}
