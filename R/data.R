# Gelieferte Gesamtlaufzeiten und Rohspreads unverändert erhalten.
prepare_market_data <- function(data) {
  zinsart <- toupper(trimws(as.character(data$Zinsart)))
  zinsart[is.na(zinsart) | zinsart %in% c("", "NICHT ANGEGEBEN")] <- "Nicht angegeben"
  data$Zinsart <- zinsart
  data$REFZS_SPREAD_SCD_BPS <- data$REFZS_SPREAD_SCD * 100
  data
}

read_market_data <- function(path) {
  prepare_market_data(readxl::read_excel(path))
}
