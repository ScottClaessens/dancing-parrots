#' Load data on social behaviour from BIRDBASE
#'
#' @param file_sociality_birdbase Path to data on social behaviour from
#'   BIRDBASE.
#'
#' @returns Tibble
#'
load_sociality_birdbase <- function(file_sociality_birdbase) {

  read_csv(
    file = file_sociality_birdbase,
    show_col_types = FALSE
  ) |>
    # create fallback column for matching
    mutate(genus_and_species = paste(genus, species))

}
