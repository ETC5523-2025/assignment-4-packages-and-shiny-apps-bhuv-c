#' Rpackage
#'
#' The dataset contains Disability-Adjusted Life Years (DALYs) per 100,000 population
#' for five major healthcare-associated infections — HAP, SSI, BSI, UTI, and CDI —
#' across two surveillance studies: the German PPS and the ECDC PPS (EU/EEA).
#'
#' Each infection’s burden is represented by two DALY components:
#' \itemize{
#'   \item \strong{YLD (Years Lived with Disability)} – measures morbidity or time lived in less than full health.
#'   \item \strong{YLL (Years of Life Lost)} – measures premature mortality due to infection.
#' }
#'
#' The dataset supports analysis and visualisation of infection burden
#' across surveillance regions, including uncertainty through standard error values.
#'
#' @format
#' A tibble with 20 rows and 5 variables:
#' \describe{
#'   \item{\code{group}}{Surveillance study — either "German PPS" or "ECDC PPS".}
#'   \item{\code{category}}{Infection type:
#'   HAP (Hospital-acquired pneumonia),
#'   SSI (Surgical site infection),
#'   BSI (Bloodstream infection),
#'   UTI (Urinary tract infection),
#'   CDI (\emph{Clostridioides difficile} infection).}
#'   \item{\code{component}}{DALY component — "YLD" (Years Lived with Disability) or "YLL" (Years of Life Lost).}
#'   \item{\code{value}}{DALYs per 100,000 population for that infection and component.}
#'   \item{\code{se}}{Standard error for the total DALY estimate (used for uncertainty/error bars).}
#' }
#'
#' @source Adapted from Zacher, B. et al. (2019), *Estimates of the burden of healthcare-associated infections in Germany based on a population survey*, PLOS Medicine.
#' \url{https://cwd.numbat.space/assignments/assignment-2-papers/Zacher2019.pdf}
#'
#' @examples
#' data("Data", package = "Rpackage")
#' head(Data)
"Data"

