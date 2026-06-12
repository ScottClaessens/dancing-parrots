# Title: R script to generate sexual_dichromatism.csv
#
# Author: Scott Claessens
#
# Notes: This code is adapted from the script R/DATA-color.R which can be found
# here: https://osf.io/2xr4v/files/osfstorage To run this data wrangling script,
# download the full database CZ_parrot.db from
# https://osf.io/2xr4v/files/osfstorage and move it to the folder
# dancing-parrots/data/sexual_dichromatism

library(colorspace) # v2.1-2
library(data.table) # v1.18.4
library(RSQLite)    # v3.53.1
library(tidyverse)  # v2.0.0

# since the colorZapper package is no longer maintained and unable to be
# installed on R 4.6.0 due to missing dependencies, must manually open the
# colorZapper file using the RSQLite package

path <- "data/sexual_dichromatism/CZ_parrot.db"
con <- RSQLite::dbConnect(RSQLite::dbDriver("SQLite"), path)
RSQLite::initExtension(con)
d <- RSQLite::dbReadTable(con, "mean_rgb") |> data.table()
RSQLite::dbDisconnect(con)
rm(con, path)

# wrangle data

d[, nsex := NULL]
d[, id := .I]
d[, mark := factor(mark, levels = c("crown","forehead", "nape",  "throat",
                                    "shoulder", "ubreast", "lbreast",
                                    "scovers", "pcovers", "secondaries",
                                    "primaries", "tail") |> rev())]
d[, col := grDevices::rgb(R, G, B, max = 255), by = id]

# convert hex codes in col column to L, a, and b values

x <- data.table(d[, as(colorspace::hex2RGB(col), "LAB")]@coords)
setnames(x, c('L', 'a', 'b'))
d <- cbind(d, x)
rm(x)

# calculate colour elaboration score: distance between each plumage patch and
# the centroid of the entire sample (joint average for L, a, and b)

d[, ces := sqrt((L - mean(L))^2 + (a - mean(a))^2 + (b - mean(b))^2)]

# calculate colour diversity score: the average euclidean distance to the
# species-specific centroid in Lab space

d[
  ,
  cds := sqrt((L - mean(L))^2 + (a - mean(a))^2 + (b - mean(b))^2),
  by = .(scinam, sex)
]

# wide format by mark

w <- merge(
  d[sex == 'f', .(scinam,col, mark, L, a, b, ces, cds)],
  d[sex == 'm', .(scinam,col, mark, L, a, b, ces, cds)],
  by = c('scinam', 'mark'),
  suffixes = c('_f', '_m')
)

# sexual dichromatism: euclidean distance in CIELAB space

w[
  ,
  sexdic := sqrt ((L_m - L_f)^2 + (a_m - a_f)^2 + (b_m - b_f)^2),
  by = .(scinam, mark)
]

# sexual dichromatism: differences in colour elaboration between m and f

w[, elabdif := ces_m - ces_f]

# averages on wide format

wa <- w[
  ,
  .(
    ces_m   = mean(ces_m),
    ces_f   = mean(ces_f),
    cds_m   = mean(cds_m),
    cds_f   = mean(cds_f),
    sexdic  = mean(sexdic),
    elabdif = mean(elabdif),
    L_f     = mean(L_f),
    a_f     = mean(a_f),
    b_f     = mean(b_f),
    L_m     = mean(L_m),
    a_m     = mean(a_m),
    b_m     = mean(b_m)
  ),
  by = .(scinam)
]

# modify scientific names

wa[, scinam := str_to_sentence(str_replace(scinam, "_", " "))]

# write sexual dichromatism data to csv file

write.csv(
  x = wa[, c("scinam", "sexdic")],
  file = "data/sexual_dichromatism/sexual_dichromatism.csv",
  row.names = FALSE
)
