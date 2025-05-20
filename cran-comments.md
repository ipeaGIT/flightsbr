── R CMD check results ─────────────────────────────────────────────────────────────────────────────────────────────── flightsbr 1.1.0 ────
Duration: 4m 11.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


* CRAN policy:
  * updated DESCRIPTION file removing 'NeedsCompilation'
  * removed |> pipe to avoid depending on R >= 4.1.0
  * reduced package file size to aprox 1.7MB

* Major changes:
  * The default of all `read_` functions now is to download data from the latest date available.
  * The function `read_aircrafts()` is now deprecated in favor of `read_aircraft()` simply to fix a typo in the function name. The behavior and outputs are identical. Closes [#45](https://github.com/ipeaGIT/flightsbr/issues/45)

