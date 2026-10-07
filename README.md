# bond-spreads-monitor

Das Dashboard dient der vergleichenden Darstellung von Emissionsspreads einer bestimmten Bank, beispielsweise der eigenen Arbeitgeberbank im internen Einsatz (hier die DZ HYP AG als Beispiel) gegenüber Jumbo-Pfandbriefspreads externer Emittenten (wie Commerzbank, Deutsche, Aareal, usw.).

Zusätzlich wird der 3-Monats-Euribor als Reference-Rate genutzt und über die Laufzeit und Deckungsart (Hypothekendeckung oder kommunal) auf die Bankemissionen gemappt. Die Renditen externer Emittenten werden ebenfalls übersichtlich dargestellt, um einen schnellen Überblick über das aktuelle Marktniveau zu ermöglichen.

Es werden keine sensiblen, nicht öffentlichen Bankdaten dargestellt.

## Start

`BSM_V1_start.R` ist der einzige produktive Einstiegspunkt. Das RStudio-Projekt
`bond-spreads-monitor.Rproj` öffnen und aus dem Projektverzeichnis starten:

```r
shiny::runApp("BSM_V1_start.R")
```

Das Dashboard enthält Spreadvergleich, Renditegrafik, Detailtabelle,
Excel- und PDF-Export sowie Emittentenprofile. Benötigt werden `R/data.R`,
`MarktdatenSpreadsbereinigtmitRendite.xlsx` und `data/issuer_master.csv`.

## Aktuelle Methodik

Benötigte Packages: `shiny`, `dplyr`, `ggplot2`, `plotly`, `DT`, `readxl`, `here`, `openxlsx`, `gridExtra` und `stringr`.

Statische Emittentenangaben werden in `data/issuer_master.csv` (UTF-8, kommagetrennt) gepflegt und beim Start von `BSM_V1_start.R` als `issuer_master` geladen. Pro Emittent ist genau eine Zeile vorgesehen; die Namen müssen für die Zuordnung mit `Emittent` in den Marktdaten übereinstimmen. Unbekannte Angaben bleiben leer oder werden als `NA` eingetragen. Texte mit Kommas müssen in doppelte Anführungszeichen gesetzt werden. Die Beispielzeilen enthalten zunächst ausschließlich die Emittentennamen; Unternehmensangaben und Ratings sind noch nicht befüllt. Die Emittentenprofile werden in der Seitenleiste angezeigt.

R liest die Datei `MarktdatenSpreadsbereinigtmitRendite.xlsx` ein. Für die Darstellung wird `REFZS_SPREAD_SCD_BPS = REFZS_SPREAD_SCD * 100` gebildet. Beispiel: 0,42 entspricht 42 bp. Auf die genaue Aufbereitung und Methodik der Daten wird in einer späteren Erweiterung des README eingegangen.
