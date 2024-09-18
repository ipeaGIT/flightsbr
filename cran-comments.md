── R CMD check results ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────── flightsbr 0.5.0 ────
Duration: 1m 28.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔



* Thumbs.db file removed
* All urls are working on the browser
* url moved to langua-specifc url to avoid 301 warning

# flightsbr dev v0.5.0

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
  
