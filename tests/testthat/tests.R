library(testthat)

expect_that(fars_read("i_do_not_exist"), throws_error())
expect_that(fars_read("accident_2013.csv.bz2"), is_a("tbl_df"))

expect_that(make_filename(2014), equals("accident_2014.csv.bz2"))
expect_that(make_filename("2014"), equals("accident_2014.csv.bz2"))
expect_that(make_filename("foobar"), gives_warning())

expect_that(fars_summarize_years(2014), is_a("tbl_df"))
expect_that(fars_summarize_years(list(2014,2015)), is_a("tbl_df"))
expect_that(colnames(fars_summarize_years(list(2014,2015))), equals(c("MONTH", "2014", "2015")))
