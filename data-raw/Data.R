## code to prepare `Data` dataset goes here
library(tidyverse)
library(patchwork)

Data <- tribble(
  ~group,          ~category, ~component, ~value, ~se,
  # German PPS
  "German PPS",    "HAP",     "YLD",        35,   30,
  "German PPS",    "HAP",     "YLL",        50,   30,
  "German PPS",    "SSI",     "YLD",         8,    6,
  "German PPS",    "SSI",     "YLL",        30,    6,
  "German PPS",    "BSI",     "YLD",        12,   28,
  "German PPS",    "BSI",     "YLL",        59,   28,
  "German PPS",    "UTI",     "YLD",        28,   24,
  "German PPS",    "UTI",     "YLL",        55,   24,
  "German PPS",    "CDI",     "YLD",         0,   18,
  "German PPS",    "CDI",     "YLL",        25,   18,

  # ECDC PPS (EU/EEA)
  "ECDC PPS",      "HAP",     "YLD",        45,   55,
  "ECDC PPS",      "HAP",     "YLL",        66,   55,
  "ECDC PPS",      "SSI",     "YLD",         4,    7,
  "ECDC PPS",      "SSI",     "YLL",        34,    7,
  "ECDC PPS",      "BSI",     "YLD",        16,   26,
  "ECDC PPS",      "BSI",     "YLL",        59,   26,
  "ECDC PPS",      "UTI",     "YLD",        18,   23,
  "ECDC PPS",      "UTI",     "YLL",        40,   23,
  "ECDC PPS",      "CDI",     "YLD",         0,   12,
  "ECDC PPS",      "CDI",     "YLL",        10,   12
) |>
  mutate(
    category  = factor(category, levels = c("HAP","SSI","BSI","UTI","CDI")),
    component = factor(component, levels = c("YLD","YLL"))
  )

# Totals per bar (for error bars)
totals <- df |>
  group_by(group, category) |>
  summarise(total = sum(value), se = first(se), .groups = "drop") |>
  mutate(ymin = pmax(0, total - se), ymax = total + se)

# Color palette (close to the figure)
pal <- c(
  "YLD" = "orange",  # warm brown/orange
  "YLL" = "skyblue"
)


usethis::use_data(Data, overwrite = TRUE)
