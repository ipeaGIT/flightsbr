## R CMD check results

── R CMD check results ────────────────────────────────────────────────────────────────────────── flightsbr 0.3.0 ────
Duration: 4m 14.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


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
