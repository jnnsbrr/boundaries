#' List required LPJmL outputs and temporal resolution
#'
#' Function to return a list of output IDs with required resolution and
#' file names for a given metric. The list is based on the metric_files.yml file
#' in the boundaries package (`"./inst/metric_files.yml"`).
#'
#' @param metric Character string containing name of metric to get
#'        required outputs. Available options are `c("biome",
#'        "nitrogen", "lsc", "bluewater", "greenwater", "biosphere")`
#'        or just `"all"` or `"benchmark"`. Default is `"all"`.
#'
#' @param approach List of character strings containing the approach to
#'       calculate the metric. Or `"all"` to get all approaches (default).
#'
#' @param spatial_scale character. Spatial resolution, available options
#'        are `"subglobal"` (at the biome level), `"global"` and
#'        `"grid"` or `"all"` (default).
#'
#' @param only_first_filename Logical. If TRUE, only the first file name will be
#'        returned for each output. If FALSE, all file names will be returned.
#'
#' @return List of output IDs with required resolution and
#'         file names for a given metric
#'
#' @examples
#' \dontrun{
#' list_outputs(
#'   "biome",
#'   approach = list("biome" = approach),
#'   spatial_scale = "subglobal",
#'   only_first_filename = FALSE
#' )
#' }
#' @export
list_outputs <- function(
  metric = "all",
  spatial_scale = "all",
  approach = "all",
  only_first_filename = TRUE
) {
  metric <- process_metric(metric = metric)

  system.file(
    "extdata",
    "metric_files.yml",
    package = "boundaries"
  ) %>%
    yaml::read_yaml() %>%
    get_outputs(metric, spatial_scale, approach, only_first_filename)

}

# List arguments of functions used in metrics from metric_files.yml
list_function_args <- function(metric = "all") {

  metric <- process_metric(metric = metric)
  system.file(
    "extdata",
    "metric_files.yml",
    package = "boundaries"
  ) %>%
    yaml::read_yaml() %>%
    get_function_args(metric)

}

# Translate metric options into internal metric names
process_metric <- function(metric = "all") {
  all_metrics <- c(
    "biome", "nitrogen", "lsc",
    "bluewater", "greenwater", "biosphere", "benchmark"
  )

  if ("all" %in% metric) {
    metric <- all_metrics
  }

  metric <- match.arg(
    arg = metric,
    choices = all_metrics,
    several.ok = TRUE
  )

  metric
}


# for input list a, all duplicate keys are unified, taking the value with
#     highest temporal resolution (daily>monthly>annual)
get_outputs <- function( # nolint
  x,
  metric_name,
  spatial_scale,
  approach,
  only_first_filename
) {
  outputs <- list()

  # Iterate over all metrics
  for (metric_string in names(x$metric[metric_name])) {
    metric <- x$metric[[metric_string]]

    # Iterate over all spatial scales
    for (scale_string in names(metric$spatial_scale)) { #nolint
      # Check if spatial scale is defined or all scales
      if (spatial_scale != "all" && !scale_string %in% spatial_scale) {
        next
      }
      scale <- metric$spatial_scale[[scale_string]]

      # Iterate over all approaches
      for (method_string in names(scale)) {
        # Check if approach is in list or all approaches
        if (all(approach != "all") && !is.null(approach[[metric_string]]) &&
              method_string != approach[[metric_string]]) { # nolint
          next
        }
        method <- scale[[method_string]]

        # Iterate over all outputs
        for (item in names(method$output)) {
          # Check if output is already in list or if it has higher resolution
          if (!item %in% names(outputs) ||
              (item %in% names(outputs) &&
                 higher_res(metric$output[[item]]$resolution,
                            outputs[[item]]$resolution))
          ) {
            # Assign output resolution from metric file
            outputs[[item]]$resolution <- method$output[[item]]$resolution #nolint
            outputs[[item]]$optional <- method$output[[item]]$optional #nolint
            # Assign output file name from metric file
            if (only_first_filename) {
              outputs[[item]]$file_name <- x$file_name[[item]][1]
            } else {
              outputs[[item]]$file_name <- x$file_name[[item]]
            }
          }
        }
      }
    }
  }
  outputs
}


# Get arguments of functions used in metrics
get_function_args <- function(x, metric_name) {
  # List functions of metrics (metric_name)
  funs <- list()

  for (metric in x$metric[metric_name]) {
    funs[[metric$fun_name]] <- metric$funs
  }

  # Get arguments of functions
  funs %>%
    lapply(function(x) {
      unlist(
        lapply(mget(x, inherits = TRUE), methods::formalArgs),
        use.names = FALSE
      )
    })
}


# Check if resolution of x is higher than resolution of y
higher_res <- function(x, y) {
  levels <- c("annual", "monthly", "daily")
  resolution_x <- match(match.arg(x, levels), levels)
  resolution_y <- match(match.arg(y, levels), levels)

  if (resolution_x > resolution_y) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

list_thresholds <- function(metric, approach, spatial_scale) {
  metric <- process_metric(metric = metric)

  yaml_data <- system.file(
    "extdata",
    "metric_files.yml",
    package = "boundaries"
  ) %>%
    yaml::read_yaml()

  return(yaml_data$metric[[metric]]$spatial_scale[[spatial_scale]][[approach]]$threshold) # nolint:line_length_linter

}

list_unit <- function(metric, approach, spatial_scale) {
  metric <- process_metric(metric = metric)

  yaml_data <- system.file(
    "extdata",
    "metric_files.yml",
    package = "boundaries"
  ) %>%
    yaml::read_yaml()

  return(yaml_data$metric[[metric]]$spatial_scale[[spatial_scale]][[approach]]$unit) # nolint:line_length_linter

}

list_long_name <- function(metric) {
  metric <- process_metric(metric = metric)

  yaml_data <- system.file(
    "extdata",
    "metric_files.yml",
    package = "boundaries"
  ) %>%
    yaml::read_yaml()

  return(yaml_data$metric[[metric]]$long_name)

}
