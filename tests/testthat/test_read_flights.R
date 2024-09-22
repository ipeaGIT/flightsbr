context("read_flights")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


# Reading the data -----------------------
cols <- c('nr_ano_referencia' , 'nr_mes_referencia')

test_that("read_flights", {

  # (default), one month, basica, progress
  test1 <- read_flights()
  testthat::expect_true(is(test1, "data.table"))
  testthat::expect_true(nrow(test1) >0 )
  testthat::expect_equal( class(test1$nr_voo), 'numeric')

  # one month, combinada, no progress bar
  test2 <- read_flights(date=202201, type='combinada', showProgress = FALSE)
  testthat::expect_true(is(test2, "data.table"))
  testthat::expect_true(nrow(test2) >0 )

  # check content
  testthat::expect_equal( as.character(min(test2$dt_referencia)), as.character("2022-01-01") )

  # all months in a year
  test3 <- read_flights(date=2022, select=cols, showProgress = FALSE, cache = TRUE)
  testthat::expect_true(is(test3, "data.table"))
  testthat::expect_true(nrow(test3) >0 )

  # a vector of dates
  test4 <- read_flights(date = c(202001, 202003), select=cols, showProgress = FALSE)
  testthat::expect_true(is(test4, "data.table"))
  testthat::expect_true(nrow(test4) >0 )
  months <- unique(test4$nr_mes_referencia)
  testthat::expect_true( all.equal(months , c(1,3)) )

  # check whether cache argument is working
  time_first <- system.time(
    f201506 <- read_flights(date = 201506))

  time_cache_true <- system.time(
    f201506 <- read_flights(date = 201506, cache = TRUE))

  time_cache_false <- system.time(
    f201506 <- read_flights(date = 201506, cache = FALSE))

  testthat::expect_true( time_cache_true[['elapsed']] < time_cache_false[['elapsed']] )
 })


# ERRORS and messages  -----------------------
test_that("read_flights", {

  # Wrong date 4 digits
  testthat::expect_error(read_flights(date=1990))
  testthat::expect_error(read_flights(date=9999))

  # Wrong date 6 digits
  testthat::expect_error(read_flights(date=199001))
  testthat::expect_error(read_flights(date=999901))

  # mixed date format
  testthat::expect_error(read_flights(date=c(2020, 202101)))

  # Wrong type and showProgress
  testthat::expect_error(read_flights(type='banana'))
  testthat::expect_error(read_flights(showProgress='banana'))
  testthat::expect_error(read_flights(cache='banana'))
  testthat::expect_warning(read_flights(select='banana'))
})
