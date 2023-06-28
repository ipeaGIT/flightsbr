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
#'             a vector of dates such as `c(202001, 20206, 202012)`.
#' @param type String. Whether the data set should be of the type `basica`
#'             (flight stage, the default) or `combinada` (On flight origin and
#'             destination - OFOD).
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#' @param select A vector of column names or numbers to keep, drop the rest. The
#'               order that the columns are specified determines the order of the
#'               columns in the result.
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
                         select = NULL){

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



#### Download one month---------------------------------------------------------
if (length(date) == 1 & nchar(date[1])==6) {

# prepare address of online data
  # split date into month and year
  y <- substring(date, 1, 4)
  m <- substring(date, 5, 6)
  file_url <- get_flights_url(type=type, year=y, month=m)

# download and read data
  dt <- download_flights_data(file_url,
                              showProgress = showProgress,
                              select = select)

  # check if download failed
  if (is.null(dt)) { return(invisible(NULL)) }

  return(dt)
}



  # set pbapply options
  original_options <- pbapply::pboptions()
  if( showProgress==FALSE){ pbapply::pboptions(type='none') }
  if( showProgress==TRUE){ pbapply::pboptions(type='txt' ,char='=') }


#### Download whole year---------------------------------------------------------
if (length(date) == 1 & nchar(date[1])==4) {

# prepare address of online data
all_months <- generate_all_months(date)

# ignore dates after max(all_dates)
all_months <- all_months[all_months <= max(all_dates)]

# download data
dt_list <- pbapply::pblapply( X=all_months,
                   FUN= function(i, type.=type, showProgress.=FALSE,
                                 select.=select) { # i = all_months[3]

                      # prepare address of online data
                      # split date into month and year
                      y <- substring(i, 1, 4)
                      m <- substring(i, 5, 6)

                      file_url <- get_flights_url(type=type, year=y, month=m)

                      # download and read data
                      temp_dt <- download_flights_data(file_url,
                                                       showProgress = FALSE,
                                                       select = select)

                      # check if download failed
                      if (is.null(temp_dt)) { return(invisible(NULL)) }
                      return(temp_dt)
                      }
                   )
}
#### Download a vector of dates-------------------------------------------------
if (length(date)>1) {

  dt_list <- lapply(X = date,
                    FUN = function(x){read_flights(date = x,
                                                   type = type,
                                                   showProgress = showProgress,
                                                   select = select)
                    }
                  )
}

# return to original pbapply options
pbapply::pboptions(original_options)

# row bind data tables
dt <- data.table::rbindlist(dt_list)
return(dt)
}

