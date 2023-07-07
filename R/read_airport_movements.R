#' Download airport movement data from Brazil
#'
#' @description
#' Download airport movements data from Brazil’s Civil Aviation Agency (ANAC).
#' The data covers all passenger, aircraft, cargo and mail movement data from
#' airports regulated by ANAC. Data only available from Jan 2019 onwards. A
#' description of all variables included in the data is available at
#' \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/operador-aeroportuario/dados-de-movimentacao-aeroportuaria/60-dados-de-movimentacao-aeroportuaria}.
#'
#'
#' @param date Numeric. Date of the data in the format `yyyymm`. Defaults to
#'             `202001`. To download the data for all months in a year, the user
#'             can pass a 4-digit year input `yyyy`.
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#'
#' @return A `"data.table" "data.frame"` object. All columns are returned with
#'         `class` of type `"character"`.
#' @export
#' @family download airport movement data
#' @examples \dontrun{ if (interactive()) {
#' # Read airport movement data
#' amov202006 <- read_airport_movements(date = 202006)
#'
#' amov2020 <- read_airport_movements(date = 2020)
#'}}
read_airport_movements <- function(date = 202001, showProgress = TRUE){

  ### check inputs
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

  ### check date input
  # get all dates available
  all_dates <- get_airport_movement_dates_available()

  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) } # nocov

  # check dates
  check_date(date=date, all_dates)


  if (nchar(date)==6) {
    #### Download one month---------------------------------------------------------

    # prepare address of online data
    # split date date into month and year
    y <- substring(date, 1, 4)
    m <- substring(date, 5, 6)

    file_url <- get_airport_movements_url(year=y, month=m)

    # download and read data
    dt <- download_airport_movement_data(file_url, showProgress = showProgress)

    # check if download failed
    if (is.null(dt)) { return(invisible(NULL)) } # nocov

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

                                    file_url <- get_airport_movements_url(year=y, month=m)

                                    # download and read data
                                    temp_dt <- download_airport_movement_data(file_url, showProgress = FALSE)

                                    # check if download failed
                                    if (is.null(temp_dt)) { return(invisible(NULL)) }
                                    return(temp_dt)
                                  }
    )

    # return to original pbapply options
    pbapply::pboptions(original_options)

    # row bind data tables
    dt <- data.table::rbindlist(dt_list)

    # convert columns to numeric
    convert_to_numeric(dt)

    return(dt)
  }
}
