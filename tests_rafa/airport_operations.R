
#' Retrieve all dates available for airport operations data
#'
#' @description
#' Retrieve from ANAC website all dates available for airport operations data.
#'
#' @param date Numeric. Either a 6-digit date in the format `yyyymm` or a 4-digit
#'             date input `yyyy`. Defaults to `NULL`, in which case the function
#'             retrieves information for all years available.
#'
#' @return Numeric vector.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_aiport_operation_dates_available()
#'}}
get_aiport_operation_dates_available <- function(date=NULL) {

  # read html table
  base_url = 'https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/'
  h <- try(rvest::read_html(base_url), silent = TRUE)

  # check if internet connection worked
  if (class(h)[1]=='try-error') {
    message("Problem connecting to ANAC data server. Please try it again.")
    return(invisible(NULL))
  }

  # get url of subdirectories
  elements <- rvest::html_elements(h, "a")
  href <- rvest::html_attr(elements, "href")
  years <- grep("../", href, fixed = TRUE, value = TRUE, invert = TRUE)
  urls <- paste0(base_url, years)

  ## check date input
  if (!is.null(date)) {
                        # get year and month
                        yyyy <- substr(date, 1, 4)
                        if (nchar(date)==6) { mm <- substr(date, 5, 6) }

                        # check year
                        if (sum(grepl(yyyy, years)) == 0){stop(paste0("Data only available for following years: ", paste0(years, collapse=" "))) }

                        # check month
                        if(exists("mm")){
                          if (!(as.numeric(mm) %in% 1:12)){stop(paste0("In date `yyyymm`, the month `mm` must be between 01 and 12"))}
                        }

                        # subset specific year
                        urls <- urls[ data.table::like(urls, yyyy)]
                        }

 # function to search .csv data in subdirectories
  recursive_search <- function(i){ # i=urls[2]

          # read html table
          h2 <- try(rvest::read_html(i), silent = TRUE)

          if (class(h2)[1]=='try-error') {
            message("Problem connecting to ANAC data server. Please try it again.")
            return(invisible(NULL))}

          # get url of subdirectories
          elements2 <- rvest::html_elements(h2, "a")
          href2 <- rvest::html_attr(elements2, "href")
          files_all <- grep("../", href2, fixed = TRUE, value = TRUE, invert = TRUE)
          files_csv <- files_all[ data.table::like(files_all, '.csv')]
          temp_urls <- paste0(i, files_csv)
          return(temp_urls)
          }

  # get urls of .csv files
  csv_urls <- lapply(X=urls, FUN=recursive_search)
  csv_urls <- unlist(csv_urls)
  # return(csv_urls) # if one wants to return the csv url

  # get all dates available
  all_dates <- substr(csv_urls , (nchar(csv_urls ) + 1) -10, nchar(csv_urls )-4 )
  all_dates <- as.numeric(all_dates)
  return(all_dates)
}









#' Put together the url of airport operation data files
#'
#' @param year Numeric. Year of the data in `yyyy` format.
#' @param month Numeric. Month of the data in `mm` format.
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' a <- get_flights_url(type='basica', year=2000, month=11)
#'}}
get_airport_operations_url <- function(year, month) {

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

             # https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/2021/Movimentacoes_Aeroportuarias_202112.csv
  url_root <- 'https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/'
  file_name <- paste0(year, '/', 'Movimentacoes_Aeroportuarias_', year, month, '.csv')
  file_url <- paste0(url_root, file_name)
  return(file_url)
}




#' Download and read ANAC airport operation data
#'
#' @param file_url String. A url passed from get_flights_url.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_airport_operations_url(year=2020, month=11)
#'
#' # download data
#' a <- download_airport_operation_data(file_url=file_url, showProgress=TRUE)
#'}}
download_airport_operation_data <- function(file_url, showProgress=showProgress){

  # create temp local file
  file_name <- substr(file_url, (nchar(file_url) + 1) -17, nchar(file_url) )
  temp_local_file <- tempfile( file_name )

  # download data and read .csv data file
  dt <- try( fread(file_url, showProgress = showProgress), silent = TRUE)

  # check if file has been downloaded
  if (class(dt)[1]=='try-error') {
    message("Problem connecting to ANAC data server. Please try again.")
    return(invisible(NULL))
  }

  return(dt)
}


