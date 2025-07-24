context("utils support functions")

# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()


test_that("check_date", {

  testthat::succeed( check_date(1, 1:10) )
  testthat::expect_error( check_date(1, 2:10) )

})


test_that("generate_all_months", {

  testthat::expect_true(
    all(generate_all_months(2010) == 201001:201012)
    )

  testthat::expect_error( generate_all_months(1) )

})


test_that("generate_all_months", {

  testthat::succeed(
    check_input_date_format(201001)
  )

  testthat::succeed(
    check_input_date_format(2010)
  )

  testthat::expect_error(
    check_input_date_format(20100101)
  )
  testthat::expect_error(
    check_input_date_format(1)
  )
})


