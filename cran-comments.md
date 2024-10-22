── R CMD check results ────────────────────────────── flightsbr 1.0.0 ────
Duration: 8m 26.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔




* All urls are working on the browser

# flightsbr dev v1.0.0

* Major changes:
  * Fixed ANAC's broken link of public airports
  * Functions `read_flights()`, `read_airport_movements()`, and `read_aircrafts()` now accept vectors of dates like `c(202201, 202301)` or `c(2022, 2024)`
  * Functions `read_airports()` and `read_aircrafts()` now has a `cache` parameter.

* Minor changes:
  * Removed dependency on the {httr} package
  * Now using curl::multi_download() to download files in parallel. This brings the advantage that the pacakge now automatically detects whether the data file has been updated and should be downloaded again.
  * Streamlined functions to simplify package maintenance and improve performance
  * Using {fs} to manage file paths and {archive} to unzip files
  * Reorganization of internal functions to simplify package maintenance
  
