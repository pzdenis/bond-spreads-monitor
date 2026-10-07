# bond-spreads-monitor

Das Dashboard dient der vergleichenden Darstellung von Emissionsspreads einer bestimmten Bank, beispielsweise der eigenen Arbeitgeberbank im internen Einsatz (hier die DZ HYP AG als Beispiel) gegenüber Jumbo-Pfandbriefspreads externer Emittenten (wie Commerzbank, Deutsche, Aareal, usw.).

Zusätzlich wird der 3-Monats-Euribor als Reference-Rate genutzt und über die Laufzeit und Deckungsart (Hypothekendeckung oder kommunal) auf die Bankemissionen gemappt. Die Renditen externer Emittenten werden ebenfalls übersichtlich dargestellt, um einen schnellen Überblick über das aktuelle Marktniveau zu ermöglichen.

Es werden keine sensiblen, nicht öffentlichen Bankdaten dargestellt.


Das Dashboard enthält Spreadvergleich, Renditegrafik, Detailtabelle,
Excel- und PDF-Export sowie Emittentenprofile. Benötigt werden `R/data.R`,
`MarktdatenSpreadsbereinigtmitRendite.xlsx` und `data/issuer_master.csv`.
 Für die Darstellung wird `REFZS_SPREAD_SCD_BPS = REFZS_SPREAD_SCD * 100` gebildet. Beispiel: 0,42 entspricht 42 bp. Auf die genaue Aufbereitung und Methodik 
 der Daten wird in einer späteren Erweiterung des README eingegangen.

## Aktuelle Methodik

Benötigte Packages: `shiny`, `dplyr`, `ggplot2`, `plotly`, `DT`, `readxl`, `here`, `openxlsx`, `gridExtra` und `stringr`.

Statische Emittentenangaben werden in `data/issuer_master.csv` (UTF-8, kommagetrennt) gepflegt und beim Start von `BSM_V1_start.R` als `issuer_master` geladen. 

