#' Download aircraft data from Brazil
#'
#' @description
#'
#' Download data of all aircraft registered in the Brazilian Aeronautical
#' Registry (Registro Aeronáutico Brasileiro - RAB), organized by the Brazilian
#' Civil Aviation Agency (ANAC). A description of all variables included in the
#' data is available at \url{https://www.gov.br/anac/pt-br/sistemas/rab}.
#'
#' @template date
#' @template showProgress
#' @template cache
#'
#' @return A `"data.table" "data.frame"` object. All columns are returned with
#'         `class` of type `"character"`.
#' @export
#' @family download flight data
#' @examples \dontrun{ if (interactive()) {
#' # Read aircraft data
#' aircraft <- read_aircraft(date = 202001,
#'                             showProgress = TRUE)
#'
#'
#'}}
read_aircraft <- function(date = 202001,
                           showProgress = TRUE,
                           cache = TRUE
                           ){

### check inputs
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }
  if( ! is.logical(cache) ){ stop(paste0("Argument 'cache' must be either 'TRUE' or 'FALSE.")) }
  check_input_date_format(date)

  ### check date input
  # get all dates available
  all_dates <- get_aircraft_dates_available()

  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) }

  # check dates
  check_date(date=date, all_dates)

  # get url of files
  file_urls <- get_aircraft_url(date)

  # download and read data
  dt <- download_aircraft_data(file_url = file_urls,
                                showProgress = showProgress,
                                cache = cache)

  # check if download failed
  if (is.null(dt)) { return(invisible(NULL)) }

  # clean names
  nnn <- names(dt)
  data.table::setnames(
    x = dt,
    old = nnn,
    new = janitor::make_clean_names(nnn)
    )

  # convert columns to numeric
  convert_to_numeric(dt)

  return(dt)
}
