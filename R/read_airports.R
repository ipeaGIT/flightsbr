#' Download airports data from Brazil
#'
#' @description
#' Download data of all airports and aerodromes registered in Brazil’s Civil
#' Aviation Agency (ANAC). Data source: \url{https://www.gov.br/anac/pt-br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos}.
#' The data dictionary for public airports can be found at \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-publicos-v2/70-lista-de-aerodromos-publicos-v2}.
#' The data dictionary for private airports can be found at \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aerodromos/lista-de-aerodromos-privados-v2}.
#'
#' @param type String. Whether the function should download data on `all`,
#'             `public` or `private` airports. Defaults to `all`, returning fewer
#'             columns. Downloading `public` and `private` airports separately
#'             will return the full set of columns available for each of those
#'             data sets.
#' @template showProgress
#' @template cache
#'
#' @return A `"data.table" "data.frame"` object.
#' @importFrom data.table :=
#' @export
#' @family download airport data
#' @examples \dontrun{ if (interactive()) {
#' # Read airports data
#' all_airports <- read_airports(type = 'all')
#'
#' public_airports <- read_airports(type = 'public')
#'
#' private_airports <- read_airports(type = 'private')
#'}}
read_airports <- function(type = 'all',
                          showProgress = TRUE,
                          cache = TRUE
                          ){

### check inputs
  if( ! type %in% c('public', 'private', 'all') ){ stop(paste0("Argument 'type' must be either 'all, 'public' or 'private'")) }
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }
  if( ! is.logical(cache) ){ stop(paste0("Argument 'cache' must be either 'TRUE' or 'FALSE.")) }

  # data url
  # https://www.gov.br/anac/pt-br/assuntos/regulados/aerodromos/lista-de-aerodromos-civis-cadastrados

  url_public <- 'https://sistemas.anac.gov.br/dadosabertos/Aerodromos/Aer%C3%B3dromos%20P%C3%BAblicos/Lista%20de%20aer%C3%B3dromos%20p%C3%BAblicos/AerodromosPublicos.csv'
  url_private <- 'https://sistemas.anac.gov.br/dadosabertos/Aerodromos/Aer%C3%B3dromos%20Privados/Lista%20de%20aer%C3%B3dromos%20privados/Aerodromos%20Privados/AerodromosPrivados.csv'

### download public airports
if (any(type %in% c('public', 'all'))){

  # create temp local file
  file_name <- basename(url_public)
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
    check_download <- download_flightsbr_file(file_url=url_public,
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
  orig_threads <- data.table::getDTthreads() # nocov
  data.table::setDTthreads(percent = 100)  # nocov

  # download and read data
  dt_public <- data.table::fread(temp_local_file,
                                 skip = 1,
                                 encoding = 'Latin-1',
                                 colClasses = 'character',
                                 sep = ';',
                                 showProgress=showProgress)


  # return to original threads
  data.table::setDTthreads(orig_threads)  # nocov

  # clean names
  nnn <- names(dt_public)
  data.table::setnames(
    x = dt_public,
    old = nnn,
    new = janitor::make_clean_names(nnn)
  )

  # fix geographical coordinates
  latlon_to_numeric(dt_public)
  altitude_to_numeric(dt_public)

  # add type info
   data.table::setDT(dt_public)[, type := 'public']

   # convert columns to numeric
   convert_to_numeric(dt_public)

  }


### download private airports
if (any(type %in% c('private', 'all'))){

  # create temp local file
  file_name <- basename(url_private)
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
    check_download <- download_flightsbr_file(file_url=url_private,
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

  # download and read data
  dt_private <- data.table::fread(temp_local_file,
                                  skip = 1,
                                  encoding = 'Latin-1',
                                  colClasses = 'character',
                                  sep = ';',
                                  showProgress=showProgress)


  # return to original threads
  data.table::setDTthreads(orig_threads)

  # clean names
  nnn <- names(dt_private)
  data.table::setnames(
    x = dt_private,
    old = nnn,
    new = janitor::make_clean_names(nnn)
  )

  # fix geographical coordinates
  latlon_to_numeric(dt_private)
  altitude_to_numeric(dt_private)

  # add type info
   dt_private[, type := 'private']

   # convert columns to numeric
   convert_to_numeric(dt_private)
  }


### return results
if (type == 'private') { return(dt_private) }
if (type == 'public') { return(dt_public) }
if (type == 'all') {
                    ## find columns in common
                    # cols_to_keep <- c("codigo_oaci", "ciad", "nome", "uf", "longitude", "latitude", "altitude")
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

