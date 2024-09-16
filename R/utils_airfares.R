

#' Retrieve all dates available for airfares data from ANAC website
#'
#' @param dom Logical. Defaults to `TRUE` download airfares of domestic
#'                 flights. If `FALSE`, the function downloads airfares of
#'                 international flights.
#'
#' @return Numeric vector.
#' @export
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_airfares_dates_available(domestic = TRUE)
#'}}
get_airfares_dates_available <- function(dom) {

  message("Function read_airfares() is temporarily  unavailable. See issue #30 https://github.com/ipeaGIT/flightsbr/issues/30")
  return(NULL)

  stop()

  if( ! is.logical(dom) ){ stop(paste0("Argument 'dom' must be either 'TRUE' or 'FALSE.")) }

  # read html table
  if( isTRUE(dom) ) { base_url = 'https://sistemas.anac.gov.br/sas/tarifadomestica/' }
  if( isFALSE(dom)) { base_url = 'https://sistemas.anac.gov.br/sas/tarifainternacional/' }

  h <- try(rvest::read_html(base_url), silent = TRUE)

  # check if internet connection worked
  if (class(h)[1]=='try-error') {                                           #nocov
    message("Problem connecting to ANAC data server. Please try it again.") #nocov
    return(invisible(NULL))                                                 #nocov
  }

  # filter elements of basica data
  elements <- rvest::html_elements(h, "a")

  if( isTRUE(dom) ) {
    basica_urls <- elements[ data.table::like(elements, '/tarifadomestica/2') ]
  }

  if( isFALSE(dom)) {
    basica_urls <- elements[ data.table::like(elements, '/tarifainternacional/2') ]
  }


  basica_urls <- lapply(X=basica_urls, FUN=function(i){rvest::html_attr(i,"href")})

  # get all dates available
  years <- gsub("[^\\d]+", "", basica_urls, perl=TRUE)

  # get url of subdirectories
  urls <- paste0(base_url, years)

  # function to search .csv data in subdirectories
  recursive_search <- function(i){ # i=urls[21]

    # read html table
    h2 <- try(rvest::read_html(i), silent = TRUE)

    if (class(h2)[1]=='try-error') {
      message("Problem connecting to ANAC data server. Please try it again.")
      return(invisible(NULL))}

    # get url of subdirectories
    elements2 <- rvest::html_elements(h2, "a")
    href2 <- rvest::html_attr(elements2, "href")
    # files_all <- grep("../", href2, fixed = TRUE, value = TRUE, invert = TRUE)
    files_csv <- href2[ data.table::like(href2, '.csv|.CSV|.txt')]
    # temp_urls <- paste0(i, files_csv)
    # return(temp_urls)
    return(files_csv)
  }

  # get urls of .csv files
  csv_urls <- lapply(X=urls, FUN=recursive_search)
  csv_urls <- unlist(csv_urls)

  # get all dates available
  options(warn=-1) # suppress warnings
  if( isTRUE(dom) ) {
    all_dates <- substr(csv_urls , (nchar(csv_urls ) + 1) -10, nchar(csv_urls )-4 ) }

  if( isFALSE(dom)) {
    csv_urls <- csv_urls[ nchar(csv_urls)==55 ]
    all_dates <- substr(csv_urls , (nchar(csv_urls ) + 1) -11, nchar(csv_urls )-4 )
    all_dates <- gsub("[-]", "", all_dates)
  }

  all_dates <- as.numeric(all_dates)
  all_dates <- all_dates[ ! is.na(all_dates)]
  options(warn=0) # unsuppress warnings

  return(all_dates)
}



#' Put together the url of airfare data files
#'
#' @param dom Logical. Defaults to `TRUE` download airfares of domestic
#'                 flights. If `FALSE`, the function downloads airfares of
#'                 international flights.
#' @param year Numeric. Year of the data in `yyyy` format.
#' @param month Numeric. Month of the data in `mm` format.
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' a <- get_airfares_url(year=2002, month=11)
#'}}
get_airfares_url <- function(dom, year, month) { # nocov start

  # https://sistemas.anac.gov.br/sas/tarifadomestica/2006/200605.csv
  # https://sistemas.anac.gov.br/sas/tarifainternacional/2015/Internacional_2015-04.txt

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  # put file url together
  if( isTRUE(dom) ) {
    url_root = 'https://sistemas.anac.gov.br/sas/tarifadomestica/'
    file_name <- paste0(year, month, '.csv')
    file_url <- paste0(url_root, year, '/', file_name)
  }

  if( isFALSE(dom)) {

    url_root = 'https://sistemas.anac.gov.br/sas/tarifainternacional/'

    if( year > 2016) { file_name <- paste0(year,'-', month, '.csv') } else {
      file_name <- paste0(year,'-', month, '.txt')}

    file_url <- paste0(url_root, year, '/Internacional_', file_name)
  }

  return(file_url)
} # nocov end




#' Download and read ANAC air fares data
#'
#' @param file_url String. A url passed from \code{\link{get_flights_url}}.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#' @param select A vector of column names or numbers to keep, passed from \code{\link{read_flights}}
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_airfares_url(dom = TRUE, year=2002, month=11)
#'
#' # download data
#' a <- download_airfares_data(file_url=file_url, showProgress=TRUE, select=NULL)
#'}}
download_airfares_data <- function(file_url = parent.frame()$file_url,
                                   showProgress = parent.frame()$showProgress,
                                   select = parent.frame()$select){ # nocov start

  # create temp local file
  file_name <- basename(file_url)
  temp_local_file <- fs::path(fs::path_temp(), file_name)


  # check if file has not been downloaded already. If not, download it
  if (!file.exists(temp_local_file) | file.info(temp_local_file)$size == 0) {

    # download data
    download_flightsbr_file(file_url=file_url, showProgress=showProgress, dest_file = temp_local_file)
  }

  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # read file stored locally
  dt <- data.table::fread(input = temp_local_file, select=select, colClasses = 'character', sep = ';') # , dec = ','

  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)
} # nocov end


