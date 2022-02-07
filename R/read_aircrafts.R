#' Download aircrafts data from Brazil
#'
#' @description
#'
#' Download data of all aircrafts registered in the Brazilian Aeronautical
#' Registry (Registro Aeronáutico Brasileiro - RAB), organized by the Brazilian
#' Civil Aviation Agency (ANAC). A description of all variables included in the
#' data is available at \url{https://www.gov.br/anac/pt-br/sistemas/rab}.
#'
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#'
#' @return A `"data.table" "data.frame"` object.
#' @export
#' @family download flight data
#' @examples \dontrun{ if (interactive()) {
#' # Read aircrafts data
#' aircrafts <- read_aircrafts(showProgress = TRUE)
#'
#'}}
read_aircrafts <- function( showProgress = TRUE ){

### check inputs
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

  # data url
  # https://dados.gov.br/dataset/aeronaves-registradas-no-registro-aeronautico-brasileiro-rab
  # https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/aeronaves/registro-aeronautico-brasileiro
  rab_url <- 'https://www.anac.gov.br/dadosabertos/areas-de-atuacao/aeronaves/registro-aeronautico-brasileiro/aeronaves-registradas-no-registro-aeronautico-brasileiro-csv'

  ### set threads for fread
  orig_threads <- data.table::getDTthreads()
  data.table::setDTthreads(percent = 100)

  # download data
  rab_dt <- try(silent=T,
                data.table::fread(rab_url,
                                  skip = 1,
                                  encoding = 'UTF-8',
                                  showProgress=showProgress))

   # return to original threads
   data.table::setDTthreads(orig_threads)

   # check if download succeeded
   if (class(rab_dt)[1]=="try-error") {
     message('Internet connection not working.')
     return(invisible(NULL)) }

   # return output
   return(rab_dt)
}
