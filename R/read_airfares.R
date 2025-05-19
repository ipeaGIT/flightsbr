#' Download data on airfares flights in Brazil
#'
#' @description
#' Download data on air fares of domestic and international flights in Brazil.
#' The data is collected by Brazil’s Civil Aviation Agency (ANAC). A description
#' of all variables included in the data for domestic airfares is available at
#' \url{https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/voos-e-operacoes-aereas/tarifas-aereas-domesticas/46-tarifas-aereas-domesticas}.
#' A description of all variables included in the data for international airfares
#' is available at \url{https://www.gov.br/anac/pt-br/assuntos/dados-e-estatisticas/microdados-de-tarifas-aereas-comercializadas}.
#'
#' @template date
#' @param domestic Logical. Defaults to `TRUE` download airfares of domestic
#'                 flights. If `FALSE`, the function downloads airfares of
#'                 international flights.
#' @template showProgress
#' @template select
#' @template cache

#' @return A `"data.table" "data.frame"` object. All columns are returned with
#'         `class` of type `"character"`.
#' @export
#' @family download air fares data
#' @examples \dontrun{ if (interactive()) {
#' # Read air fare data
#' af_201506 <- read_airfares(date = 201506, domestic = TRUE)
#'
#' af_2015 <- read_airfares(date = 2015, domestic = TRUE)
#'}}
read_airfares <- function(date = NULL,
                          domestic = TRUE,
                          showProgress = TRUE,
                          select = NULL,
                          cache = TRUE
                          ){


  ### check inputs
  if( ! is.logical(domestic) ){ stop(paste0("Argument 'domestic' must be either 'TRUE' or 'FALSE.")) }
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }
  if( ! is.logical(cache) ){ stop(paste0("Argument 'cache' must be either 'TRUE' or 'FALSE.")) }
  check_input_date_format(date)

  ### check date input
  # get all dates available
  all_dates <- get_airfares_dates_available(dom = domestic)


  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) }

  # check dates
  if (is.null(date)) { date <- max(all_dates) }
  check_date(date=date, all_dates)

  # prepare address of online data
  file_urls <- get_airfares_url(dom = domestic, date)

  # download and read data
  dt <- download_airfares_data(file_urls = file_urls,
                               showProgress = showProgress,
                               cache = cache)

  # check if download failed
  if (is.null(dt)) { return(invisible(NULL)) }

  # clean names
  nnn <- names(dt)
  data.table::setnames(
    x = dt,
    old = nnn,
    new = janitor::make_clean_names(nnn)
  )

  # convert columns to numeric
  convert_to_numeric(dt, type='airfare')

  return(dt)
}

