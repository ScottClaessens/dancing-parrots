# Title: R script to generate sociality_birdbase.csv
#
# Author: Scott Claessens
#
# Notes: To run this data wrangling script, download the full BIRDBASE data file
# from https://doi.org/10.6084/m9.figshare.27051040 and move it to the folder
# dancing-parrots/data/sociality/birdbase

options(tidyverse.quiet = TRUE)
library(readxl)    # v1.4.5
library(tidyverse) # v2.0.0

# read in full dataset
d <- readxl::read_xlsx(
  path = paste0(
    "data/sociality/birdbase/",
    "BIRDBASE v2025.1 Sekercioglu et al. Final.xlsx"
  )
)

# wrangle data
d |>
  # set first row as column names
  setNames(d[1, ]) |>
  # remove first row containing column names
  slice(-1) |>
  # keep relevant columns
  transmute(
    scientific_name = `IOC World Bird List (v15.1)`,
    order = Order,
    family = `Family IOC 15.1`,
    genus = Genus,
    species = Species,
    colonial = parse_integer(Social_1),
    social = parse_integer(Social_2),
    pairs_and_family_groups = parse_integer(Social_3),
    singly_and_pairs = parse_integer(Social_4),
    solitary = parse_integer(Social_5)
  ) |>

  # write to file
  write.csv(
    file = "data/sociality/birdbase/sociality_birdbase.csv",
    row.names = FALSE
  )

# clean up
rm(d)
