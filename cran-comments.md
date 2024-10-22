── R CMD check results ────────────────────────────── flightsbr 1.0.0 ────
Duration: 8m 26.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔




* All urls are working on the browser

# flightsbr dev v1.0.0

* Breaking changes:
  * The names of all columns in the data outputs are now cleanned with {janitor}
  * Function `read_airports()` now downloads v2 version of public airports data. Closes [#41](https://github.com/ipeaGIT/flightsbr/issues/41)

* Major changes:
  * Function `read_airfares()` is working again. Closes [#30](https://github.com/ipeaGIT/flightsbr/issues/30). The prices of air tickets are now returned as numeric.
  * Function `read_flights()` with fixed decimal values in numeric columns. Closes [#43](https://github.com/ipeaGIT/flightsbr/issues/43)
  * Function `read_airports()` with fixed numeric values for `"altitude"` column. Closes [#42](https://github.com/ipeaGIT/flightsbr/issues/42)
    
* Minor changes:
  * Internally check of the consistency of date inputs. The date input must be consistent in either a 6-digit format `yyyymm` OR a 4-digit format `yyyy`.
  * New support function `latest_airfares_date()`
  * Fix error that stopped reading aircraft data `read_aircrafts()` for multiple months when the number of collums differed across months. Fixed using `data.table::rbindlist(fill = TRUE)`

