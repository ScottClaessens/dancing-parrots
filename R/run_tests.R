#' Run tests for data
#'
#' @param data Dataset to run tests on.
#'
#' @returns List of test results if all tests pass, else an error
#'
run_tests <- function(data) {

  # run silent reporter
  reporter <- SilentReporter$new()

  # run tests
  with_reporter(reporter, {

    test_that("Dataset dimensions are as expected.", {
      expect_equal(class(data)[1], "tbl_df")
      expect_equal(nrow(data), 406)
      expect_equal(ncol(data), 19)
      expect_equal(
        colnames(data),
        c("scientific_name", "common_name", "order", "family", "genus",
          "species", "colonial", "social", "pairs_and_family_groups",
          "singly_and_pairs", "solitary", "social_bonds",
          "log_foraging_group_size", "foraging_group_research_effort",
          "vocal_production_learning", "sexual_dichromatism",
          "sexual_size_dimorphism", "log_neuron_count", "log_neuron_count_sd")
      )
    })

    test_that("Dataset column types are as expected.", {
      expect_equal(class(data$scientific_name), "character")
      expect_equal(class(data$common_name), "character")
      expect_equal(class(data$order), "character")
      expect_equal(class(data$family), "character")
      expect_equal(class(data$genus), "character")
      expect_equal(class(data$species), "character")
      expect_equal(class(data$colonial), "factor")
      expect_equal(class(data$social), "factor")
      expect_equal(class(data$pairs_and_family_groups), "factor")
      expect_equal(class(data$singly_and_pairs), "factor")
      expect_equal(class(data$solitary), "factor")
      expect_equal(class(data$social_bonds)[1], "ordered")
      expect_equal(class(data$log_foraging_group_size), "numeric")
      expect_equal(class(data$foraging_group_research_effort), "integer")
      expect_equal(class(data$vocal_production_learning), "factor")
      expect_equal(class(data$sexual_dichromatism), "numeric")
      expect_equal(class(data$sexual_size_dimorphism), "numeric")
      expect_equal(class(data$log_neuron_count), "numeric")
      expect_equal(class(data$log_neuron_count_sd), "numeric")
    })

    test_that("All species names are unique.", {
      expect_equal(length(unique(data$scientific_name)), nrow(data))
      expect_equal(length(unique(data$common_name)), nrow(data))
    })

    test_that("There is no missing data for species metadata columns.", {
      metadata_columns <- c("scientific_name", "common_name", "order",
                            "family", "genus", "species")
      expect_true(all(!is.na(data[, metadata_columns])))
    })

    test_that("Positive variables are all greater than zero.", {
      expect_all_true(complete.cases(data$log_foraging_group_size) >= 0)
      expect_all_true(complete.cases(data$sexual_dichromatism) >= 0)
      expect_all_true(complete.cases(data$sexual_size_dimorphism) >= 0)
      expect_all_true(complete.cases(data$log_neuron_count) >= 0)
      expect_all_true(complete.cases(data$log_neuron_count_sd) >= 0)
    })

  })

  # did all tests pass?
  expectations <- reporter$expectations()
  all_tests_passed <- all(
    sapply(expectations, function(x) class(x)[1]) == "expectation_success"
  )

  # stop if any test failures
  if (!all_tests_passed) {
    stop("One or more tests failed.")
  }

  # return results
  expectations

}
