% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bluewater_status.R
\name{bluewater_status}
\alias{bluewater_status}
\title{Status calculation of the bluewater boundary}
\usage{
bluewater_status(
  files_scenario,
  files_reference,
  spatial_scale,
  time_span_scenario = as.character(1982:2011),
  time_span_reference = time_span_scenario,
  approach = "gerten2020",
  time_series_avg = NULL,
  config_args = list(),
  thresholds = NULL,
  cut_min = 0.0864
)
}
\arguments{
\item{files_scenario}{list with variable names and corresponding file paths
(character string) of the scenario LPJmL run. Handled automatically via
\code{\link[=calc_status]{calc_status()}}.}

\item{files_reference}{list with variable names and corresponding file paths
(character string) of the files_reference LPJmL run. Handled automatically
via \code{\link[=calc_status]{calc_status()}}.}

\item{spatial_scale}{character string indicating spatial resolution
options: "global", "subglobal", "grid";
for "grid" the approach "gerten2020" is applicable based on EFR calculations;
for "global"/"subglobal" the share (\%) of total global/basin area with
deviations is calculated}

\item{time_span_scenario}{time span to use output from the scenario run,
e.g. \code{1982:2011}.}

\item{time_span_reference}{time span use output from the reference run,
e.g. \code{1901:1930}.}

\item{approach}{approach (character string) to be used , currently available
approach is \code{"gerten2020"} based on
\href{https://doi.org/10.1038/s41893-019-0465-1}{Gerten et al. 2020}
for spatial_scale = "grid" and
"wang_erlandsson2022" as well as "porkka2024" for
spatial_scale = "global" or "subglobal"}

\item{time_series_avg}{integer. Number of years to be used for the moving
average calculation. If \code{NULL}, all years are averaged for one status
calculation, for \code{1} the whole time span is used to calculate a status time
series.}

\item{config_args}{list of arguments to be passed on from the model
configuration.}

\item{thresholds}{named character string with thresholds to be used to
define the safe, increasing risk and high risk zone, the approach and scale
specific default thresholds are defined in metric_files.yml are are applied
if thresholds are set to NULL.}

\item{cut_min}{double. Exclude boundary calculations for discharge < cut_min
and dismiss EFR transgresssions if < cut_min for "gerten2020" approach,
Default: 0.0864 hm3/day (=1 m3/s)}
}
\value{
Object of class \code{control_variable} with the boundary status of the
bluewater boundary.
}
\description{
Planetary Boundary status calculation of the bluewater boundary (as part of
the freshwater boundary) based on a scenario LPJmL run and a reference LPJmL
run.
}
\examples{
\dontrun{
boundary_status <- calc_status(
  boundary = "bluewater",
  config_scenario = "path/to/config_scenario.json",
  config_reference = "path/to/config_reference.json",
  spatial_scale = "global",
  time_span_scenario = 1901:2019,
  time_span_reference = 1901:1930,
  approach = "porkka2024"
)
}

}
