* Bug fixes
  - The functions `read_flights()` and `read_airport_movements()` no longer have side effects on objects named month and year on the global environment. The split_date() support function was removed from the package.
  - Using a simpler / slightly faster version of latlon_to_numeric() with suppressed warnings.


## R CMD check results

-- R CMD check results ---------------------------------------------- flightsbr 0.1.1 ----
Duration: 3m 21.8s

0 errors √ | 0 warnings √ | 0 notes √

* This is a bug fix release.
