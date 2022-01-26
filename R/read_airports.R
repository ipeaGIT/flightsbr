#' Download airports data from Brazil
#'
#' @description
#' Download data of all airports and aerodromes registered in Brazil’s Civil
#' Aviation Agency (ANAC). Data source: \url{https://www.gov.br/anac/pt-br/assuntos/regulados/aerodromos/lista-de-aerodromos-civis-cadastrados}.
#' The data dictionary for public airports can be found at \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-publicos-v2/70-lista-de-aerodromos-publicos-v2}.
#' The data dictionary for private airports can be found at \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-privados-v2}.
#'
#' @param type String. Whether function should download data  on `public` (Default)
#'             or `private` airports.
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#' @return A `"data.table" "data.frame"` object.
#' @export
#' @family download airport data
#' @importFrom data.table %like%
#' @examples \dontrun{ if (interactive()) {
#' # Read airports data
#' public_airports <- read_airports(type = 'public')
#'
#' private_airports <- read_airports(type = 'private')
#'}}
read_airports <- function(type = 'public', showProgress = TRUE){

### check inputs
  if( ! type %in% c('public', 'private') ){ stop(paste0("Argument 'type' must be either 'public' or 'private'")) }
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

  # data url
  url_public <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/aerodromos/cadastro-de-aerodromos/aerodromos-cadastrados/cadastro-de-aerodromos-civis-publicos.csv'
  url_private <- 'https://sistemas.anac.gov.br/dadosabertos/Aerodromos/Lista%20de%20aer%C3%B3dromos%20privados/Aerodromos%20Privados/AerodromosPrivados.csv'

### download public airports
if (type=='public'){

  dt_public <- try(silent=T,
                   data.table::fread(url_public,
                                     skip = 2,
                                     encoding = 'UTF-8',
                                     showProgress=showProgress))
  # check if download succeeded
  if (class(dt_public)[1]=="try-error") {
                          message('Internet connection not working.')
                          return(invisible(NULL)) }

  # fix column names
  data.table::setnames(dt_public, unlist(c(dt_public[1,])) )
  dt_public <- dt_public[-1,]

  # fix geographical coordinates
  dt_public <- latlon_to_numeric(df=dt_public, colname = 'LATITUDE')
  dt_public <- latlon_to_numeric(df=dt_public, colname = 'LONGITUDE')

  return(dt_public)
  }

### download private airports
else if (type=='private'){

  dt_private <- try(silent=T,
                    data.table::fread(url_private,
                                      skip = 1,
                                      showProgress=showProgress))
  # check if download succeeded
  if (class(dt_private)[1]=="try-error") {
                          message('Internet connection not working.')
                          return(invisible(NULL)) }

  # fix geographical coordinates
  dt_private <- latlon_to_numeric(df=dt_private, colname = 'Latitude')
  dt_private <- latlon_to_numeric(df=dt_private, colname = 'Longitude')

  ## last time the data was updated
  # last_update_private <- data.table::fread(url_private, nrows = 1)
  # last_update_private[1,]
  return(dt_private)
  }
}

