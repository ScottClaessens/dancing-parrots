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
    "data/species_names/species_names.csv",
    format = "file"
  ),
  tar_target(
    file_sociality,
    "data/sociality/sociality.csv",
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

  # load data
  tar_target(
    data,
    load_data(
      file_species_names,
      file_sociality,
      file_vocal_production_learning,
      file_sexual_dichromatism
    )
  )

)
