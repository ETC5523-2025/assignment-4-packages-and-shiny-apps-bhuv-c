#' DALY infection-burden dataset
#'
#' The dataset contains Disability-Adjusted Life Years (DALYs) per 100,000 for
#' five healthcare-associated infections — HAP, SSI, BSI, UTI, and CDI —
#' across two surveillance studies: German PPS and ECDC PPS (EU/EEA).
#'
#' Each infection’s burden is split into:
#' \itemize{
#'   \item \strong{YLD} — Years Lived with Disability
#'   \item \strong{YLL} — Years of Life Lost
#' }
#'
#' @format A tibble with 20 rows and 5 variables:
#' \describe{
#'   \item{\code{group}}{Surveillance study: "German PPS" or "ECDC PPS".}
#'   \item{\code{category}}{Infection type: HAP, SSI, BSI, UTI, CDI.}
#'   \item{\code{component}}{DALY component: "YLD" or "YLL".}
#'   \item{\code{value}}{DALYs per 100,000 population.}
#'   \item{\code{se}}{Standard error for the total DALY estimate (for error bars).}
#' }
#'
#' @source Zacher et al. (2019),
#' \url{https://cwd.numbat.space/assignments/assignment-2-papers/Zacher2019.pdf}
#'
#' @name Data
#' @docType data
#' @usage data(Data)
#' @keywords datasets
NULL
