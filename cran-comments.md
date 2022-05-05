## R CMD check results

-- R CMD check results ----------------------------------------------------------- flightsbr 0.2.0 ----
Duration: 4m 30.5s

0 errors √ | 0 warnings √ | 0 notes √


## flightsbr v0.2.0

* Major changes:
  * Update urls to new location where flights data is stored. This makes `read_flights()` work again.
  * New function `read_airfares()` to read data on air fares of domestic and international flights [Closed #22](https://github.com/ipeaGIT/flightsbr/issues/22).

* Minor changes:
  * The data downloaded in `read_flights()` and `read_airport_movements()` are now cached in temp dir. Closed [#20](https://github.com/ipeaGIT/flightsbr/issues/21).
  * All columns are now returned with class `character`. This fixes a bug in the `read_airport_movements()` function. Closed [#20](https://github.com/ipeaGIT/flightsbr/issues/20).
