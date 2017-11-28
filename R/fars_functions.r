#' Return a data frame representing the data in the csv file pointed to by the \code{filename} given as input.
#'
#' @param filename A character vector representing the filename of a csv file to be read in.
#'
#' @return A data frame representing the data from the \code{filename} given as input.
#'
#' @note The \code{filename} must exist or an error is raised.
#'
#' @importFrom readr "read_csv"
#' @importFrom dplyr "tbl_df"
#'
#' @examples
#' \dontrun{
#' fars_read("accident_2015.csv.bz2")
#' }
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}


#' Given a \code{year} as input return the FARS filename containing data for that year.
#'
#' @param year A value that can be coerced to an integer and that represents a year.
#'
#' @return A character vector that is the filename of the FARS file containing data for the \code{year} given as input.
#'
#' @note The input variable \code{year} must be castable to an integer or it will be coerced to NA.
#'
#' @examples
#' \dontrun{
#' make_filename(2015)
#' make_filename("2014")
#' }
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}


#' Given a list or vector of years, return the month/year combinations for all observations in the FARS
#' data belonging to the given years.
#'
#' @param years A list or vector of values that can be coerced to integers and that each represents a year.
#'
#' @return A list of tibbles, one tibble for each year in \code{years}, which each contains the month/year
#'         combination for each observation in the FARS files for the given \code{years}.
#'
#' @importFrom dplyr "%>%","mutate","select"
#'
#' @note The elements in \code{years} must be castable to integers.
#'
#' @examples
#' \dontrun{
#' fars_read_years(list(2014))
#' fars_read_years(list("2013",2014,2015))
#' }
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}


#' Given a list or vector of years, return the number of observations in the FARS data for all the given years and
#' the months in these years.
#'
#' @param years A list or vector of values that can be coerced to integers and that each represents a year.
#'
#' @return A tibble containing the number of observations in the FARS data for the given \code{years} at a month granularity.
#'
#' @export
#'
#' @importFrom dplyr "bind_rows","group_by","summarize"
#' @importFrom tidyr "spread"
#'
#' @note The elements in \code{years} must be castable to integers.
#'
#' @examples
#' \dontrun{
#' fars_summarize_years(list(2014))
#' fars_summarize_years(list(2013,2014,2015))
#' }
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}


#' Given a number representing a US State and a value representing a year, this function
#' extracts the FARS data for the given State at the given year, removes non-sensical
#' observations (where longitude > 900 or latitude > 90) and plots all the remaining
#' observations on a map.
#'
#' @param state.num A value convertible to an integer, which represents the US State for
#'                  which to extract FARS data.
#' @param year A value convertible to an integer, which represents the year for which
#'             to extract FARS data.
#'
#' @return No return value, but has the side effect of plotting the FARS observations for
#'         the given US State (\code{state.num}) at the given \code{year} on a map.
#'
#' @export
#'
#' @importFrom dplyr "filter"
#' @importFrom maps "map"
#' @importFrom graphics "points"
#'
#' @note \code{state.num} and \code{year} must both be castable to integers.
#'
#' @examples
#' \dontrun{
#' fars_map_state(4, 2015)
#' }
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
