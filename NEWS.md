# log history of flightsbr package development

-------------------------------------------------------

# v0.1.0

* Major changes:
- Function `read_flighs()` now takes `date` input in the format `yyyymm` or `yyyy`. The the date is a 4-digit number, the function now downloads the data of all months in that year. [Closes #2](https://github.com/ipeaGIT/flightsbr/issues/1).
- new internal support functions:
  - `split_date()`: Split a date from yyyymmm to year yyyy and month mm
  - `check_date()`: Check whether date input is acceptable
  - `generate_all_months()`: Generate all months with `yyyymm` format in a year
  - `get_url()`: Put together the data file url
  - `download_flights_data()`: Download and read ANAC flight data

* Minor changes:
- new parameter `select` in `read_flighs()`, allowing the user to specify the columns that should be read.
- new tests of `read_flighs()`. Coverage of 95.24%. [Closes #5](https://github.com/ipeaGIT/flightsbr/issues/5).
- New checks on `date` input. [Closes #2](https://github.com/ipeaGIT/flightsbr/issues/2).


-------------------------------------------------------

# v0.0.1

* Launch of **flightsbr** v0.0.1 on CRAN https://cran.r-project.org/package=flightsbr
