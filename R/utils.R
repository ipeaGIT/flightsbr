#' Retrieve all dates available for flights data from ANAC website
#'
#' @return Numeric vector.
#' @export
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_flight_dates_available()
#'}}
get_flight_dates_available <- function() {

  # read html table
  url = 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/envio-de-informacoes'
  h <- try(rvest::read_html(url), silent = TRUE)

  # check if internet connection worked
  if (class(h)[1]=='try-error') {                                           #nocov
    message("Problem connecting to ANAC data server. Please try it again.") #nocov
    return(invisible(NULL))                                                 #nocov
  }

  # filter elements of basica data
  elements <- rvest::html_elements(h, "a")
  basica_urls <- elements[ data.table::like(elements, '/basica') ]
  basica_urls <- lapply(X=basica_urls, FUN=function(i){rvest::html_attr(i,"href")})

  # get all dates available
  all_dates <- substr(basica_urls, (nchar(basica_urls) + 1) -11, nchar(basica_urls)-4 )
  all_dates <- gsub("[-]", "", all_dates)

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
#' @export
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

    # check length
    if ( ! nchar(date) %in% c(4,6)) {stop("Date has to be either `NULL` or a 4- or 6-digit number `yyyymm`")}

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
  csv_urls <- gsub('.csv.csv', '.csv', csv_urls, fixed = TRUE)

  # get all dates available
  all_dates <- substr(csv_urls , (nchar(csv_urls ) + 1) -10, nchar(csv_urls )-4 )
  all_dates <- as.numeric(all_dates)
  return(all_dates)
}


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



#' Generate all months with `yyyymm` format in a year
#'
#' @param date Numeric. 4-digit date in the format `yyyy`.
#' @return Vector or strings.
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate all months in 2000
#' a <- check_date(2000)
#'}}
generate_all_months <- function(date) { # nocov start

  # check
  if( nchar(date)!=4 ){ stop(paste0("Argument 'date' must be 4-digit in the format `yyyy`.")) }

  jan <- as.numeric(paste0(date, '01'))
  dec <- as.numeric(paste0(date, '12'))
  all_months <- jan:dec
  return(all_months)
} # nocov end



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
get_flights_url <- function(type, year, month) { # nocov start

  # old https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/basica2021-01.zip
  # old https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/microdados/
  # new https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/microdados/basica2021-01.zip
  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  url_root <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/envio-de-informacoes'

  file_name <- paste0('/', type,'/', year, '/',type, year, '-', month, '.zip')
  file_url <- paste0(url_root, file_name)
  return(file_url)
} # nocov end


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


#' Download file from url
#'
#' @param file_url String. A url passed from get_flights_url.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#' @param dest_file String, passed from \code{\link{read_flights}}
#'
#' @return Silently saves downloaded file to temp dir.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' file_url <- get_flights_url(type='basica', year=2000, month=11)
#'
#' # download data
#' download_flightsbr_file(file_url=file_url,
#'                         showProgress=TRUE,
#'                         dest_file = tempfile(fileext = ".zip")
#'                        )
#'}}
download_flightsbr_file <- function(file_url, showProgress=showProgress, dest_file = temp_local_file){

  # download data
  try(
    httr::GET(url=file_url,
              if(showProgress==T){ httr::progress()},
              httr::write_disk(dest_file, overwrite = T),
              config = httr::config(ssl_verifypeer = FALSE)
    ), silent = TRUE)

  # check if file has NOT been downloaded, try a 2nd time
  if (!file.exists(dest_file) | file.info(dest_file)$size == 0) {

    # download data: try a 2nd time
    try(
      httr::GET(url=file_url,
                if(showProgress==T){ httr::progress()},
                httr::write_disk(dest_file, overwrite = T),
                config = httr::config(ssl_verifypeer = FALSE)
      ), silent = TRUE)
  }

  # Halt function if download failed
  if (!file.exists(dest_file) | file.info(dest_file)$size == 0) {
    message('Internet connection not working.')
    return(invisible(NULL)) }
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
download_flights_data <- function(file_url, showProgress=showProgress, select=select){ # nocov start

  # create temp local file
  file_name <- basename(file_url)
  temp_local_file <- paste0(tempdir(),"/",file_name)

  # check if file has not been downloaded already. If not, download it
  if (!file.exists(temp_local_file) | file.info(temp_local_file)$size == 0) {

  # download data
  download_flightsbr_file(file_url=file_url, showProgress=showProgress, dest_file = temp_local_file)
  }

  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # # address of zipped file stored locally
  # temp_local_file_zip <- paste0('unzip -p ', temp_local_file)
  #
  # # read zipped file stored locally
  # dt <- data.table::fread( cmd =  temp_local_file_zip, select=select, colClasses = 'character', sep = ';')

  # unzip file to tempdir
  temp_local_dir <- tempdir()
  utils::unzip(zipfile = temp_local_file, exdir = temp_local_dir)

  # get file name
  file_name <- utils::unzip(temp_local_file, list = TRUE)$Name

  # read file stored locally
  dt <- data.table::fread( paste0(temp_local_dir,'/', file_name),
                           select = select,
                           colClasses = 'character',
                           sep = ';')

  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)
  } # nocov end




#' Download and read ANAC air fares data
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
#' file_url <- get_airfares_url(dom = TRUE, year=2002, month=11)
#'
#' # download data
#' a <- download_airfares_data(file_url=file_url, showProgress=TRUE, select=NULL)
#'}}
download_airfares_data <- function(file_url, showProgress=showProgress, select=select){ # nocov start

  # create temp local file
  file_name <- basename(file_url)
  temp_local_file <- paste0(tempdir(),"/",file_name)

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
#' a <- get_airport_movements_url(year=2000, month=11)
#'}}
get_airport_movements_url <- function(year, month) { # nocov start

  if( nchar(month) ==1 ) { month <- paste0('0', month)}

  # https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/2021/Movimentacoes_Aeroportuarias_202112.csv
  url_root <- 'https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/'
  file_name <- paste0(year, '/', 'Movimentacoes_Aeroportuarias_', year, month, '.csv')
  file_url <- paste0(url_root, file_name)
  return(file_url)
} # nocov end




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
download_airport_movement_data <- function(file_url, showProgress=showProgress){ # nocov start

  # # create temp local file
  file_name <- basename(file_url)
  temp_local_file <- paste0(tempdir(),"/",file_name)

  # check if file has not been downloaded already. If not, download it
  if (!file.exists(temp_local_file) | file.info(temp_local_file)$size == 0) {

    # download data
    download_flightsbr_file(file_url=file_url, showProgress=showProgress, dest_file = temp_local_file)
  }

  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # # assign column classes
  # dt_classes <- list(IDate=c('DT_PREVISTO', 'DT_CALCO', 'DT_TOQUE'),
  #                    ITime =c('HH_PREVISTO', 'HH_CALCO', 'HH_TOQUE'))

  # download data and read .csv data file
  dt <- data.table::fread(temp_local_file, showProgress = showProgress, colClasses = 'character', sep = ';')
  # class(dt$DT_CALCO)
  # class(dt$HH_PREVISTO)


  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)
} # nocov end
