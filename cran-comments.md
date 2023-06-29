## R CMD check results

── R CMD check results ──────────────────────────────────────────────────────────────── flightsbr 0.2.1 ────
Duration: 3m 21.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


## flightsbr v0.3.0

* Major changes:
  * Function read_airfares() is temporarily  unavailable. See issue [#30](https://github.com/ipeaGIT/flightsbr/issues/30) 

* Minor changes:
  * Function `read_flights()` now accepts a vector of dates. Closed #29.

* Bug fixes:
  * Fixed broken link for data dictionary for airport movement data
  * Fixed code to rbindlist air fares from multiple years. Closed #26.
  * Fixed code to read a few dates that were not caught in `get_airfares_dates_available()` because of ".CSV" in ANAC url. Closed #27.
  * Fixed code to use `get_airport_movement_dates_available()`
