library(targets)
tar_source()

tar_option_set(
  packages = c("readxl", "tidyverse")
)

# pipeline
list(

  # ─────────────────────────────────────────
  # Load species data
  # ─────────────────────────────────────────

  # get data files
  tar_target(
    file_species_names,
    "data/species-names/species-names.csv",
    format = "file"
  ),
  tar_target(
    file_birdbase,
    "data/birdbase/birdbase.csv",
    format = "file"
  ),
  tar_target(
    file_vocal_production_learning,
    "data/vocal-production-learning/parrot_vocalmimic_socioecol.xlsx",
    format = "file"
  ),

  # load data
  tar_target(
    data,
    load_data(
      file_species_names,
      file_birdbase,
      file_vocal_production_learning
    )
  )

)
