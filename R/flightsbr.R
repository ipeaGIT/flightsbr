#' flightsbr: Download Flight and Airport Data from Brazil
#'
#' Download flight and airport data from Brazil’s Civil Aviation Agency (ANAC)
#'  <https://www.gov.br/anac/pt-br>. The data includes detailed information on all
#'  aircrafts, aerodromes, airports, and airport movements registered in ANAC,
#'   and on every international flight to and from Brazil, as well as domestic
#'   flights within the country.
#'
#' @section Usage:
#' Please check the vignettes and data documentation on the
#' [website](https://ipeagit.github.io/flightsbr/).
#'
#' @docType package
#' @name flightsbr
#' @aliases flightsbr-package
#'
#' @importFrom data.table := %like% .SD
#' @importFrom utils globalVariables unzip
"_PACKAGE"


## quiets concerns of R CMD check re: the .'s that appear in pipelines
utils::globalVariables( c('month', # nocov start
                          'year',
                          'latitude',
                          'longitude',
                          'temp_local_file',
                          'NR_',
                          'nr_',
                          'reference_date',
                          'altitude',
                          'success') )  # nocov end

