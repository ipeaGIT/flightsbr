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
#' @param date Numeric. Date of the data in the format `yyyymm`. Defaults to
#'             `202001`. To download the data for all months in a year, the user
#'             can pass a 4-digit year input `yyyy`.
#' @param domestic Logical. Defaults to `TRUE` download airfares of domestic
#'                 flights. If `FALSE`, the function downloads airfares of
#'                 international flights.
#' @param showProgress Logical. Defaults to `TRUE` display progress.
#' @param select A vector of column names or numbers to keep, drop the rest. The
#'               order that the columns are specified determines the order of the
#'               columns in the result.
#'
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
read_airfares <- function(date = 202001, domestic = TRUE, showProgress = TRUE, select = NULL){

### check inputs
  if( ! is.logical(domestic) ){ stop(paste0("Argument 'domestic' must be either 'TRUE' or 'FALSE.")) }
  if( ! is.logical(showProgress) ){ stop(paste0("Argument 'showProgress' must be either 'TRUE' or 'FALSE.")) }

### check date input
  # get all dates available
  all_dates <- get_airfares_dates_available(dom = domestic)

  # check if download failed
  if (is.null(all_dates)) { return(invisible(NULL)) }

 # check dates
  check_date(date=date, all_dates)


if (nchar(date)==6) {
#### Download one month---------------------------------------------------------

# prepare address of online data
  # split date into month and year
  y <- substring(date, 1, 4)
  m <- substring(date, 5, 6)
  file_url <- get_airfares_url(dom = domestic, year=y, month=m)

# download and read data
  dt <- download_airfares_data(file_url, showProgress = showProgress, select = select)

  # check if download failed
  if (is.null(dt)) { return(invisible(NULL)) }

  return(dt)


} else if (nchar(date)==4) {
#### Download whole year---------------------------------------------------------

# prepare address of online data
all_months <- generate_all_months(date)

# ignore dates after max(all_dates)
all_months <- all_months[all_months <= max(all_dates)]

# set pbapply options
original_options <- pbapply::pboptions()
if( showProgress==FALSE){ pbapply::pboptions(type='none') }
if( showProgress==TRUE){ pbapply::pboptions(type='txt' ,char='=') }

# download data
dt_list <- pbapply::pblapply( X=all_months,
                   FUN= function(i, dom = domestic, showProgress.=FALSE, select.=select) { # i = all_months[3]

                      # prepare address of online data
                      # split date into month and year
                      y <- substring(i, 1, 4)
                      m <- substring(i, 5, 6)

                      file_url <- get_airfares_url(dom = domestic, year=y, month=m)

                      # download and read data
                      temp_dt <- download_airfares_data(file_url, showProgress = FALSE, select = select)

                      # check if download failed
                      if (is.null(temp_dt)) { return(invisible(NULL)) }
                      return(temp_dt)
                      }
                   )

# return to original pbapply options
pbapply::pboptions(original_options)

# row bind data tables
dt <- data.table::rbindlist(dt_list, fill=TRUE)
return(dt)

}}

