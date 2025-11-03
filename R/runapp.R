#' Launch the packaged Shiny app
#'
#' Opens the example DALY dashboard bundled in \code{inst/app}.
#' Packages needed: shiny (and the app’s other suggested packages).
#'
#' @export
#' @examples
#' \dontrun{
#'   run_app()
#' }
run_app <- function() {
  # check required runtime deps
  need <- c("shiny", "bslib", "ggplot2", "dplyr", "tidyr", "plotly", "DT")
  miss <- need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss)) {
    stop("Please install required packages: ", paste(miss, collapse = ", "), call. = FALSE)
  }

  app_dir <- system.file("app", package = utils::packageName())
  if (app_dir == "" || !dir.exists(app_dir)) {
    stop("Could not find app directory in this package (inst/app).", call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}

