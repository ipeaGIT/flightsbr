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




#' Check the date of the latest airfare data available

#' @param dom Logical. Defaults to `TRUE` download airfares of domestic
#'                 flights. If `FALSE`, the function downloads airfares of
#'                 international flights.
#' @return A numeric date in the format `yyyymm`.
#' @export
#' @family support function
#' @examples \dontrun{ if (interactive()) {
#'
#' latest_date <- latest_airfares_date()
#'
#'}}
latest_airfares_date <- function(dom=TRUE){

  # get all dates available
  all_dates <- get_airfares_dates_available(dom)

  # find latest date
  latest_date <- max(all_dates)
  return(latest_date)
}
