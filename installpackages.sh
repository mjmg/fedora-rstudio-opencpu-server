#!/bin/sh

# This installs R packages in CRAN
Rscript -e "install.packages('ggplot')"

# This installs R packages from github
Rscript -e "library(devtools); install_github('dplyr', 'hadley')"

# This installs opencpu webapps from github
Rscript -e "library(devtools); install_github('gitstats')"

# This installs R packages under Bioconductor
Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('EBImage')"
