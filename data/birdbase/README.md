# Information on dataset `birdbase.csv`

**File name:** `birdbase.csv`

**Title:** Data on social behaviour for 6650 bird species from the database BIRDBASE

**Authors:** Şekercioğlu et al.

**Reference:** Şekercioğlu, Ç.H., Kittelberger, K.D., Mota, F.M.M. *et al.* BIRDBASE: A Global Dataset of Avian Biogeography, Conservation, Ecology and Life History Traits. *Sci Data* **12**, 1558 (2025). <https://doi.org/10.1038/s41597-025-05615-3>

**Source data DOI:** <https://doi.org/10.6084/m9.figshare.27051040>

**Dimensions:** 6650 rows x 2 columns

**Notes:** To generate `birdbase.csv`, download the full BIRDBASE dataset and run the R script `birdbase-data-wrangling.R`. The CSV file contains only the relevant columns for this study and filters to species with observed data for the `Social_2` variable.

**Data dictionary:**

- `scientific_name` - The scientific name (genus and species names) for the parrot species.
- `social` - Binary 0/1 integer. If 1, the bird species is social (i.e., lives with large numbers of birds, mixed species flocks, seasonal flocks of the same species, etc.) If 0, the bird species is not social. The variable is taken from the `Social_2` column in the BIRDBASE dataset.
