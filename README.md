# bond-spreads-monitor

Das Dashboard dient der vergleichenden Darstellung von Emissionsspreads einer bestimmten Bank, beispielsweise der eigenen Arbeitgeberbank im internen Einsatz (hier die DZ HYP AG als Beispiel) gegenüber Jumbo-Pfandbriefspreads externer Emittenten (wie Commerzbank, Deutsche, Aareal, usw.).

Zusätzlich wird der 3-Monats-Euribor als Reference-Rate genutzt und über die Laufzeit und Deckungsart (Hypothekendeckung oder kommunal) auf die Bankemissionen gemappt. Die Renditen externer Emittenten werden ebenfalls übersichtlich dargestellt, um einen schnellen Überblick über das aktuelle Marktniveau zu ermöglichen.

Es werden keine sensiblen, nicht öffentlichen Bankdaten dargestellt.

## Aktuelle Methodik

Benötigte Packages: `shiny`, `dplyr`, `ggplot2`, `plotly`, `DT`, `readxl`, `openxlsx`, `gridExtra` und `stringr`.

R liest die Datei `MarktdatenSpreadsbereinigtmitRendite.xlsx` ein. Für die Darstellung wird `REFZS_SPREAD_SCD_BPS = REFZS_SPREAD_SCD * 100` gebildet. Beispiel: 0,42 entspricht 42 bp. Auf die genaue Aufbereitung und Methodik der Daten wird in einer späteren Erweiterung des README eingegangen.
