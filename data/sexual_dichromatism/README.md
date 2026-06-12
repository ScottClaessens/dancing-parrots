# Information on dataset `sexual_dichromatism.csv`

**File name:** `sexual_dichromatism.csv`

**Title:** Data on sexual dichromatism for 398 parrot species

**Authors:** Luisana Carballo, Kaspar Delhey, Mihai Valcu, Bart Kempenaers

**Reference:** Carballo, L., Delhey, K., Valcu, M., & Kempenaers, B. (2020). Body size and climate as predictors of plumage colouration and sexual dichromatism in parrots. *Journal of Evolutionary Biology*, *33*(11), 1543-1557. <https://doi.org/10.1111/jeb.13690>

**Source data URL:** <https://osf.io/2xr4v/files/osfstorage>

**Date accessed:** 12th June 2026

**Dimensions:** 398 rows x 2 columns

**Notes:** To generate `sexual_dichromatism.csv`, download the full colorZapper database `CZ_parrot.db` and run the R script `sexual_dichromatism_data_wrangling.R`. The CSV file contains only the relevant columns for this study: scientific names and sexual dichromatism scores.

**Data dictionary:**

- `scinam` - The scientific name (genus and species names) for the bird species.
- `sexdic` - Positive real. Amount of sexual dichromatism, proxied as the Euclidean distance in CIELAB colour space between homologous body patches in males and females, averaged across body patches for each species.
