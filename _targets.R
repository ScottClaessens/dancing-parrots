library(targets)
tar_source()

tar_option_set(
  packages = c("readxl", "tidyverse", "withr")
)

# pipeline
list(

  # ─────────────────────────────────────────
  # Load species data
  # ─────────────────────────────────────────

  # get data files
  tar_target(
    file_species_names,
    "data/species_names/species_names.csv",
    format = "file"
  ),
  tar_target(
    file_sociality_birdbase,
    "data/sociality/birdbase/sociality_birdbase.csv",
    format = "file"
  ),
  tar_target(
    file_sociality_tobias,
    "data/sociality/tobias_et_al_2016/Data Sheet 3.xlsx",
    format = "file"
  ),
  tar_target(
    file_vocal_production_learning,
    "data/vocal_production_learning/parrot_vocalmimic_socioecol.xlsx",
    format = "file"
  ),
  tar_target(
    file_sexual_dichromatism,
    "data/sexual_dichromatism/sexual_dichromatism.csv",
    format = "file"
  ),
  tar_target(
    file_sexual_size_dimorphism,
    "data/sexual_size_dimorphism/sexual_size_dimorphism.csv",
    format = "file"
  ),
  tar_target(
    file_brain_size,
    "data/brain_size/brain_size.csv",
    format = "file"
  ),

  # load data
  tar_target(
    data,
    load_data(
      file_species_names,
      file_sociality_birdbase,
      file_sociality_tobias,
      file_vocal_production_learning,
      file_sexual_dichromatism,
      file_sexual_size_dimorphism,
      file_brain_size
    )
  )

)
