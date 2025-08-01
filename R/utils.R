#' Check whether date input is acceptable
#' @param date Numeric. Either a 6-digit date in the format `yyyymm` or a 4-digit
#'             date input `yyyy` .
#' @param all_dates Numeric vector created with the get_all_dates_available() function.
#'
#' @return Check messages.
#' @export
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#'
#' # get all dates available
#' all_dates <- get_all_dates_available()
#'
#' # check dates
#' a <- check_date(200011, all_dates)
#'}}
check_date <- function(date, all_dates) {

  error_message <-  paste0("The data is currently only available for dates between ", min(all_dates), " and ", max(all_dates), ".")

  for(d in date){
    if (nchar(d)==6) {
      if (!(d %in% all_dates)) {stop(error_message)}
      }

    if (nchar(d)!=6) {
      if (!(d %in% unique(substr(all_dates, 1, 4)) )) {stop(error_message)}
    }
  }
}



#' Generate all months with `yyyymm` format for a given year
#'
#' @param date Numeric. 4-digit date in the format `yyyy`. The function also
#'        takes multiple years.
#' @return Vector or strings.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate all months in 2000
#' a <- check_date(2000)
#'
#' b <- check_date(c(2000, 2005))
#'}}
generate_all_months <- function(date) {

  # check
  if (any(nchar(date)!=4)) { stop(paste0("Argument 'date' must be 4-digit in the format `yyyy`.")) }

  get_all_months <- function(yyyy){
    jan <- as.numeric(paste0(yyyy, '01'))
    dec <- as.numeric(paste0(yyyy, '12'))
    allmonths <- jan:dec
    return(allmonths)
  }

  all_dates <- lapply(X=date, FUN = get_all_months)
  all_dates <- unlist(all_dates)
  return(all_dates)

}




#' Download file from url
#'
#' @param file_url String. A url passed from \code{\link{get_flights_url}}.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#' @param dest_file String, passed from \code{\link{read_flights}}
#' @param cache Logical, passed from \code{\link{read_flights}}
#'
#' @return Silently saves downloaded file to temp dir.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_flights_url(type='basica', date=200011)
#'
#' # download data
#' download_flightsbr_file(file_url=file_url,
#'                         showProgress=TRUE,
#'                         dest_file = tempfile(fileext = ".zip")
#'                        )
#'}}
download_flightsbr_file <- function(file_url = parent.frame()$file_url,
                                    showProgress = parent.frame()$showProgress,
                                    dest_file = temp_local_file,
                                    cache = cache){ # nocov start

  # address to temp file
  dest_file <- fs::path(fs::path_temp(), basename(file_url))

  # download data
  downloaded_files <- curl::multi_download(
    urls = file_url,
    destfiles = dest_file,
    resume = cache,
    progress = showProgress
    )

  # return TRUE if everything worked
  check_download <- all(downloaded_files$success)
  if (isTRUE(check_download)) {
    return(check_download)
    }

  # check if file has NOT been downloaded, try a 2nd time
  if (any(!downloaded_files$success | is.na(downloaded_files$success))) {

    # update table to download only the files that failed in the 1st attempt
    downloaded_files <- subset(
      downloaded_files,
      success == FALSE | is.na(success)
      )

    # download data: try a 2nd time
    downloaded_files <- curl::multi_download(
      urls = downloaded_files$url,
      destfiles = downloaded_files$destfile,
      resume = TRUE,
      progress = showProgress
      )

    check_download <- all(downloaded_files$success)
    if (isTRUE(check_download)) {
      return(check_download)
    }

  # Halt function if download failed
    if (any(!downloaded_files$success | is.na(downloaded_files$success))) {
      message('Internet connection not working. Try again later.')
      return(invisible(NULL))
      }
  }

}  # nocov end





#' Convert latitude and longitude columns to numeric
#'
#' @param df A data.frame internal to the `read_airport()` function.
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
latlon_to_numeric <- function(df){ # nocov start

  # check if df has lat lon colnames
  if(!'latitude' %in% names(df)){ stop("Column 'latitude' is missing from original ANAC data.") }
  if(!'longitude' %in% names(df)){ stop("Column 'longitude' is missing from original ANAC data.") }

  # ref
  # https://semba-blog.netlify.app/02/25/2020/geographical-coordinates-conversion-made-easy-with-parzer-package-in-r/

  # supress warning
  defaultW <- getOption("warn")
  options(warn = -1)

  # # fix string
  # df[, latitude := gsub("[\u00c2]", "", latitude) ]
  # df[, longitude := gsub("[\u00c2]", "", longitude) ]

  # convert to numeric
  df[, latitude := parzer::parse_lat(latitude) ]
  df[, longitude := parzer::parse_lon(longitude) ]

  # restore warnings
  options(warn = defaultW)

  return(df)
} # nocov end


#' Convert altitude column to numeric
#'
#' @param df A data.frame internal to the `read_airport()` function.
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
altitude_to_numeric <- function(df){ # nocov start

  # check if df has lat lon colnames
  if(!'altitude' %in% names(df)){ stop("Column 'altitude' is missing from original ANAC data.") }

  # supress warning
  defaultW <- getOption("warn")
  options(warn = -1)

  # fix string
  df[, altitude := gsub(" m", "", altitude) ]
  df[, altitude := gsub(",", ".", altitude) ]

  # convert to numeric
  df[, altitude := as.numeric(altitude) ]

  # restore warnings
  options(warn = defaultW)

  return(df)
} # nocov end




#' @keywords internal
convert_to_numeric <- function(dt, type='standard') { # nocov start

  # detect if there are any columns that should be numeric
  numeric_cols <- names(dt)[names(dt) %like% 'NR_|nr_|qt_|comprimento_|largura_']
  numeric_cols <- numeric_cols[numeric_cols != 'nr_singular']

  if (type =='airfare') {
    airfare_num_cols <- c('ano', 'mes', 'tarifa_n', 'tarifa', 'assentos')
    airfare_num_cols <- airfare_num_cols[airfare_num_cols %in% names(dt)]
    numeric_cols <- c(numeric_cols, airfare_num_cols)
    }


  if (length(numeric_cols)==0) { return(invisible(TRUE)) }

  # replace , with . for numbers
  dt[,(numeric_cols):= lapply(.SD, FUN = function(x){gsub(',','.',x)}), .SDcols = numeric_cols]
  # to numeric
  suppressWarnings(
    dt[,(numeric_cols):= lapply(.SD, as.numeric), .SDcols = numeric_cols]
    )

  return(invisible(TRUE))
} # nocov end









#' Check whether the format of the date input is acceptable
#' @param date Vector. Either a 6-digit date in the format `yyyymm` or a 4-digit
#'             date input `yyyy` .
#'
#' @return Check messages.
#' @export
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#'
#' # get all dates available
#' all_dates <- get_all_dates_available()
#'
#' # check dates
#' a <- check_date(200011, all_dates)
#'}}
check_input_date_format <- function(date = parent.frame()$date) {

  # are all dates yyyy
  yyyy <- (all(nchar(date)==4))

  # are all dates yyyymm
  yyyymm <- (all(nchar(date)==6))

  if(yyyy + yyyymm == 0){
  stop("The 'date' input must be consistent in either a 6-digit format `yyyymm` OR a 4-digit format `yyyy`.")
  }
}


