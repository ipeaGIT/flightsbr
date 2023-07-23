#' Download aircrafts data from Brazil
#'
#' @description
#'
#' Download data of all aircrafts registered in the Brazilian Aeronautical
#' Registry (Registro Aeronáutico Brasileiro - RAB), organized by the Brazilian
#' Civil Aviation Agency (ANAC). A description of all variables included in the
#' data is available at \url{https://www.gov.br/anac/pt-br/sistemas/rab}.
#'
#' @template date
#' @template showProgress
#'
#' @return A `"data.table" "data.frame"` object. All columns are returned with
#'         `class` of type `"character"`.
#' @export
#' @family download flight data
#' @examples \dontrun{ if (interactive()) {
#' # Read aircrafts data
#' aircrafts <- read_aircrafts(showProgress = TRUE)
#'
#'}}
read_aircrafts <- function(date = 202001, showProgress = TRUE ){

### check inputs
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

  ### check date input
  # get all dates available
  all_dates <- get_aircrafts_dates_available()

  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) }

  # check dates
  check_date(date=date, all_dates)


  if (nchar(date)==6) {
  #### Download one month---------------------------------------------------------

    # prepare address of online data
    # split date into month and year
    y <- substring(date, 1, 4)
    m <- substring(date, 5, 6)
    file_url <- get_aircrafts_url(year=y, month=m)

    # download and read data
    dt <- download_aircrafts_data(file_url, showProgress = showProgress)

    # check if download failed
    if (is.null(dt)) { return(invisible(NULL)) }

    # add date of reference
    dt[, reference_date := paste0(y,m)]

    # convert columns to numeric
    convert_to_numeric(dt)

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
                                      # split date into month and year
                                      y <- substring(i, 1, 4)
                                      m <- substring(i, 5, 6)

                                      file_url <- get_aircrafts_url(year=y, month=m)

                                      # download and read data
                                      temp_dt <- download_aircrafts_data(file_url, showProgress = FALSE)

                                      # add date of reference
                                      temp_dt[, reference_date := paste0(y,m)]

                                      # check if download failed
                                      if (is.null(temp_dt)) { return(invisible(NULL)) }
                                      return(temp_dt)
                                    }
      )

      # return to original pbapply options
      pbapply::pboptions(original_options)


      # convert columns to numeric
      convert_to_numeric(dt)

      return(dt)

    }
  }
