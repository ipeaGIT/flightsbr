#' Download flight data from Brazil
#'
#' @description
#' Download flight data from Brazil’s Civil Aviation Agency (ANAC). The data
#' includes detailed information on every international flight to and from Brazil,
#' as well as domestic flights within the country. The data include flight-level
#' information of airports of origin and destination, flight duration, aircraft
#' type, payload, and the number of passengers, and several other variables. A
#' description of all variables included in the data is available at \url{https://www.anac.gov.br/assuntos/setor-regulado/empresas/envio-de-informacoes/descricao-de-variaveis}.
#'
#' @param year Numeric. Year of the data. Defaults to `2010`
#' @param month Numeric. Year of the data. Defaults to `1` (January)
#' @param type String. Whether the data set should be of the type `basica`
#' (flight stage, the default) or `combinada` (On flight origin and destination
#' - OFOD).
#' @param showProgress Logical. Defaults to `TRUE` display progress bar
#'
#' @return A `"data.table" "data.frame"` object
#' @export
#' @family download flight data

#' @examples \dontrun{ if (interactive()) {
#' # Read flights data
#' a201506 <- read_flights(year=2015, month=6)
#'}}
read_flights <- function(year=2020, month=1, type='basica', showProgress=TRUE){

### check inputs
  # type
  if( ! type %in% c('basica', 'combinada') ){ stop(paste0("Argument 'type' must be either 'basica' or 'combinada'")) }

  # year and months perhaps use yyyymm ?

  # progress bar
  if( !(showProgress %in% c(T, F)) ){ stop("Value to argument 'showProgress' has to be either TRUE or FALSE") }


### prepare address of online data
  if( nchar(month) ==1 ) { month <- paste0('0', month)}
  url_root <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/'
  file_name <- paste0(type, year, '-', month, '.zip')
  file_url <- paste0(url_root, file_name)

### download data
  temp_local_file <- tempfile( file_name )
  # utils::download.file(url = file_url, destfile = temp_local_file)

  try(
    httr::GET(url=file_url,
             if(showProgress==T){ httr::progress()},
              httr::write_disk(temp_local_file, overwrite = T),
              config = httr::config(ssl_verifypeer = FALSE)
    ), silent = F)

### read zipped file stored locally
  temp_local_file_zip <- paste0('unzip -p ', temp_local_file)
  dt <- data.table::fread( cmd =  temp_local_file_zip)
  return(dt)
}

