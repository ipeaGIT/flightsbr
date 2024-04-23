── R CMD check results ────────────────────────────────── flightsbr 0.4.1 ────
Duration: 7m 21.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


# flightsbr v0.4.1

* Minor changes:
  * The `read_flights()` function now uses `fread(encoding = 'Latin-1')` internally to avoid issues with encoding. Closed #35.
  * The function `get_airport_movement_dates_available()` does not throw warnings of `NA` values anymore.
  * The `read_aircrafts()` function now used `fread(skip = 1)` internally to read column names correctly.

