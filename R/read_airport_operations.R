#' Download airport operation data from Brazil
#'
#' @description
#' Download airport operation data from Brazil’s Civil Aviation Agency (ANAC)...
#'
#' @param date Numeric. Date of the data in the format `yyyymm`. Defaults to
#'             `202001`. To download the data for all months in a year, the user
#'             can pass a 4-digit year input `yyyy`.
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#'
#' @return A `"data.table" "data.frame"` object.
#' @export
#' @family download airport operation data
#' @examples \dontrun{ if (interactive()) {
#' # Read flights data
#' a201506 <- read_airport_operations(date = 202006)
#'
#' a2015 <- read_airport_operations(date = 2020)
#'}}
read_airport_operations <- function(date = 202001, showProgress = TRUE){

### check inputs
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

### check date input
  # get all dates available
  all_dates <- get_aiport_operation_dates_available()

  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) }

 # check dates
  check_date(date=date, all_dates)


if (nchar(date)==6) {
#### Download one month---------------------------------------------------------

# prepare address of online data
  split_date(date)
  file_url <- get_airport_operations_url(year=year, month=month)

# download and read data
  dt <- download_airport_operation_data(file_url, showProgress = showProgress)

  # check if download failed
  if (is.null(dt)) { return(invisible(NULL)) }

  return(dt)


} else if (nchar(date)==4) {
#### Download whole year---------------------------------------------------------

# prepare address of online data
all_months <- generate_all_months(date)

# ignore dates after max(all_dates)
all_months <- all_months[all_months <= max(all_dates)]

# set pbapply options
original_options <- pbapply::pboptions()
if( showProgress==FALSE){ pbapply::pboptions(type='none') }
if( showProgress==TRUE){ pbapply::pboptions(type='txt' ,char='=') }

# download data
dt_list <- pbapply::pblapply( X=all_months,
                   FUN= function(i, showProgress.=FALSE) { # i = all_months[3]

                      # prepare address of online data
                      split_date(i)
                      file_url <- get_airport_operations_url(year, month)

                      # download and read data
                      temp_dt <- download_airport_operation_data(file_url, showProgress = FALSE)

                      # check if download failed
                      if (is.null(temp_dt)) { return(invisible(NULL)) }
                      return(temp_dt)
                      }
                   )

# return to original pbapply options
pbapply::pboptions(original_options)

# row bind data tables
dt <- data.table::rbindlist(dt_list)
return(dt)

}}

