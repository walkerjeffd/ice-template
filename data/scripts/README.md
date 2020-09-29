Interactive Catchment Explorer Template Datasets
================================================

This folder contains an R script for generating the two example datasets (`northeast` and `northwest`).

These datasets both use the HUC12 pour points associated with regions 01 (northeast) and 17 (northwest). For each dataset, random data are generated for two numeric variables (`variable1` and `variable2`) and one categorical variable (`variable3`).

## Step 1: Download Shapefile

Download and extract the `tpp.zip` file from https://www.sciencebase.gov/catalog/item/5762b664e4b07657d19a71ea. The shapefile should be located at `data/scripts/tpp/tpp.shp`.

## Step 2: Run R Script

After obtaining the `tpp.shp` shapefile, run the `main.R` script. Note that you may need to install the library dependencies first if they are not already available:

```
install.packages(c("sf", "tidyverse", "jsonlite", "glue"))
```

The output files for each example dataset should be saved in the appropriate theme folder (`data/northeast/` and `data/northwest`).
