#!/bin/sh

# This installs R packages in CRAN
echo "Installing ggplot2 from CRAN"
Rscript -e "install.packages('ggplot2')"

# This installs R packages from github
echo "Installing dplyr and hadley from github"
Rscript -e "library(devtools); install_github('dplyr', 'hadley')"

# This installs opencpu webapps from github
echo "Installing appdemo and gitstats opencpu webapp"
Rscript -e "library(devtools); install_github('appdemo')"
Rscript -e "library(devtools); install_github('gitstats')"

# This installs R packages under Bioconductor
echo "Installing EBImage from Bioconductor"
Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('EBImage')"
