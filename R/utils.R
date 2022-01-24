# nocov start


## quiets concerns of R CMD check re: the .'s that appear in pipelines
utils::globalVariables( c('month', 'year', '%like%') )

.onLoad <- function(lib, pkg) {
  # Use GForce Optimisations in data.table operations
  # details > https://jangorecki.gitlab.io/data.cube/library/data.table/html/datatable-optimize.html
  options(datatable.optimize = Inf) # nocov

  # set number of threads used in data.table to 100%
  # library(data.table)
  data.table::setDTthreads(percent = 100) # nocov
}

#' @importFrom(data.table, ':=', '%like%', fifelse, fread)
NULL



#' Split a date from yyyymmm to year yyyy and month mm
#'
#' @description Split a date from yyyymmm to year yyyy and month mm.
#'
#' @param date Numeric. Date of the data in `yyyymm` format.
#'
#' @return An two string objects, `year` and `month`.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Read flights data
#' a <- split_date(200011)
#'}}
split_date <- function(date) {

  y <- m <- NULL
  y <- substring(date, 1,4)
  m <- substring(date, 5,6)

  newList <- list("year" = y,
                  "month" = m)
  list2env(newList ,.GlobalEnv)
}

#' Check whether date input is acceptable
#' @param date Numeric. Either a 6-digit date in the format `yyyymm` or a 4-digit
#'             date input `yyyy` .
#'
#' @return Check messages.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- check_date(200011)
#'}}
check_date <- function(date) {

  # all dates between 2000 and 2021
  all_dates <- lapply(X=2000:2021, FUN=generate_all_months)
  all_dates <- unlist(all_dates)

  # no data after 202111
  all_dates <- all_dates[all_dates < 202111]

  if (nchar(date)==6) {
    if (!(date %in% all_dates)) {stop("Data only available for dates between Jan 2000 and Nov 2021.")}
    }

  if (nchar(date)==4) {
    if (!(date %in% 2000:2021)) {stop("Data only available for dates between Jan 2000 and Nov 2021.")}
    }
}




#' Generate all months with `yyyymm` format in a year
#'
#' @param date Numeric. 4-digit date in the format `yyyy`.
#' @return Vector or strings.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate all months in 2000
#' a <- check_date(2000)
#'}}
generate_all_months <- function(date) {

  # check
  if( nchar(date)!=4 ){ stop(paste0("Argument 'date' must be 4-digit in the format `yyyy`.")) }

  jan <- as.numeric(paste0(date, '01'))
  dec <- as.numeric(paste0(date, '12'))
  all_months <- jan:dec
  return(all_months)
}



#' Put together the data file url
#'
#' @param year Numeric. Year of the data in `yyyy` format.
#' @param month Numeric. Month of the data in `mm` format.
#' @param type String. Whether the data set should be of the type `basica`
#'             (flight stage, the default) or `combinada` (On flight origin and
#'             destination - OFOD).
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' a <- get_url(type='basica', year=2000, month=11)
#'}}
get_url <- function(type, year, month) {

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  url_root <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/'
  file_name <- paste0(type, year, '-', month, '.zip')
  file_url <- paste0(url_root, file_name)
  return(file_url)
}



#' Download and read ANAC flight data
#'
#' @param file_url String. A url passed from get_url.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#' @param select A vector of column names or numbers to keep, passed from \code{\link{read_flights}}
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_url(type='basica', year=2000, month=11)
#'
#' # download data
#' a <- download_flights_data(file_url=file_url, showProgress=TRUE, select=NULL)
#'}}
download_flights_data <- function(file_url, showProgress=showProgress, select=select){

  # create temp local file
  file_name <- substr(file_url, (nchar(file_url) + 1) -17, nchar(file_url) )
  temp_local_file <- tempfile( file_name )

  # download data
  try(
    httr::GET(url=file_url,
              if(showProgress==T){ httr::progress()},
              httr::write_disk(temp_local_file, overwrite = T),
              config = httr::config(ssl_verifypeer = FALSE)
    ), silent = F)

  # read zipped file stored locally
  temp_local_file_zip <- paste0('unzip -p ', temp_local_file)
  dt <- data.table::fread( cmd =  temp_local_file_zip, select=select)
  return(dt)
  }


#' Convert latitude and longitude columns to numeric
#'
#' @param df A data.frame internal to the `read_airport()` function.
#' @param colname String. Either `LATITUTE` or `LONGITUDE`.
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
latlon_to_numeric <- function(df, colname){

  # create column identifying whether coordinates in the South or West
  df$south_west <- data.table::fifelse( data.table::like(df[[colname]], 'S|W' ), -1, 1)

  # get vector
  vec <- df[[colname]]

  # fix string
  vec <- gsub("[.]", "", vec) # replace any decimal markers
  vec <- gsub("[\xB0]", ".", vec) # replace the degree symbol ° with a point '.'
  vec <- gsub("[^0-9.-]", "", vec) # keep only numeric

  # convert to numeric
  df[[colname]] <- as.numeric(vec) * df$south_west
  df$south_west <- NULL

  return(df)
}




# nocov end
