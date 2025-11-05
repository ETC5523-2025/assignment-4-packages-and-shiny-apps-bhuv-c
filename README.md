# Rpackage

**Rpackage** is an interactive **Shiny dashboard** packaged for **ETC5523 – Communicating with Data** (Monash University).  
It visualises **Disability-Adjusted Life Years (DALYs) per 100,000** for five healthcare-associated infections, split into **YLD** (Years Lived with Disability) and **YLL** (Years of Life Lost), across two surveillance studies: **German PPS** and **ECDC PPS (EU/EEA)**.

---

## Overview

- A clean, tidy dataset of infection-burden metrics (`Data`).
- A fully interactive Shiny app (in `inst/app`) with a crimson theme.
- A pkgdown site with consistent styling and documentation.
- Examples of clear data descriptions that align with ETC5523 rubric.

---

## Data summary

The dataset (`Data`) provides **DALY estimates per 100,000 population** for five infection categories, across two study groups and two DALY components.

| Variable | Description |
|-----------|--------------|
| **group** | Surveillance study source — either *German PPS* (national study) or *ECDC PPS* (EU-wide). |
| **category** | Type of healthcare-associated infection:<br>• **HAP** – Hospital-Acquired Pneumonia<br>• **SSI** – Surgical Site Infection<br>• **BSI** – Bloodstream Infection<br>• **UTI** – Urinary Tract Infection<br>• **CDI** – *Clostridioides difficile* Infection |
| **component** | DALY component:<br>• **YLD** – *Years Lived with Disability*<br>• **YLL** – *Years of Life Lost* |
| **value** | Mean DALYs per 100,000 population for the infection and component. |
| **se** | Standard error of the total stacked DALY value (used to show uncertainty in error bars). |

Each bar in the dashboard shows YLD + YLL contributions to total burden for each infection type, allowing comparisons across studies and components.
    | Standard error for the **stacked total** (`YLD + YLL`), used to draw uncertainty/error bars. |

**Notes on interpretation**

- In **stacked** bars, the error bar represents uncertainty for the *total* DALY burden (YLD + YLL).  
- In **side-by-side** bars, component values (YLD vs YLL) are shown separately and the total-SE bar is hidden.

**Source:**  
Zacher, B. *et al.* (2019). *Disease burden of healthcare-associated infections in Germany*. 
Read the paper → https://cwd.numbat.space/assignments/assignment-2-papers/Zacher2019.pdf

---

## Installation

```r
# install.packages("devtools")
devtools::install_github("ETC5523-2025/assignment-4-packages-and-shiny-apps-bhuv-c")
