#' Download airports data from Brazil
#'
#' @description
#' Download data of all airports and aerodromes registered in Brazil’s Civil
#' Aviation Agency (ANAC). Data source: \url{https://www.gov.br/anac/pt-br/assuntos/regulados/aerodromos/lista-de-aerodromos-civis-cadastrados}.
#' The data dictionary for public airports can be found at \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-publicos-v2/70-lista-de-aerodromos-publicos-v2}.
#' The data dictionary for private airports can be found at \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-privados-v2}.
#'
#' @param type String. Whether the function should download data on `all`,
#'             `public` or `private` airports. Defaults to `all`, returning fewer
#'             columns. Downloading `public` and `private` airports separately
#'             will return the full set of columns available for each of those
#'             data sets.
#'
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#' @return A `"data.table" "data.frame"` object.
#' @export
#' @family download airport data
#' @importFrom data.table %like%
#' @examples \dontrun{ if (interactive()) {
#' # Read airports data
#' all_airports <- read_airports(type = 'all')
#'
#' public_airports <- read_airports(type = 'public')
#'
#' private_airports <- read_airports(type = 'private')
#'}}
read_airports <- function(type = 'all', showProgress = TRUE){

### check inputs
  if( ! type %in% c('public', 'private', 'all') ){ stop(paste0("Argument 'type' must be either 'all, 'public' or 'private'")) }
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

  # data url
  # https://www.gov.br/anac/pt-br/assuntos/regulados/aerodromos/lista-de-aerodromos-civis-cadastrados
  url_public <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/aerodromos/cadastro-de-aerodromos/aerodromos-cadastrados/cadastro-de-aerodromos-civis-publicos.csv'
  url_private <- 'https://sistemas.anac.gov.br/dadosabertos/Aerodromos/Lista%20de%20aer%C3%B3dromos%20privados/Aerodromos%20Privados/AerodromosPrivados.csv'

### download public airports
if (any(type %in% c('public', 'all'))){

  dt_public <- try(silent=T,
                   data.table::fread(url_public,
                                     skip = 2,
                                     # encoding = 'Latin-1',
                                     showProgress=showProgress))
  # check if download succeeded
  if (class(dt_public)[1]=="try-error") {
                          message('Internet connection not working.')
                          return(invisible(NULL)) }

  # fix column names to lower case
  pbl_names <- unlist(c(dt_public[1,]))
  pbl_names <- iconv(pbl_names, from = 'utf8', to = 'utf8')
  data.table::setnames(dt_public, tolower(prv_names) )
  dt_public <- dt_public[-1,]

  # fix geographical coordinates
  dt_public <- latlon_to_numeric(df=dt_public, colname = 'LATITUDE')
  dt_public <- latlon_to_numeric(df=dt_public, colname = 'LONGITUDE')

  # # names to lower case
  # pbl_names <- iconv(names(dt_public), from = 'ISO-8859-1', to = 'utf8')
  # data.table::setnames(dt_public, tolower(names(pbl_names)))
  }

### download private airports
if (any(type %in% c('private', 'all'))){

  dt_private <- try(silent=T,
                    data.table::fread(url_private,
                                      skip = 1,
                                      # encoding = 'Latin-1',
                                      showProgress=showProgress))
  # check if download succeeded
  if (class(dt_private)[1]=="try-error") {
                          message('Internet connection not working.')
                          return(invisible(NULL)) }

  # fix column names to lower case
  prv_names <- iconv(names(dt_private), from = 'ISO-8859-1', to = 'utf8')
  data.table::setnames(dt_private, tolower(prv_names))

  # # names to to lower case
  # prv_names <- iconv(names(dt_private), from = 'ISO-8859-1', to = 'utf8')
  # data.table::setnames(dt_private, tolower(prv_names))

  # fix geographical coordinates
  dt_private <- latlon_to_numeric(df=dt_private, colname = 'Latitude')
  dt_private <- latlon_to_numeric(df=dt_private, colname = 'Longitude')

  }

if (type == 'private') { return(dt_private) }
if (type == 'public') { return(dt_public) }
if (type == 'all') {
                    ## find columns in common
                    # cols_to_keep <- c("código oaci", "ciad", "nome", "uf", "longitude", "latitude", "altitude")
                    a <- names(dt_private)
                    b <- names(dt_public)
                    cols_to_keep <- a[a %in% b]

                    ## subset columns in common
                    dt_public <- dt_public[, cols_to_keep, with=FALSE]
                    dt_private <- dt_private[, cols_to_keep, with=FALSE]

                    dt <- data.table::rbindlist(list(dt_public, dt_private), use.names=FALSE)

                    return(dt)
                    }
}

