# Information on dataset `sexual_size_dimorphism.csv`

**File name:** `sexual_size_dimorphism.csv`

**Title:** Data on sexual size dimorphism for 398 parrot species

**Authors:** Luisana Carballo, Kaspar Delhey, Mihai Valcu, Bart Kempenaers

**Reference:** Carballo, L., Delhey, K., Valcu, M., & Kempenaers, B. (2020). Body size and climate as predictors of plumage colouration and sexual dichromatism in parrots. *Journal of Evolutionary Biology*, *33*(11), 1543-1557. <https://doi.org/10.1111/jeb.13690>

**Source data URL:** <https://osf.io/2xr4v/files/osfstorage>

**Date accessed:** 12th June 2026

**Dimensions:** 398 rows x 2 columns

**Notes:** To generate `sexual_size_dimorphism.csv`, download the full dataset `life_history.xlsx` and run the R script `sexual_size_dimorphism_data_wrangling.R`. The CSV file contains only the relevant columns for this study: scientific names and sexual size dimorphism scores.

**Data dictionary:**

- `scientific_name` - The scientific name (genus and species names) for the bird species.
- `sexual_size_dimorphism` - Positive real. Amount of sexual dimorphism in body size, proxied as absolute differences between male and female values on a principal component capturing wing size, tarsus size, and tail size. 0 indicates no dimorphism, increasingly positive numbers indicate larger differences in body size between males and females.
