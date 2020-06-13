
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku <img src="man/figures/logo.png" align="right" alt="santoku logo" width="120" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/hughjonesd/santoku.svg?branch=master)](https://travis-ci.org/hughjonesd/santoku)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/hughjonesd/santoku?branch=master&svg=true)](https://ci.appveyor.com/project/hughjonesd/santoku)
[![Codecov test
coverage](https://codecov.io/gh/hughjonesd/santoku/branch/master/graph/badge.svg)](https://codecov.io/gh/hughjonesd/santoku?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/santoku)](https://CRAN.R-project.org/package=santoku)
<!-- badges: end -->

santoku is a versatile cutting tool for R. It provides `chop()`, a
replacement for `base::cut()`.

## Advantages

Here are some advantages of santoku:

  - By default, `chop()` always covers the whole range of the data, so
    you won’t get unexpected `NA` values.

  - `chop()` can handle single values as well as intervals. For example,
    `chop(x, breaks = c(1, 2, 2, 3))` will create a separate factor
    level for values exactly equal to 2.

  - Flexible labelling, including easy ways to label intervals by
    numerals or letters.

  - Convenience functions for creating quantile intervals, evenly-spaced
    intervals or equal-sized groups.

  - Convenience functions for quickly tabulating chopped data.

These advantages make santoku especially useful for exploratory
analysis, where you may not know the range of your data in advance.

## Usage

``` r
library(santoku)

# chop returns a factor:
chop(1:10, c(3, 5, 7))
#>  [1] [1, 3)  [1, 3)  [3, 5)  [3, 5)  [5, 7)  [5, 7)  [7, 10] [7, 10] [7, 10]
#> [10] [7, 10]
#> Levels: [1, 3) [3, 5) [5, 7) [7, 10]

# exactly() creates its own category
# `labels` for integer data:
chop(1:10, c(3, exactly(5), 7), labels = lbl_discrete())
#>  [1] 1 - 2  1 - 2  3 - 4  3 - 4  5      6      7 - 10 7 - 10 7 - 10 7 - 10
#> Levels: 1 - 2 3 - 4 5 6 7 - 10

library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union
# chop dates by calendar month, then tabulate:
tab_width(Sys.Date() + 1:90, months(1), labels = lbl_discrete(fmt = "%d %b"))
#> x
#> 14 Jun - 13 Jul 14 Jul - 13 Aug 14 Aug - 13 Sep 
#>              30              31              29
```

For more information, see the
[vignette](https://hughjonesd.github.io/santoku/articles/santoku.html).
