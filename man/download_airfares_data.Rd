% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_airfares.R
\name{download_airfares_data}
\alias{download_airfares_data}
\title{Download and read ANAC air fares data}
\usage{
download_airfares_data(
  file_urls = parent.frame()$file_urls,
  showProgress = parent.frame()$showProgress,
  select = parent.frame()$select,
  cache = parent.frame()$cache
)
}
\arguments{
\item{file_urls}{String. A url passed from \code{\link{get_flights_url}}.}

\item{showProgress}{Logical. Defaults to \code{TRUE} display progress.}

\item{select}{A vector of column names or positions to keep. The rest of the
columns are not read. The order that the columns passed determines the
order of the columns in the result.}

\item{cache}{Logical. Whether the function should read cached data downloaded
previously. Defaults to \code{TRUE}. If \code{FALSE}, the function will
always download the data and overwrite cached data.}
}
\value{
A \verb{"data.table" "data.frame"} object
}
\description{
Download and read ANAC air fares data
}
\examples{
\dontrun{ if (interactive()) {
# Generate url
file_url <- get_airfares_url(dom = TRUE, date=200211)

# download data
a <- download_airfares_data(file_urls=file_url, showProgress=TRUE, select=NULL)
}}
}
\keyword{internal}
