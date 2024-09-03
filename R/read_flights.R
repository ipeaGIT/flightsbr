#' Download flight data from Brazil
#'
#' @description
#' Download flight data from Brazil’s Civil Aviation Agency (ANAC). The data
#' includes detailed information on every international flight to and from Brazil,
#' as well as domestic flights within the country. The data include flight-level
#' information of airports of origin and destination, flight duration, aircraft
#' type, payload, and the number of passengers, and several other variables. A
#' description of all variables included in the data is available at \url{https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/descricao-de-variaveis}.
#'
#' @param date Numeric. Date of the data in the format `yyyymm`. Defaults to
#'             `202001`. To download the data for all months in a year, the user
#'             can pass a 4-digit year input `yyyy`. The parameter also accepts
#'             a vector of dates such as `c(202001, 202006, 202012)`.
#' @param type String. Whether the data set should be of the type `basica`
#'             (flight stage, the default) or `combinada` (On flight origin and
#'             destination - OFOD).
#' @template showProgress
#' @template cache
#' @template select
#'
#' @return A `"data.table" "data.frame"` object. All columns are returned with
#'         `class` of type `"character"`.
#' @export
#' @family download flight data
#' @examples \dontrun{ if (interactive()) {
#' # Read flights data
#' f201506 <- read_flights(date = 201506)
#'
#' f2015 <- read_flights(date = 2015)
#'}}
read_flights <- function(date = 202001,
                         type = 'basica',
                         showProgress = TRUE,
                         select = NULL,
                         cache = TRUE){

### check inputs
  if( ! type %in% c('basica', 'combinada') ){ stop(paste0("Argument 'type' must be either 'basica' or 'combinada'")) }
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

### check date input
  # get all dates available
  all_dates <- get_flight_dates_available()

  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) }

  # check dates
  check_date(date=date, all_dates)



#### Download and read data

  # prepare url of online files
  file_url <- get_flights_url(type=type, date=date)

  # download and read data
  dt_list <- download_flights_data(file_url,
                                   showProgress,
                                   select,
                                   cache)

  # check if download failed
  if (is.null(dt)) { return(invisible(NULL)) }

#### prep data

  # row bind data tables
  dt <- data.table::rbindlist(dt_list)

  # convert columns to numeric
  convert_to_numeric(dt)

  return(dt)
}

