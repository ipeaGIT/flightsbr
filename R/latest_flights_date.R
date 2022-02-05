#' Check the date of the latest flight data available
#'
#' @return A numeric date in the format `yyyymm`.
#' @export
#' @family support function
#' @examples \dontrun{ if (interactive()) {
#'
#' latest_date <- latest_flights_date()
#'
#'}}
latest_flights_date <- function(){

  # get all dates available
  all_dates <- get_flight_dates_available()

  # find latest date
  latest_date <- max(all_dates)
  return(latest_date)
}

