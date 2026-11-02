#' Convert binary variable to absent/present factor
#'
#' @param x Numeric vector of 0s and 1s to convert to absent/present factor.
#'
#' @returns Factor vector
#'
convert_binary <- function(x) {

  factor(
    ifelse(x == 0, "Absent", "Present"),
    levels = c("Absent", "Present")
  )

}
