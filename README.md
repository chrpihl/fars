<!-- README.md is generated from README.Rmd. Please edit that file -->
Travis build status
===================

![Travis build status](https://travis-ci.org/chrpihl/fars.svg?branch=master)

fars
====

The FARS data analyzer package contains functions for exploring data from the US National Highway Traffic Safety Administration's "Fatality Analysis Reporting System". The package includes data from the years 2013, 2014 and 2015, but data from other years can also be imported using the package as long as the data format stays the same.

Example
-------

The FARS data for years 2013, 2014 and 2015 is included in three separate files located in the "data" subfolder of the package. Simply copy the data to the working directory to allow the functions in the package to use them.

The following example shows how to use the package to get an overview of the number of observations in the FARS data for years 2014 and 2015 on a granunlarity of a month (make sure to copy the FARS data files to the working directory before running the example):

``` r
library(fars)
fars_summarize_years(list(2014,2015))
#> # A tibble: 12 x 3
#>    MONTH `2014` `2015`
#>  * <int>  <int>  <int>
#>  1     1   2168   2368
#>  2     2   1893   1968
#>  3     3   2245   2385
#>  4     4   2308   2430
#>  5     5   2596   2847
#>  6     6   2583   2765
#>  7     7   2696   2998
#>  8     8   2800   3016
#>  9     9   2618   2865
#> 10    10   2831   3019
#> 11    11   2714   2724
#> 12    12   2604   2781
```

The next example shows how to use the package to plot all observations from the FARS data for a given year and a particular US State number (make sure to copy the FARS data files to the working directory before running the example). Here we choose to plot the observations for year 2014 and state number 5:

``` r
library(fars)
fars_map_state(4, 2015)
#> Warning: package 'bindrcpp' was built under R version 3.3.3
```

![](README-example%20plot-1.png)
