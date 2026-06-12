# Title: R script to generate sexual_size_dimorphism.csv
#
# Author: Scott Claessens
#
# Notes: This code is adapted from the script R/DATA-LifeHistory.R which can be
# found here: https://osf.io/2xr4v/files/osfstorage To run this data wrangling
# script, download the full dataset life_history.xlsx from
# https://osf.io/2xr4v/files/osfstorage and move it to the folder
# dancing-parrots/data/sexual_size_dimorphism

library(data.table) # v1.18.4
library(readxl)     # v1.4.5

# load data
L <-
  readxl::read_excel(
    path = "data/sexual_size_dimorphism/life_history.xlsx"
  ) |>
  data.table()

# from wide to long format
#
# note: there was an issue in the original code for the female part of the
# rbind() call (see line 15 in R/DATA-LifeHistory.R), the original code
# duplicated male tarsus and tail measurements in both the male and female
# parts of the dataset - this is fixed below, so values will differ from the
# original paper
male   <- L[, .(scinam,   male_wing_mm,   male_tarsus_mm,   male_tail_mm)]
female <- L[, .(scinam, female_wing_mm, female_tarsus_mm, female_tail_mm)]

L1 <-
  rbind(
    male[, sex := "male"],
    female[, sex := "female"],
    use.names = FALSE
  ) |>
  na.omit()

# compute body size PCA
PCA <-
  prcomp(
    L1[, .(male_wing_mm, male_tarsus_mm, male_tail_mm)],
    center = TRUE,
    scale. = TRUE
  )

# add first principal component to dataset
L1[, PC1 := (PCA |> predict() |> as_tibble() |> dplyr::select(PC1))]

# from long to wide format
L1 <-
  dcast(
    L1[, .(scinam, PC1, sex)],
    scinam ~ sex,
    value.var = "PC1"
  )

setnames(
  L1,
  c("male", "female"),
  c("male_bodySize_PC1", "female_bodySize_PC1")
)

# add pca scores to original dataset
L <-
  merge(
    L,
    L1[, .(scinam, male_bodySize_PC1, female_bodySize_PC1)],
    all.x = TRUE,
    by = "scinam"
  )

# compute sexual size dimorphism (absolute difference between PCAs)
L[, scientific_name := str_to_sentence(scinam)]
L[, sexual_size_dimorphism := abs(male_bodySize_PC1 - female_bodySize_PC1)]

# write to file
write.csv(
  x = L[, .(scientific_name, sexual_size_dimorphism)],
  file = "data/sexual_size_dimorphism/sexual_size_dimorphism.csv",
  row.names = FALSE
)
