#' Load neuronal count data from Tsuboi et al. (2018).
#'
#' @param file_brain_size_tsuboi Path to data on brain size from Tsuboi et al.
#'   (2018).
#' @param exponent Numeric vector. Bootstrapped exponent for brain volume to
#'   neuron count conversion.
#'
#' @returns Tibble
#'
load_brain_size_tsuboi <- function(file_brain_size_tsuboi, exponent) {

  readxl::read_xlsx(
    path = file_brain_size_tsuboi
  ) |>
    rowwise() |>
    transmute(
      scientific_name = standardise_scientific_names(
        str_replace(Genus_Species, "_", " ")
      ),
      brain_mass = ifelse(
        Method == "Mass",
        `Brain mass (g)`,
        `Brain Volume (ml)` * 1.036
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

}
