# Information on dataset `sociality.csv`

**File name:** `sociality.csv`

**Title:** Data on social behaviour for 11589 bird species from the database BIRDBASE

**Authors:** Şekercioğlu et al.

**Reference:** Şekercioğlu, Ç.H., Kittelberger, K.D., Mota, F.M.M. *et al.* BIRDBASE: A Global Dataset of Avian Biogeography, Conservation, Ecology and Life History Traits. *Sci Data* **12**, 1558 (2025). <https://doi.org/10.1038/s41597-025-05615-3>

**Source data DOI:** <https://doi.org/10.6084/m9.figshare.27051040>

**Date accessed:** 9th June 2026

**Dimensions:** 11589 rows x 6 columns

**Notes:** To generate `sociality.csv`, download the full BIRDBASE dataset and run the R script `sociality-data-wrangling.R`. The CSV file contains only the relevant columns from BIRDBASE for this study: taxonomic names and the `Social_2` variable.

**Data dictionary:**

- `scientific_name` - The scientific name (genus and species names) for the bird species. The variable is taken from the `IOC World Bird List (v15.1)` column in the BIRDBASE dataset.
- `order` - Taxonomic order name. The variable is taken from the `Order` column in the BIRDBASE dataset.
- `family` - Taxonomic family name. The variable is taken from the `Family IOC 15.1` column in the BIRDBASE dataset.
- `genus` - Taxonomic genus name. The variable is taken from the `Genus` column in the BIRDBASE dataset.
- `species` - Taxonomic species name. The variable is taken from the `Species` column in the BIRDBASE dataset.
- `social` - Binary 0/1 integer. If 1, the bird species is social (i.e., lives with large numbers of birds, mixed species flocks, seasonal flocks of the same species, etc.) If 0, the bird species is not social. If NA, data are missing. The variable is taken from the `Social_2` column in the BIRDBASE dataset.
