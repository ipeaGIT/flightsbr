# log history of flightsbr package development

-------------------------------------------------------

# v0.1.0

* Major changes:
- New function `read_aircrafts()` to read data on all aircrafts registered in the Brazilian Aeronautical Registry (Registro Aeronáutico Brasileiro - RAB) [Closes #14](https://github.com/ipeaGIT/flightsbr/issues/14).
- New function `read_airports()` to read data on all public and private airports. [Closes #4](https://github.com/ipeaGIT/flightsbr/issues/4) and [Closes #9](https://github.com/ipeaGIT/flightsbr/issues/9).
- Function `read_flighs()` now takes `date` input in the format `yyyymm` or `yyyy`. The the date is a 4-digit number, the function now downloads the data of all months in that year. [Closes #2](https://github.com/ipeaGIT/flightsbr/issues/1).
- new internal support functions:
  - `split_date()`: Split a date from yyyymmm to year yyyy and month mm
  - `check_date()`: Check whether date input is acceptable
  - `generate_all_months()`: Generate all months with `yyyymm` format in a year
  - `get_url()`: Put together the data file url
  - `download_flights_data()`: Download and read ANAC flight data
- Three separate vignettes. A general intro to the package, and more detailed vignettes on `read_flighs` and `read_airports()`.

* Minor changes:
- new parameter `select` in `read_flighs()`, allowing the user to specify the columns that should be read.
- new tests of `read_flighs()`. Coverage of 95.24%. [Closes #5](https://github.com/ipeaGIT/flightsbr/issues/5).
- New checks on `date` input. [Closes #2](https://github.com/ipeaGIT/flightsbr/issues/2).
- Functions now should fail gracefully in case of problems with internet connection. [Closes #7](https://github.com/ipeaGIT/flightsbr/issues/7).


-------------------------------------------------------

# v0.0.1

* Launch of **flightsbr** v0.0.1 on CRAN https://cran.r-project.org/package=flightsbr
