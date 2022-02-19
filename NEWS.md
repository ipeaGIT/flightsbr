# flightsbr v0.1.09 (dev)

* Bug fixes:
  * functions `read_flights()` and `read_airport_movements()` no longer have side effects on objects named `month` and `year` on the global environment. The `split_date()` support function was removed from the package. [Closes #17](https://github.com/ipeaGIT/flightsbr/issues/17).
  * Using a simpler / slightly faster version of `latlon_to_numeric()` with suppressed warnings.


# flightsbr v0.1.0

* Major changes:
  * New function `read_aircrafts()` to read data on all aircrafts registered in the Brazilian Aeronautical Registry (Registro Aeronáutico Brasileiro - RAB) [Closes #14](https://github.com/ipeaGIT/flightsbr/issues/14).
  * New function `read_airports()` to read data on all public and private airports. [Closes #4](https://github.com/ipeaGIT/flightsbr/issues/4) and [Closes #9](https://github.com/ipeaGIT/flightsbr/issues/9).
  * New function `latest_flights_date()` to check the date of the latest flight data available. [Closes #16](https://github.com/ipeaGIT/flightsbr/issues/16).
  * New function `read_airport_movements()` to download data on airport movements. [Closes #15](https://github.com/ipeaGIT/flightsbr/issues/15).
  * Function `read_flights()` now takes `date` input in the format `yyyymm` or `yyyy`. When the date input is a 4-digit number, the function now downloads data of all months in that year. [Closes #1](https://github.com/ipeaGIT/flightsbr/issues/1).
  * Function `read_flights()` now automatically detects and checks the latest flights data available. [Closes #13](https://github.com/ipeaGIT/flightsbr/issues/13).
  * new internal support functions:
    * `split_date()`: Split a date from yyyymmm to year yyyy and month mm
    * `check_date()`: Check whether date input is acceptable
    * `generate_all_months()`: Generate all months with `yyyymm` format in a year
    * `latlon_to_numeric()`: Convert spatial coordinates of airports to lat lon
    * `get_flights_url()`: Put together the url of flight data files
    * `get_flight_dates_available()`: Retrieve from ANAC website all dates available for flights data
    * `download_flights_data()`: Download and read ANAC flight data
    * `get_airport_movements_url()`: Put together the url of airport movement data files
    * `get_airport_movement_dates_available()`: Retrieve all dates available for airport movements data
    * `download_airport_movement_data()`: Download and read ANAC airport movement data
  * Three separate vignettes. A general intro to the package, and more detailed vignettes on `read_flights` and `read_airports()`.

* Minor changes:
  * new parameter `select` in `read_flights()`, allowing the user to specify the columns that should be read.
  * new tests of `read_flights()`. Coverage of 95.24%. [Closes #5](https://github.com/ipeaGIT/flightsbr/issues/5).
  * New checks on `date` input. [Closes #2](https://github.com/ipeaGIT/flightsbr/issues/2).
  * Functions now should fail gracefully in case of problems with internet connection. [Closes #7](https://github.com/ipeaGIT/flightsbr/issues/7).



# flightsbr v0.0.1

* Launch of **flightsbr** v0.0.1 on CRAN https://cran.r-project.org/package=flightsbr
