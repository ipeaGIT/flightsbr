#' flightsbr: Download Flight And Airport Data from Brazil
#'
#' Download flight and airport data from Brazil’s Civil Aviation Agency (ANAC)
#'  <https://www.gov.br/anac>. The data includes detailed information on all
#'  aircrafts, aerodromes, airports, and airports movements registered in ANAC,
#'   and on every international flight to and from Brazil, as well as domestic
#'   flights within the country.
#'
#' @section Usage:
#' Please check the vignettes on the [website](https://ipeagit.github.io/flightsbr/).
#'
#' @docType package
#' @name flightsbr
#' @aliases flightsbr-package
#' @useDynLib flightsbr, .registration = TRUE
#'
#' @importFrom data.table := .I .SD %chin% fread %like%
#' @importFrom utils globalVariables
"_PACKAGE"


## quiets concerns of R CMD check re: the .'s that appear in pipelines
utils::globalVariables( c('month',
                          'year',
                          ':=') )

.onLoad <- function(lib, pkg) {
  # Use GForce Optimisations in data.table movements
  # details > https://jangorecki.gitlab.io/data.cube/library/data.table/html/datatable-optimize.html
  options(datatable.optimize = Inf) # nocov

  # set number of threads used in data.table to 100%
  # library(data.table)
  data.table::setDTthreads(percent = 100) # nocov
}

