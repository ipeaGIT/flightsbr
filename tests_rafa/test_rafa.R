# devtools::install_github("ipeaGIT/r5r", subdir = "r-package", force=T)





##### ASCII characters  ------------------------



# I find ?stringi::stri_escape_unicode to be extremely useful for generating \uxxxx escapes, for example:

# stringi::stri_escape_unicode("°") |> cat("\n")
\u00b0

Which can be reversed (for checking) using:

# stringi::stri_unescape_unicode("\u00b0") |> cat("\n")
# °
# stringi::stri_unescape_unicode("\ub0") |> cat("\n")


This also works with non-ASCII characters embedded in longer sentences:

  # > stringi::stri_escape_unicode("Åv — mærkelige tegn!") |> cat("\n")
\u00c5v \u2014 m\u00e6rkelige tegn!

  # > stringi::stri_unescape_unicode("\u00c5v \u2014 m\u00e6rkelige tegn!") |> cat("\n")
Åv — mærkelige tegn!

  Big thanks to the authors of the stringi package if they are reading this!


##### Coverage ------------------------
library(flightsbr)
library(testthat)
library(covr)
Sys.setenv(NOT_CRAN = "true")


# each function separately
covr::function_coverage(fun=read_airports, test_file("tests/testthat/test_read_airports.R"))
covr::function_coverage(fun=read_flights, test_file("tests/testthat/test_read_flights.R"))


# nocov start

# nocov end

# the whole package
Sys.setenv(NOT_CRAN = "true")
cov <- covr::package_coverage(path = ".", type = "tests")
cov


x <- as.data.frame(cov)
covr::codecov( coverage = cov, token ='aaaaa' )


##### check ftp dirs and files ------------------------

library(RCurl)

url <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/evolucao_da_divisao_territorial_do_brasil/evolucao_da_divisao_territorial_do_brasil_1872_2010/municipios_1872_1991/divisao_territorial_1872_1991/"

url <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/basica2020-01.zip'
url <- 'https://www.gov.br/anac/pt-br/assuntos/regulados/empresas-aereas/envio-de-informacoes/microdados/'


# List Years/folders available


filenames = getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)


dir_list <-
  read.table(
    textConnection(
      getURLContent(url)
    ),
    # sep = "",
    strip.white = TRUE)
dir_list


##### Profiling function ------------------------
# p <-   profvis( update_newstoptimes("T2-1@1#2146") )
#
# p <-   profvis( b <- corefun("T2-1") )





# checks spelling
library(spelling)
devtools::spell_check(pkg = ".", vignettes = TRUE, use_wordlist = TRUE)

# Update documentation
devtools::document(pkg = ".")


# Write package manual.pdf
system("R CMD Rd2pdf --title=Package gtfs2gps --output=./gtfs2gps/manual.pdf")
# system("R CMD Rd2pdf gtfs2gps")




### CMD Check ----------------
# Check package errors

# LOCAL
Sys.setenv(NOT_CRAN = "true")
devtools::check(pkg = ".",  cran = FALSE, env_vars = c(NOT_CRAN = "true"))

# CRAN
Sys.setenv(NOT_CRAN = "false")
devtools::check(pkg = ".",  cran = TRUE, env_vars = c(NOT_CRAN = "false"))

devtools::check_win_release(pkg = ".")

# devtools::check_win_oldrelease()
# devtools::check_win_devel()


beepr::beep()



tictoc::tic()
devtools::check(pkg = ".",  cran = TRUE, env_vars = c(NOT_CRAN = "false"))
tictoc::toc()





# build binary -----------------
system("R CMD build . --resave-data") # build tar.gz



pu <- names(dt_public) |> tolower()
pr <- names(dt_private)  |> tolower()

dt_public$OPERAÇÃO
dt_private$`Operação Noturna`

pu[pu %in% pr]

