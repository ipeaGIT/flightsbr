# flightsbr: Download Flight and Airport Data from Brazil <img align="right" src="man/figures/logo.png?raw=true" alt="logo" width="180">

[![CRAN
   status](https://www.r-pkg.org/badges/version/flightsbr)](https://CRAN.R-project.org/package=flightsbr)
[![R-CMD-check](https://github.com/ipeaGIT/flightsbr/workflows/R-CMD-check/badge.svg)](https://github.com/ipeaGIT/flightsbr/actions)
[![Lifecycle:
     experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN/METACRAN Total
   downloads](http://cranlogs.r-pkg.org/badges/grand-total/flightsbr?color=yellow)](https://CRAN.R-project.org/package=flightsbr)
[![Codecov test
coverage](https://codecov.io/gh/ipeaGIT/flightsbr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ipeaGIT/flightsbr?branch=main)
[![DOI](https://img.shields.io/badge/DOI-10.31219%2Fosf.io%2Fjdv7u-blue)](https://doi.org/10.31219/osf.io/jdv7u)

**flightsbr** is a R package to download flight and airport data from Brazil’s Civil Aviation Agency (ANAC). The data includes detailed information on all aircrafts, airports, and airport movements registered in ANAC, and on every international flight to and from Brazil, as well as domestic flights within the country.


## Installation

```R
# From CRAN
  install.packages("flightsbr")

# or use the development version with latest features
  utils::remove.packages('flightsbr')
  devtools::install_github("ipeaGIT/flightsbr")
```


## Basic usage
The package currently includes [four main functions](https://ipeagit.github.io/flightsbr/reference/index.html):

1. `read_flights()`
2. `read_airports()`
3. `read_aircrafts()`
4. `read_airport_movements()`

#### 1) `read_flights()` to download data on national and international flights.
```
# flights in a given month/year (yyyymm)
df_201506 <- read_flights(date=201506)

# flights in a given year (yyyy)
df_2015 <- read_flights(date=2015)

```

#### 2) `read_airports()` to download data on private and public airports.
```
airports_all <- flightsbr::read_airports(type = 'all')

airports_prv <- flightsbr::read_airports(type = 'private')
airports_pbl <- flightsbr::read_airports(type = 'public')

```

#### 3) `read_aircrafts()` to download aircrafts data.
```
aircrafts <- flightsbr::read_aircrafts()
```

#### 4) `read_airport_movements()` to download data on aiport movements.
```
airport_ops <- flightsbr::read_airport_movements(date = 202001)
```


#### **Related projects**

As of today, there are other repositories/projects with Brazilian aviation data and which include more info related to weather conditions, air traffic management etc. The advantage of **flights** is that it's the easiest and fastest way to download flight and airport Data from Brazil in `R`.

- [AVSTATS-Brasil](http://www.nectar.ita.br/avstats/), by the team at ITA
- [Integrated Dataset of Brazilian Flights](https://ieee-dataport.org/documents/brazilian-flights-dataset), by the team at CEFET-RJ.


## Acknowledgement <a href="https://www.ipea.gov.br"><img align="right" src="man/figures/ipea_logo.png" alt="IPEA" width="300" /></a>

Original data is collected by [Brazil’s Civil Aviation Agency (ANAC)](https://www.gov.br/anac/pt-br). The **flightsbr** package is developed by a team at the Institute for Applied Economic Research (Ipea), Brazil. If you want to cite this package, you can cite it as:

* Pereira, R.H.M. (2022) **flightsbr: Download Flight and Airport Data from Brazil**. GitHub repository - https://github.com/ipeaGIT/flightsbr.

