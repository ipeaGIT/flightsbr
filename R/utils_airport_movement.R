
#' Retrieve all dates available for airport movements data
#'
#' @description
#' Retrieve from ANAC website all dates available for airport movements data.
#'
#' @return Numeric vector.
#' @export
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # check dates
#' a <- get_airport_movement_dates_available()
#'}}
get_airport_movement_dates_available <- function() {

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
  all_dates <- regmatches(csv_urls, gregexpr("\\d{6}", csv_urls))
  all_dates <- unlist(unique(all_dates))
  all_dates <- as.numeric(all_dates)

  return(all_dates)
}




#' Put together the url of airport movement data files
#'
#' @param date Numeric. Date of the data in the format `yyyymm`. Defaults to
#'             `202001`. To download the data for all months in a year, the user
#'             can pass a 4-digit year input `yyyy`. The parameter also accepts
#'             a vector of dates such as `c(202001, 202006, 202012)`.
#'
#' @return A url string.
#'
#' @keywords internal
#' @examples \dontrun{ if (interactive()) {
#' # Generate url
#' a <- get_airport_movements_url(year=2000, month=11)
#'}}
get_airport_movements_url <- function(date = parent.frame()$date) { # nocov start

  # https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/2021/Movimentacoes_Aeroportuarias_202112.csv
  url_root <- 'https://sistemas.anac.gov.br/dadosabertos/Operador%20Aeroportu%C3%A1rio/Dados%20de%20Movimenta%C3%A7%C3%A3o%20Aeroportu%C3%A1rias/'


  # date with format yyyymm
  if (all(nchar(date)==6)) {
    year <- substring(date,1,4)
    file_name <- paste0(year, '/', 'Movimentacoes_Aeroportuarias_', date, '.csv')
    file_urls <- paste0(url_root, file_name)
  }


  # date with format yyyy
  if (all(nchar(date)==4)) {
    all_dates <- generate_all_months(date)
    year <- substring(all_dates,1,4)
    file_name <- paste0(year, '/', 'Movimentacoes_Aeroportuarias_', all_dates, '.csv')
    file_urls <- paste0(url_root, file_name)
  }

  return(file_urls)
} # nocov end



#' Download and read ANAC airport movement data
#'
#' @param file_url String. A url passed from \code{\link{read_airport_movements}}.
#' @param showProgress Logical, passed from \code{\link{read_airport_movements}}
#' @param cache Logical, passed from \code{\link{read_airport_movements}}
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
download_airport_movement_data <- function(file_url = parent.frame()$file_url,
                                           showProgress = parent.frame()$showProgress,
                                           cache = parent.frame()$cache){ # nocov start

  # # create temp local file
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
      return(invisible(NULL))                                                 #nocov
    }
  }





  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # # assign column classes
  # dt_classes <- list(IDate=c('DT_PREVISTO', 'DT_CALCO', 'DT_TOQUE'),
  #                    ITime =c('HH_PREVISTO', 'HH_CALCO', 'HH_TOQUE'))

  # download data and read .csv data file
  dt <- pbapply::pblapply(X=temp_local_file, FUN= data.table::fread,
                          showProgress = showProgress,
                          colClasses = 'character',
                          sep = ';'
  ) |>
    data.table::rbindlist(fill = TRUE)



  # return to original threads
  data.table::setDTthreads(orig_threads)

  return(dt)
} # nocov end


