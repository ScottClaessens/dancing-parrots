#' Join two datasets
#'
#' The function first tries to link by scientific name. If there's no match, it
#' tries linking by genus and species names.
#'
#' @param left_df Primary dataset.
#' @param right_df Dataset to left join.
#' @param variable String. Which variable in the datasets to join.
#'
#' @returns Tibble
#'
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
