# nocov start


#' Retrieve from ANAC website all dates available for flights data
#'
#' @return Numeric vector.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_flight_dates_available()
#'}}
get_flight_dates_available <- function() {

  # read html table
  url = 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/'
  h <- try(rvest::read_html(url), silent = TRUE)

  # check if internet connection worked
  if (class(h)[1]=='try-error') {
    message("Problem connecting to ANAC data server")
    return(invisible(NULL))
  }

  # filter elements of basica data
  elements <- rvest::html_elements(h, "a")
  basica_urls <- elements[ data.table::like(elements, '/basica') ]
  basica_urls <- lapply(X=basica_urls, FUN=function(i){rvest::html_attr(i,"href")})

  # get all dates available
  all_dates <- substr(basica_urls, (nchar(basica_urls) + 1) -11, nchar(basica_urls)-4 )
  all_dates <- gsub("[-]", "", all_dates)
  all_dates <- as.numeric(all_dates)
  return(all_dates)
}


#' Check whether date input is acceptable
#' @param date Numeric. Either a 6-digit date in the format `yyyymm` or a 4-digit
#'             date input `yyyy` .
#' @param all_dates Numeric vector created with the get_all_dates_available() function.
#'
#' @return Check messages.
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

  if (nchar(date)==6) {
    if (!(date %in% all_dates)) {stop(paste0("So far, the data is only available for dates between ", min(all_dates), " and ", max(all_dates), "."))}
    }

  if (nchar(date)!=6) {
    if (!(date %in% 2000:2021)) {stop(paste0("So far, the data is only available for dates between ", min(all_dates), " and ", max(all_dates), "."))}
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



#' Put together the url of flight data files
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
#' a <- get_flights_url(type='basica', year=2000, month=11)
#'}}
get_flights_url <- function(type, year, month) {

  # https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/basica2021-01.zip

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  url_root <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/'
  file_name <- paste0(type, year, '-', month, '.zip')
  file_url <- paste0(url_root, file_name)
  return(file_url)
}



#' Download and read ANAC flight data
#'
#' @param file_url String. A url passed from get_flights_url.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#' @param select A vector of column names or numbers to keep, passed from \code{\link{read_flights}}
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_flights_url(type='basica', year=2000, month=11)
#'
#' # download data
#' a <- download_flights_data(file_url=file_url, showProgress=TRUE, select=NULL)
#'}}
download_flights_data <- function(file_url, showProgress=showProgress, select=select){

  # create temp local file
  # file_name <- substr(file_url, (nchar(file_url) + 1) -17, nchar(file_url) )
  file_name <- basename(file_url)
  temp_local_file <- tempfile( file_name )

  # download data
  try(
    httr::GET(url=file_url,
              if(showProgress==T){ httr::progress()},
              httr::write_disk(temp_local_file, overwrite = T),
              config = httr::config(ssl_verifypeer = FALSE)
    ), silent = TRUE)

  # address of zipped file stored locally
  temp_local_file_zip <- paste0('unzip -p ', temp_local_file)

  # check if file has been downloaded
  if (!file.exists(temp_local_file) | file.info(temp_local_file)$size == 0) {
        message('Internet connection not working.')
        return(invisible(NULL)) }

  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # read zipped file stored locally
  dt <- data.table::fread( cmd =  temp_local_file_zip, select=select)

  # return to original threads
  data.table::setDTthreads(orig_threads)

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

  # https://semba-blog.netlify.app/02/25/2020/geographical-coordinates-conversion-made-easy-with-parzer-package-in-r/

  # # create column identifying whether coordinates in the South or West
  # df$south_west <- data.table::fifelse( data.table::like(df[[colname]], 'S|W' ), -1, 1)

  # get vector
  vec <- df[[colname]]

  # # fix string
  # vec <- gsub("[W|S]", "", vec) # remove text
  vec <- gsub("[\u00c2]", "", vec) # remove special characters Â

  if(colname=='latitude'){
                  df[[colname]] <- parzer::parse_lat(vec)
                  }

  if(colname=='longitude'){
    df[[colname]] <- parzer::parse_lon(vec)
  }

  # # fix string
  # vec <- gsub("[.]", "", vec) # replace any decimal markers
  # vec <- gsub("[\ub0]", ".", vec) # replace the degree symbol ° with a point '.'
  # vec <- gsub("[^0-9.-]", "", vec) # keep only numeric
  #
  # # convert to numeric
  # df[[colname]] <- as.numeric(vec) * df$south_west
  # df$south_west <- NULL

  return(df)
}





#' Retrieve all dates available for airport movements data
#'
#' @description
#' Retrieve from ANAC website all dates available for airport movements data.
#'
#' @param date Numeric. Either a 6-digit date in the format `yyyymm` or a 4-digit
#'             date input `yyyy`. Defaults to `NULL`, in which case the function
#'             retrieves information for all years available.
#'
#' @return Numeric vector.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_airport_movement_dates_available()
#'}}
get_airport_movement_dates_available <- function(date=NULL) {

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









#' Put together the url of airport movement data files
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
get_airport_movements_url <- function(year, month) {

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  # https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/2021/Movimentacoes_Aeroportuarias_202112.csv
  url_root <- 'https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/'
  file_name <- paste0(year, '/', 'Movimentacoes_Aeroportuarias_', year, month, '.csv')
  file_url <- paste0(url_root, file_name)
  return(file_url)
}




#' Download and read ANAC airport movement data
#'
#' @param file_url String. A url passed from get_flights_url.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#'
#' @return A `"data.table" "data.frame"` object
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_airport_movements_url(year=2020, month=11)
#'
#' # download data
#' a <- download_airport_movement_data(file_url=file_url, showProgress=TRUE)
#'}}
download_airport_movement_data <- function(file_url, showProgress=showProgress){

  # create temp local file
  # file_name <- substr(file_url, (nchar(file_url) + 1) -17, nchar(file_url) )
  file_name <- basename(file_url)

  temp_local_file <- tempfile( file_name )

  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # download data and read .csv data file
  dt <- try( data.table::fread(file_url, showProgress = showProgress), silent = TRUE)

  # return to original threads
  data.table::setDTthreads(orig_threads)

  # check if file has been downloaded
  if (class(dt)[1]=='try-error') {
    message("Problem connecting to ANAC data server. Please try again.")
    return(invisible(NULL))
  }

  return(dt)
}

# nocov end
