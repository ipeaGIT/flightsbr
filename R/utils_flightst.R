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




#' Put together the url of flight data files
#'
#' @param type String. Whether the data set should be of the type `basica`
#'             (flight stage, the default) or `combinada` (On flight origin and
#'             destination - OFOD).
#' @param date Numeric. Date of the data in the format `yyyymm`. Defaults to
#'             `202001`. To download the data for all months in a year, the user
#'             can pass a 4-digit year input `yyyy`. The parameter also accepts
#'             a vector of dates such as `c(202001, 202006, 202012)`.
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate urls
#' a <- get_flights_url(type='basica', year=2000, month=11)
#'}}
get_flights_url <- function(type, date) { # nocov start

  # old https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/basica2021-01.zip
  # old https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/microdados/
  # new https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/microdados/basica2021-01.zip

  # set root url
  url_root <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/Instrucoes-para-a-elaboracao-e-apresentacao-das-demonstracoes-contabeis/envio-de-informacoes'

  # date with format yyyymm
  if (all(nchar(date)==6)) {
    y <- substring(date, 1, 4)
    m <- substring(date, 5, 6)
    url_spec <- paste0('/', type,'/', y, '/',type, y, '-', m, '.zip')
    file_urls <- paste0(url_root, url_spec)
    #  file_names <- basename(file_urls)
  }

  # date with format yyyy
  if (all(nchar(date)==4)) {
    all_dates <- generate_all_months(date)
    y <- substring(all_dates, 1, 4)
    m <- substring(all_dates, 5, 6)
    url_spec <- paste0('/', type,'/', y, '/',type, y, '-', m, '.zip')
    file_urls <- paste0(url_root, url_spec)
    #  file_names <- basename(file_urls)
  }

  return(file_urls)
} # nocov end



#' Download and read ANAC flight data
#'
#' @param file_url String. A url passed from \code{\link{get_flights_url}}.
#' @param showProgress Logical, passed from \code{\link{read_flights}}
#' @param select A vector of column names or numbers to keep, passed from \code{\link{read_flights}}
#' @param cache Logical, passed from \code{\link{read_flights}}
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
download_flights_data <- function(file_url = parent.frame()$file_url,
                                  showProgress = parent.frame()$showProgress,
                                  select = parent.frame()$select,
                                  cache = parent.frame()$cache){ # nocov start

  # create temp local file
  file_name <- basename(file_url)
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
    check_download <- download_flightsbr_file(
      file_url=file_url,
      showProgress=showProgress,
      dest_file = temp_local_file,
      cache = cache)

  # check if internet connection worked
  if (is.null(check_download)) { # nocov start
    message("Problem connecting to ANAC data server. Please try it again.") #nocov
    return(invisible(NULL))                                              #nocov
    } # nocov end
  }


  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  ## unzip and fread
  unzip_and_fread <- function(single_temp_local_file,
                              showProgress = parent.frame()$showProgress,
                              select = parent.frame()$select){

    # single_temp_local_file = temp_local_file[1]

    # unzip file to tempdir
    temp_local_dir <- fs::path_temp()

    #  utils::unzip(zipfile = single_temp_local_file, exdir = temp_local_dir)
    archive::archive_extract(
      archive = single_temp_local_file,
      dir = temp_local_dir
      )


    # get file name
    file_name <- utils::unzip(single_temp_local_file, list = TRUE)$Name

    # read file stored locally
    temp_dt <- data.table::fread(fs::path(temp_local_dir, file_name),
                                 select = select,
                                 showProgress = showProgress,
                                 colClasses = 'character',
                                 sep = ';',
                                 encoding = 'Latin-1')
    return(temp_dt)
  }

  message('Unziping and reading data to memory.')
  if(isTRUE(showProgress)){
    dt <- pbapply::pblapply(X=temp_local_file, FUN=unzip_and_fread,
                            select = select,
                            showProgress = showProgress)
  } else {
    dt <- lapply(X=temp_local_file, FUN=unzip_and_fread,
                 select = select,
                 showProgress = showProgress)
  }


  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)

} # nocov end

