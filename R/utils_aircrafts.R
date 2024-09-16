
#' Retrieve all dates available for aircrafts data from ANAC website
#'
#' @return Numeric vector.
#' @export
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_aircrafts_dates_available()
#'}}
get_aircrafts_dates_available <- function() {

  # read html table
  base_url = 'https://sistemas.anac.gov.br/dadosabertos/Aeronaves/RAB/Historico_RAB/'
  h <- try(rvest::read_html(base_url), silent = TRUE)

  # check if internet connection worked
  if (class(h)[1]=='try-error') {                                           #nocov
    message("Problem connecting to ANAC data server. Please try it again.") #nocov
    return(invisible(NULL))                                                 #nocov
  }

  # filter elements of basica data
  elements <- rvest::html_elements(h, "a")
  basica_urls <- elements[ data.table::like(elements, '.csv') ]
  basica_urls <- lapply(X=basica_urls, FUN=function(i){rvest::html_attr(i,"href")})

  # get all dates available
  all_dates <- substr(basica_urls, 1, nchar(basica_urls)-4 )
  all_dates <- gsub("[-]", "", all_dates)
  all_dates <- gsub("[_]", "", all_dates)

  # remove eventual letters
  all_dates <- sub("a", "", all_dates, fixed = TRUE)
  ## remove ALL eventual letters
  # all_dates <- lapply(X = base::letters,
  #                     FUN = function(x){
  #                       all_datesf <- sub(x, "", all_dates, fixed = TRUE)
  #                       return(all_datesf)}
  #                     )
  all_dates <- unique(all_dates)
  all_dates <- as.numeric(all_dates)
  return(all_dates)
}



#' Put together the url of aircrafts data files
#'
#' @param year Numeric. Year of the data in `yyyy` format.
#' @param month Numeric. Month of the data in `mm` format.
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' a <- get_flights_url(year=2000, month=11)
#'}}
get_aircrafts_url <- function(year, month) { # nocov start

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  url_root <- 'https://sistemas.anac.gov.br/dadosabertos/Aeronaves/RAB/Historico_RAB/'

  file_name <- paste0(year, '-', month, '.csv')
  file_url <- paste0(url_root, file_name)
  return(file_url)
} # nocov end



#' Download and read ANAC aircraft data
#'
#' @param file_url String. A url passed from \code{\link{get_flights_url}}.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
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
download_aircrafts_data <- function(file_url = parent.frame()$file_url,
                                    showProgress = parent.frame()$showProgress
){ # nocov start

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
  dt <- data.table::fread(input = temp_local_file,
                          encoding = 'UTF-8',
                          colClasses = 'character',
                          skip = 1,
                          sep = ';') # , dec = ','

  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)
} # nocov end
