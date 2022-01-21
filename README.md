# flightsbr: Download Flight Data from Brazil <img align="right" src="man/figures/logo.png?raw=true" alt="logo" width="180">


[![CRAN
   status](https://www.r-pkg.org/badges/version/flightsbr)](https://CRAN.R-project.org/package=flightsbr)
[![R-CMD-check](https://github.com/ipeaGIT/gtfs2gps/workflows/R-CMD-check/badge.svg)](https://github.com/ipeaGIT/gtfs2gps/actions)
[![Lifecycle:
     experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN/METACRAN Total
   downloads](http://cranlogs.r-pkg.org/badges/grand-total/flightsbr?color=yellow)](https://CRAN.R-project.org/package=flightsbr)

**flightsbr** is a computational package to download flight data from Brazil’s Civil Aviation Agency (ANAC). The data includes detailed information on every international flight to and from Brazil, as well as domestic flights within the country.


## Installation

```R
# From CRAN
  install.packages("flightsbr")

# or use the development version with latest features
  utils::remove.packages('flightsbr')
  devtools::install_github("ipeaGIT/flightsbr")
```


## Usage
The package is still under development. We currently recommend using the development version.

```R
library(flightsbr)

# read data on all flights in the month of June 2015.
df_201506 <- read_flights(date=201506, showProgress = FALSE)

# read data on all flights in the year 2015.
df_2015 <- read_flights(date=2015)

```




## Acknowledgement <a href="https://www.ipea.gov.br"><img align="right" src="man/figures/ipea_logo.png" alt="IPEA" width="300" /></a>

Original data is collected by [Brazil’s Civil Aviation Agency (ANAC)](https://www.gov.br/anac/pt-br). The **flightsbr** package is developed by a team at the Institute for Applied Economic Research (Ipea), Brazil. If you want to cite this package, you can cite it as:

* Pereira, R.H.M. (2022) **flightsbr: Download Flight Data from Brazil**. GitHub repository - https://github.com/ipeaGIT/flightsbr.

