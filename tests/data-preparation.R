# Aus dem Projektverzeichnis: Rscript --vanilla tests/data-preparation.R
source("R/data.R")

raw <- data.frame(
  Zinsart = c(" h ", NA, "", "K", "K"),
  REFZS_SPREAD_SCD = c(0.42, NA, -0.12, 0.42, 0.42),
  Rendite = c(NA, 2, 3, 4, 4),
  check.names = FALSE
)
raw$`Laufzeit in Jahren` <- c(15, 3.12345, 20, 10, 10)
prepared <- prepare_market_data(raw)
stopifnot(
  prepared$REFZS_SPREAD_SCD_BPS[1] == 42,
  prepared$REFZS_SPREAD_SCD_BPS[3] == -12,
  identical(prepared$REFZS_SPREAD_SCD, raw$REFZS_SPREAD_SCD),
  identical(prepared$`Laufzeit in Jahren`, raw$`Laufzeit in Jahren`),
  identical(prepared$Rendite, raw$Rendite),
  identical(prepared$Zinsart, c("H", "Nicht angegeben", "Nicht angegeben", "K", "K")),
  nrow(prepared) == nrow(raw),
  sum(duplicated(prepared)) == sum(duplicated(raw)),
  identical(prepare_market_data(prepared), prepared)
)
cat("OK: 0,42 -> 42 bp; Rohwerte, Gesamtlaufzeit, fehlende Renditen und Duplikate erhalten.\n")
