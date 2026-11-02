#' Convert the social bonds variable to an ordered factor
#'
#' @param x Numeric vector. The social bonds variable.
#'
#' @returns Ordered factor vector
#'
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
