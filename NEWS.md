# flightsbr dev v0.5.099999 dev


* Breaking changes:
  * The names of all columns in the data outputs are now cleanned with {janitor}
  * Function `read_airports()` now downloads v2 version of public airports data. Closes [#41](https://github.com/ipeaGIT/flightsbr/issues/41)

* Major changes:
  * Function `read_airfares()` is working again. Closes [#30](https://github.com/ipeaGIT/flightsbr/issues/30)
  * Function `read_flights()` with fixed decimal values in numeric columns. Closes [#43](https://github.com/ipeaGIT/flightsbr/issues/43)
  * Function `read_airports()` with fixed values for `"altitude"` column. Closes [#42](https://github.com/ipeaGIT/flightsbr/issues/42)
    
* Minor changes:
  * Internally check of the consistency of date inputs. The date input must be consistent in either a 6-digit format `yyyymm` OR a 4-digit format `yyyy`.
  * New support function `latest_airfares_date()`
  Fix error that stopped reading aircraft data `read_aircrafts()` for multiple months when the number of collums differed across months. Fixed using `data.table::rbindlist(fill = TRUE)`



# flightsbr dev v0.5.0

* Major changes:
  * Fixed ANAC's broken link of public airports
  * Functions `read_flights()`, `read_airport_movements()`, and `read_aircrafts()` now accept vectors of dates like `c(202201, 202301)` or `c(2022, 2024)`
  * Functions `read_airports()` and `read_aircrafts()` now has a `cache` parameter.
  * The package is now significantly faster because it is using `curl::multi_download()` to download files in parallel. This brings the advantage that the package now automatically detects whether the data file has been updated and should be downloaded again.

* Minor changes:
  * Removed dependency on the {httr} package
  * Streamlined functions to simplify package maintenance and improve performance
  * Using {fs} to manage file paths and {archive} to unzip files
  * Reorganization of internal functions to simplify package maintenance
  




# flightsbr v0.4.1

* Minor changes:
  * The `read_flights()` function now uses `fread(encoding = 'Latin-1')` internally to avoid issues with encoding. Closed #35.
  * The function `get_airport_movement_dates_available()` does not throw warnings of `NA` values anymore.
  * The `read_aircrafts()` function now used `fread(skip = 1)` internally to read column names correctly.


# flightsbr v0.4.0

* Major changes:
  * The functions `read_flights()` and `read_airport_movements()` now have a new parameter `cache`, which indicates whether the function should read cached data downloaded previously. Defaults to `TRUE`. Closed #31.
  * The function `read_aircrafts()` now has a `date` parameter, which allows one to download the data on aircrafts registered at ANAC at particular years/months.  Closed #33.

* Minor changes:
  * All functions now return numeric columns with `numeric` class. Closed #32.

* Bug fixes:
  * Fixed bug when unzipping files for `read_flights()` function in Unix systems. 
  Closed #31.
   * Updated link to private airports data changed by ANAC. Closed #34.

# flightsbr v0.3.0

* Major changes:
  * Function read_airfares() is temporarily  unavailable. See issue [#30](https://github.com/ipeaGIT/flightsbr/issues/30) 

* Minor changes:
  * Function `read_flights()` now accepts a vector of dates. Closed #29.

* Bug fixes:
  * Fixed broken link for data dictionary for airport movement data
  * Fixed code to rbindlist air fares from multiple years. Closed #26.
  * Fixed code to read a few dates that were not caught in `get_airfares_dates_available()` because of ".CSV" in ANAC url. Closed #27.
  * Fixed code to use `get_airport_movement_dates_available()`



# flightsbr v0.2.1

* Bug fixes:
  * Fixed bug in `read_flights()` due to changes in ANAC data links.
  * Fixed broken link in `intro_flightsbr` vignette


# flightsbr v0.2.0

* Major changes:
  * Update urls to new location where flights data is stored. This makes `read_flights()` work again.
  * New function `read_airfares()` to read data on airfares of domestic and international flights [Closed #22](https://github.com/ipeaGIT/flightsbr/issues/22).

* Minor changes:
  * The data downloaded in `read_flights()` and `read_airport_movements()` are now cached in temp dir. Closed [#20](https://github.com/ipeaGIT/flightsbr/issues/21).
  * All columns are now returned with class `character`. This fixes a bug in the `read_airport_movements()` function. Closed [#20](https://github.com/ipeaGIT/flightsbr/issues/20).



# flightsbr v0.1.2

* Bug fixes:
  * Fixed bug that stopped flightsbr from downloading 2022 data.



# flightsbr v0.1.1

* Bug fixes:
  * functions `read_flights()` and `read_airport_movements()` no longer have side effects on objects named `month` and `year` on the global environment. The `split_date()` support function was removed from the package. [Closed #17](https://github.com/ipeaGIT/flightsbr/issues/17).
  * `read_` functions now try to download for a 2nd time if the 1st attempt failed. This will help overcome a small issue with the instability of ANAC data links. [Closed #18](https://github.com/ipeaGIT/flightsbr/issues/18).
  * Using a simpler / slightly faster version of `latlon_to_numeric()` with suppressed warnings.
  * Update package citation, adding OSF preprint DOI.


# flightsbr v0.1.0

* Major changes:
  * New function `read_aircrafts()` to read data on all aircrafts registered in the Brazilian Aeronautical Registry (Registro Aeronáutico Brasileiro - RAB) [Closed #14](https://github.com/ipeaGIT/flightsbr/issues/14).
  * New function `read_airports()` to read data on all public and private airports. [Closed #4](https://github.com/ipeaGIT/flightsbr/issues/4) and [Closed #9](https://github.com/ipeaGIT/flightsbr/issues/9).
  * New function `latest_flights_date()` to check the date of the latest flight data available. [Closed #16](https://github.com/ipeaGIT/flightsbr/issues/16).
  * New function `read_airport_movements()` to download data on airport movements. [Closed #15](https://github.com/ipeaGIT/flightsbr/issues/15).
  * Function `read_flights()` now takes `date` input in the format `yyyymm` or `yyyy`. When the date input is a 4-digit number, the function now downloads data of all months in that year. [Closed #1](https://github.com/ipeaGIT/flightsbr/issues/1).
  * Function `read_flights()` now automatically detects and checks the latest flights data available. [Closed #13](https://github.com/ipeaGIT/flightsbr/issues/13).
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
  * new tests of `read_flights()`. Coverage of 95.24%. [Closed #5](https://github.com/ipeaGIT/flightsbr/issues/5).
  * New checks on `date` input. [Closed #2](https://github.com/ipeaGIT/flightsbr/issues/2).
  * Functions now should fail gracefully in case of problems with internet connection. [Closed #7](https://github.com/ipeaGIT/flightsbr/issues/7).



# flightsbr v0.0.1

* Launch of **flightsbr** v0.0.1 on CRAN https://cran.r-project.org/package=flightsbr
