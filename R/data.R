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

# Statische Stammdaten: leere Felder und NA bleiben fehlende Angaben.
read_issuer_master <- function(path = here::here("data", "issuer_master.csv")) {
  expected_columns <- c(
    "Emittent", "Land", "Sitz", "Institutstyp", "Geschaeftsmodell",
    "Funding_Profil", "Kurzprofil", "Website", "Investor_Relations_URL", "Quelle"
  )
  if (!file.exists(path)) {
    stop("Emittenten-Stammdatendatei fehlt: ", path, call. = FALSE)
  }
  data <- read.csv(
    path, fileEncoding = "UTF-8", colClasses = "character",
    na.strings = c("", "NA"), check.names = FALSE, strip.white = TRUE
  )
  if (!identical(names(data), expected_columns)) {
    stop("issuer_master.csv muss die vorgesehenen 10 Spalten in der definierten Reihenfolge enthalten.",
         call. = FALSE)
  }
  data[] <- lapply(data, trimws)
  data[] <- lapply(data, function(x) { x[x == ""] <- NA_character_; x })
  if (anyNA(data$Emittent) || anyDuplicated(data$Emittent)) {
    stop("issuer_master.csv: Emittent muss ausgefüllt und eindeutig sein.", call. = FALSE)
  }
  data
}
