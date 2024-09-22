

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

  # message("Function read_airfares() is temporarily  unavailable. See issue #30 https://github.com/ipeaGIT/flightsbr/issues/30")
  # return(NULL)
  #
  # stop()

  if( ! is.logical(dom) ){ stop(paste0("Argument 'dom' must be either 'TRUE' or 'FALSE.")) }

  # read html table
  if( isTRUE(dom) ) { base_url = 'https://sas.anac.gov.br/sas/tarifadomestica/' }
  if( isFALSE(dom)) { base_url = 'https://sas.anac.gov.br/sas/tarifainternacional/' }

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
#' @param date Numeric. Date of the data in the format `yyyymm`. To download the
#'             data for all months in a year, the user can pass a 4-digit year
#'             input `yyyy`. The parameter also accepts a vector of dates such as
#'             `c(202001, 202006, 202012)`.
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' a <- get_airfares_url(year=2002, month=11)
#'}}
get_airfares_url <- function(dom,
                             date = parent.frame()$date) { # nocov start

  # Domestic flights
  if( isTRUE(dom) ) {
    url_root = 'https://sas.anac.gov.br/sas/tarifadomestica/'

    # date with format yyyymm
    if (all(nchar(date)==6)) {
      years <- substring(date,1,4)
      months <- substring(date,5,6)
      file_urls <- paste0(url_root, years, '/', date, '.csv')
    }

    # date with format yyyy
    if (all(nchar(date)==4)) {
      all_dates <- generate_all_months(date)
      years <- substring(all_dates,1,4)
      months <- substring(all_dates,5,6)
      file_urls <- paste0(url_root, years, '/', all_dates, '.csv')
    }
  }


  # International flights
  if( isFALSE(dom)) {

    url_root = 'https://sas.anac.gov.br/sas/tarifainternacional/'

    # date with format yyyymm
    if (all(nchar(date)==6)) {
      years <- substring(date,1,4)
      months <- substring(date,5,6)
      file_urls <- paste0(url_root, years, '/Internacional_', years, '-', months, '.csv')
    }

    # date with format yyyy
    if (all(nchar(date)==4)) {
      all_dates <- generate_all_months(date)
      years <- substring(all_dates,1,4)
      months <- substring(all_dates,5,6)
      file_urls <- paste0(url_root, years, '/Internacional_', years, '-', months, '.csv')
    }

    # replace .csv with .txt for dates earlier than 2016
    fix_file_extension <- function(url){
      yyyy <- gsub(".*(199[0-9]|20[01][0-9]).*","\\1",url)[1] # detect year of reference
      if(yyyy < 2017) { url <- gsub('.csv', '.txt', url) }
      return(url)
    }

    file_urls <- lapply(X=file_urls, FUN=fix_file_extension) |> unlist()
    }

  return(file_urls)
} # nocov end




#' Download and read ANAC air fares data
#'
#' @param file_urls String. A url passed from \code{\link{get_flights_url}}.
#' @template showProgress
#' @template select
#' @template cache
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_airfares_url(dom = TRUE, date=200211)
#'
#' # download data
#' a <- download_airfares_data(file_urls=file_url, showProgress=TRUE, select=NULL)
#'}}
download_airfares_data <- function(file_urls = parent.frame()$file_urls,
                                   showProgress = parent.frame()$showProgress,
                                   select = parent.frame()$select,
                                   cache = parent.frame()$cache
                                   ){ # nocov start

  # create temp local file
  file_name <- basename(file_urls)
  temp_local_file <- fs::path(fs::path_temp(), file_name)


  # use cached files or not
  if (any(cache==FALSE & file.exists(temp_local_file))) {
    unlink(temp_local_file, recursive = T)
  }

  # has the file been downloaded already? If not, download it
  if (any(cache==FALSE |
          !file.exists(temp_local_file) |
          file.info(temp_local_file)$size == 0)) {

    # download data
    check_download <- download_flightsbr_file(file_url=file_urls,
                                              showProgress=showProgress,
                                              dest_file = temp_local_file,
                                              cache = cache)
    # check if internet connection worked
    if (is.null(check_download)) { # nocov start
      message("Problem connecting to ANAC data server. Please try it again.") #nocov
      return(invisible(NULL))                                                 #nocov
    }
  }


  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # read files stored locally
  dt <- pbapply::pblapply(X=temp_local_file,
                          FUN = function(x){

                            # read
                            temp_x <- data.table::fread(x,
                                                        showProgress = showProgress,
                                                        encoding = 'Latin-1',
                                                        colClasses = 'character',
                                                        sep = ';')
                            }) |>
    data.table::rbindlist(fill = TRUE)



  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)
} # nocov end


