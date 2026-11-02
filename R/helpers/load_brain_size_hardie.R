#' Load neuronal count data from Hardie & Cooney (2023)
#'
#' @param file_brain_size_hardie Path to data on brain size from Hardie and
#'   Cooney (2023).
#' @param exponent Numeric vector. Bootstrapped exponent for brain volume to
#'   neuron count conversion.
#'
#' @returns Tibble
#'
load_brain_size_hardie <- function(file_brain_size_hardie, exponent) {

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

}
