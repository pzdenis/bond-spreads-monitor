Ich untersuche die Repository-Struktur, die R-Dateien und den Datenfluss bis zur Shiny-App. Dabei prüfe ich besonders, welche Teile für ein eigenständiges Dashboard für Spreadvergleiche nötig sind und wo Bond-Kennzahlen oder MKK-Bandbreiten damit verflochten sind. Ich ändere keine Dateien.
• Ran pwd && rg --files --hidden -g '!.git' -g '!renv/library/**' -g '!node_modules/**' -g '!packrat/lib/**'
  └ smime.p7s
    shinyapp3.6.1 R.R
    bond-spreads-monitor.Rproj
• Explored
  └ Search AGENTS.md in ..
• Ran wc -l *.R *.txt README.md && git status --short && cat README.md beschreibung.txt 'formulas used.txt' .gitignore bond-spreads-monitor.Rproj
  └ 
    RnwWeave: Sweave
    LaTeX: pdfLaTeX
• Ran cat global.R main_dashboard.R helpers_calendar.R helpers_daycount.R
  └   dc <- DayCounter("ActualActual", "ICMA")  # ICMA
      yearFraction(as.Date(start), as.Date(end), dc)
    }
• Explored
  └ Read shinyapp3.6.1 R.R, helpers_yield.R, module_yield.R, module_mkk.R, module_plausi.R
• Ran cat helpers_yield.R module_yield.R
  └     })
      })
    }
• Ran sed -n '1,115p' module_mkk.R && command -v Rscript && Rscript --vanilla -e 'cat(as.character(getRversion()))'
  └ 4.6.1
Der Spreadvergleich verwendet bereits fertig gelieferte Excel-Werte; die Bond-Rechner speisen ihn nicht. Die Verflechtung liegt vor allem im gemeinsamen App-Start und in der Oberfläche. Außerdem sind zwei App-Einstiegspunkte vorhanden, deren Startlogik derzeit kollidiert. Ich prüfe noch die Excel-Strukturen und konkrete Fehlerstellen, um notwendige Dashboard-Bestandteile von entbehrlichen Abhängigkeiten zu unterscheiden.
• Ran Rscript --vanilla -e 'pkgs <- c("shiny","bslib","shinyWidgets","ggplot2","ggthemes","readxl","dplyr","DT","plotly","gridExtra","stringr","lubridate","RQuantLib","here","shinyvalidate","readr","openxlsx"); …
  └ PARSE OK: module_plausi.R 
    PARSE OK: module_yield.R 
    PARSE OK: shinyapp3.6.1 R.R 
• Ran rg -n 'testumgebung|source\(|library\(|::|ql_cal|adjust_bday|advance_date|yearfrac_icma|filteredDZ' --glob '*.R' && file smime.p7s && ls -lh *.xlsx
  └ -rw-r--r--. 1 ernstfroehlich ernstfroehlich 11K Aug 20 15:54 Hilfdatei mkk-reiter R.xlsx
    -rw-r--r--. 1 ernstfroehlich ernstfroehlich 43K Aug 20 15:54 MarktdatenSpreadsbereinigtmitRendite.xlsx
    -rw-r--r--. 1 ernstfroehlich ernstfroehlich 38K Aug 20 15:54 Marktdaten_Spreads_bereinigt.xlsx
• Ran python - <<'PY' …
  └ Laufzeit in Jahren missing 0 unique 13 range (3.0, 20.0) values 
    AssetSwapSpreadMid missing 0 unique 259 range (1.66343289809538, 58.87895053895403) values 
    Zinsart missing 3 unique 3 range  values [('H', 230), ('K', 34), ('', 3)]
• Ran Rscript --vanilla -e 'e <- new.env(); x <- parse("helpers_yield.R"); for (v in x) if (!(is.call(v) && identical(v[[1]],as.name("library")))) eval(v,e); print(e$price_from_ytm(as.Date("2025-07-01"),as.Date(…
  └ [1] 0
    
    past coupon candidates: 0 
• Ran python - <<'PY' …
  └ DZ rows [{'A': 'DZ HYP AG', 'B': 'INTERN REFI', 'C': 'DE000A13SR38', 'D': 'HypPfe', 'E': 'Pfandbriefe Traditionelle Hypotheken', 'F': '42024', 'G': '18.01.2030', 'H': '15', 'I': '26.635636665407841', 'J': '7…
    duplicate ISIN [('XS3074424188', 2), ('DE000BHY0HZ2', 3), ('DE000A3E5K73', 2), ('DE000MHB41J8', 2), ('DE000MHB38J4', 2), ('DE000MHB31J9', 2), ('DE000NLB2TD7', 2)]
    maturity examples [('07.05.2027', '3'), ('25.02.2028', '3'), ('11.01.2027', '3'), ('15.01.2027', '3'), ('13.10.2026', '3'), ('24.01.2028', '3'), ('19.10.2026', '3'), ('26.04.2027', '3')]
• Ran git diff --stat && git status --short && nl -ba main_dashboard.R | head -60 && nl -ba helpers_yield.R | tail -105
  └    124      if (is.na(wal_years) || wal_years <= 0) return(NA_real_)
       125      ((par - price_clean) / wal_years) * 10000
       126    }
Das Repository enthält einen brauchbaren Kern für Spreadvergleiche, ist aktuell aber mit einer zweiten Dashboard-Oberfläche, Bond-Rechnern und bankinternen MKK-Funktionen vermischt. Für dein gewünschtes eigenständiges Spread-Dashboard lassen sich diese Teile weitgehend abtrennen: Der Spreadvergleich verwendet keine Ergebnisse der Bond-Rechner.

Ich habe alle neun R-Dateien, die Begleitdateien und die Strukturen/Inhalte der fünf Excel-Dateien untersucht. Es wurden keine Dateien verändert. Die bereits vorhandene Änderung an shinyapp3.6.1 R.R und die unversionierte .Rproj-Datei habe ich unangetastet gelassen.

Alle R-Dateien sind syntaktisch parsebar. Ein vollständiger App-Lauf war nicht möglich, weil die benötigten R-Pakete in dieser Umgebung fehlen. Die folgenden Laufzeitprobleme sind daher aus dem Code abgeleitet; einen zentralen Berechnungsfehler habe ich zusätzlich isoliert mit R reproduziert.

1. Aktueller Projektaufbau

Das Projekt liegt vollständig im Hauptverzeichnis. Es gibt keine getrennten Verzeichnisse für App, Daten, Berechnungen oder Tests und keinen eindeutigen standardisierten App-Einstieg wie app.R.

Inhaltlich bestehen vier Bereiche:

 Bereich                   Umsetzung
━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Spreadvergleich           Excel-Import, Filter, interaktive Grafiken und Exporte in shinyapp3.6.1 R.R
────────────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────
 Bond-Kennzahlen           Preis, Rendite, Stückzinsen, DV01 und FRN-Näherung
────────────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────
 MKK-Funktionen            Bandbreitentabelle, Arbeitsanleitung, Plain-Vanilla-Plausibilisierung und Callable-Prototyp
────────────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────
 Alternative Oberfläche    main_dashboard.R mit Startseite und zwei MKK-/Rendite-Reitern

Der Dateiname main_dashboard.R ist dabei irreführend: Der eigentliche Spreadvergleich steckt in shinyapp3.6.1 R.R, nicht in main_dashboard.R.

2. Aufgaben der einzelnen Dateien

 Datei                 Aktuelle Aufgabe                                                                                                      Bedeutung für dein Ziel
━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 shinyapp3.6.1 R.R     Lädt Skripte und drei Excel-Dateien; enthält CSS, gesamte Vergleichsoberfläche, Filter, Diagramme, Tabellen,          Wichtigste Grundlage, aber stark zu entflechten
                       Exporte und MKK-Leitfaden
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 main_dashboard.R      Lädt Pakete und Skripte; baut separate Navigation mit Startseite, Rendite-Plausi und MKK-Bewertung                    Für den Spreadvergleich derzeit keine eigene Funktion
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 global.R              Lädt fünf Helper-/Moduldateien erneut                                                                                 Redundante Initialisierung
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 helpers_yield.R       Kupontermine, Stückzinsen, Preis ↔ Rendite, DV01, FRN-Discount-Margin-Näherung                                        Für reine Spreadvergleiche entbehrlich
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 helpers_calendar.R    Wrapper für TARGET-Kalender und Geschäftstagsanpassungen über RQuantLib                                               Im übrigen Projekt nicht aufgerufen
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 helpers_daycount.R    Vorgesehener ICMA-Jahresbruch-Helfer                                                                                  Im übrigen Projekt nicht aufgerufen
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 module_yield.R        Shiny-Modul mit Bond-Eingaben, Kennzahlen, separater Daycount-Anzeige und Preis-Rendite-Kurve                         Entfällt bei deinem Ziel
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 module_mkk.R          Plain-Vanilla-Plausibilisierung sowie Callable-Auswertung aus hochgeladener Spread-CSV                                Eigenständiger Nebenbereich, für das Vergleichsdashboard entbehrlich
────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ──────────────────────────────────────────────────────────────────────
 module_plausi.R       Weiteres Plain-Vanilla-Plausi-Modul, teilweise ähnlich zu module_mkk.R                                                Wird nirgends eingebunden

Die Daten- und Begleitdateien:

 Datei                                        Inhalt / Verwendung
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MarktdatenSpreadsbereinigtmitRendite.xlsx    Aktive Vergleichsdaten: 267 Datenzeilen, 16 Spalten, 25 Emittenten; enthält bereits Spreads und Renditen
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Marktdaten_Spreads_bereinigt.xlsx            Ähnlicher Bestand ohne Renditespalte; aktuell nicht eingelesen. Keine identische Ersatzdatei: unter anderem fehlen drei Zinsart-Werte
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Gemergte_Spread_Markt_Daten.xlsx             465 Datenzeilen mit externen Kupons und DZ-HYP-Referenzinformationen; aktuell nicht verwendet
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 BandbreitenMKK2.xlsx                         72 Datenzeilen mit Kategorie, Segment und Wert; versorgt ausschließlich die Bandbreitenauswahl/-tabelle
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 Hilfdatei mkk-reiter R.xlsx                  13 Datenzeilen mit Geschäftsarten und SCD-Arbeitsschritten; versorgt die Checkliste
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 beschreibung.txt                             Kurze Erläuterung der Referenzzinskennungen und Beispieldaten; enthält einen offensichtlichen Buchstabenfehler bei der Erklärung von T
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 formulas used.txt                            Manuelle Excel-Umformungen für Datum und Volumen; kein ausführbarer Aufbereitungsprozess
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 README.md                                    Enthält nur den Projektnamen
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 bond-spreads-monitor.Rproj                   RStudio-Projekteinstellungen
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 .gitignore                                   Übliche Ausschlüsse für R-Arbeitsstände, Paketbibliotheken und Umgebungsdateien
───────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 smime.p7s                                    PKCS#7-Signaturdatei; keine erkennbare App-Funktion

3. Datenfluss

Der implementierte Datenfluss des Spreadvergleichs ist:

flowchart TD
    A[Excel: Marktdaten mit Spread und Rendite] --> B[Einlesen und minimale Bereinigung]
    B --> C[Filter: Zinsart, Laufzeit, Emittent]
    C --> D[Spreadgrafik: DZ HYP gegen übrige Emittenten]
    C --> E[Renditegrafik: übrige Emittenten]
    C --> F[Detailtabelle und PDF]
    C --> G[Excel-Export: nur übrige Emittenten]

    H[Excel: MKK-Bandbreiten] --> I[Kategorie-/Segmentfilter und Tabelle]
    J[Excel: MKK-Arbeitsschritte] --> K[Checkliste und Originaldatei-Download]

    L[Manuelle Bond-Eingaben] --> M[Yield-Helper]
    M --> N[Bond-Kennzahlen und Plausi]

    O[Separate Spread-CSV] --> P[Callable-Mittelwerte und Funding-Vergleich]

Die wichtige Trennung: Zwischen den Bond-Kennzahlen und den eingelesenen Vergleichsdaten gibt es keinen Rückfluss. Auch die MKK-Bandbreiten verändern weder die Spreads noch die Spreadgrafik.

Die Aufbereitung in der App beschränkt sich auf:

Entfernen von Zeilen mit fehlender Zinsart.
Vereinheitlichen der Zinsart durch Großschreibung und Entfernen äußerer Leerzeichen.
Runden von Laufzeit in Jahren auf zwei Nachkommastellen.
Ableiten der Filterauswahl aus dem eingelesenen Bestand.

Anschließend werden die Daten je Sitzung reaktiv gefiltert. Die Excel-Dateien selbst werden beim Ausführen des Skripts geladen; eine Aktualisierung im laufenden Dashboard ist nicht vorgesehen.

Die vorgelagerte Datenaufbereitung fehlt im Repository. Es gibt keinen R-Prozess, der Rohdaten zusammenführt, Asset-Swap-Spreads erzeugt, SCD-Werte zuordnet oder die Renditespalte berechnet. Die vorhandenen Excel-Dateien lassen verschiedene Bearbeitungsstände erkennen, aber deren Entstehung ist nicht reproduzierbar dokumentiert.

4. Abhängigkeiten zwischen den R-Dateien

Die derzeitige Ladekette sieht so aus:

shinyapp3.6.1 R.R
├── packages.R                    FEHLT
├── helpers_calendar.R
├── helpers_yield.R
├── helpers_daycount.R
├── module_yield.R
├── module_mkk.R
└── main_dashboard.R
    ├── lädt dieselben Helper und Module erneut
    └── lädt über festen G:/-Pfad weitere Dateien
        └── global.R
            └── lädt dieselben Helper und Module nochmals

module_plausi.R                   nicht eingebunden

Die tatsächlichen funktionalen Abhängigkeiten sind deutlich kleiner:

 Verbraucher                            Benötigte eigene Funktionen
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 module_yield.R                         ytm_from_price(), price_from_ytm(), dv01(), discount_margin_approx() aus helpers_yield.R
─────────────────────────────────────  ──────────────────────────────────────────────────────────────────────────────────────────
 Plain-Vanilla-Teil von module_mkk.R    ytm_from_price() und price_from_ytm()
─────────────────────────────────────  ──────────────────────────────────────────────────────────────────────────────────────────
 module_plausi.R                        Dieselben zwei Yield-Funktionen
─────────────────────────────────────  ──────────────────────────────────────────────────────────────────────────────────────────
 Spreadvergleich                        Keine der Bond-, Kalender- oder Daycount-Funktionen
─────────────────────────────────────  ──────────────────────────────────────────────────────────────────────────────────────────
 Kalender-/Daycount-Helper              Keine Aufrufe aus den aktiven Berechnungen

Module greifen außerdem auf global geladene Pakete zurück. Beispielsweise lädt module_yield.R selbst nur ggplot2, verwendet aber Shiny-Funktionen ohne Namespace. Dadurch hängt seine Funktionsfähigkeit von der vorherigen Ladereihenfolge ab.

5. Technische Schwachstellen und Konsequenzen für dein Ziel

A. Der App-Start ist nicht eigenständig reproduzierbar

Drei konkrete Hindernisse:

shinyapp3.6.1 R.R erwartet unmittelbar eine nicht vorhandene packages.R.
main_dashboard.R lädt Dateien aus einem fest eingebauten bankinternen G:/...-Verzeichnis. Der angeblich optionale Block läuft immer, weil base und files unmittelbar davor definiert werden.
testumgebung wird verwendet, aber in keiner Repository-Datei definiert.

Außerdem definieren beide Dashboard-Dateien globale ui-/server-Objekte und erzeugen jeweils ein shinyApp()-Objekt. Das ist eine konkurrierende App-Struktur statt eines klaren Einstiegspunkts. Siehe Startlogik in main_dashboard.R (main_dashboard.R:22).

B. Für den Spreadvergleich sind Datenbedeutung und Einheiten die wichtigsten offenen Punkte

Hier liegt aus meiner Sicht der größte fachlich-technische Handlungsbedarf für das künftige Dashboard.

SCD-Einheit ist nicht abgesichert. AssetSwapSpreadMid enthält Werte von ungefähr 1,66 bis 58,88, REFZS_SPREAD_SCD Werte von 0,37 bis 0,72. Beide werden unverändert auf einer Achse „Spread (bps)“ dargestellt. Das spricht für möglicherweise unterschiedliche Einheiten. Falls 0,37 Prozentpunkte bedeutet, müsste die Anzeige 37 bp lauten. Die App prüft oder konvertiert das nicht.

„Laufzeit“ ist offenbar nicht durchgehend Restlaufzeit. Eine DZ-HYP-Anleihe mit Fälligkeit 18.01.2030 steht beispielsweise mit 15 Jahren in der Datei. Das deutet auf Ursprungslaufzeit oder Referenzlaufzeit hin. Für einen Vergleich entlang der Restlaufzeit wäre das eine andere Bezugsgröße.

Ein belastbarer Bewertungsstichtag fehlt. Die Spalte REFZS_PRICEDATE enthält tatsächlich Beschreibungen wie 10Y-HYPO-Median, keine Datumswerte.

Die Bedeutung der SCD-Werte ist unklar. Kennungen und Beschreibungen deuten auf zugeordnete Referenz-/Segmentwerte hin. Die Oberfläche präsentiert sie jedoch wie individuelle Anleihespreads.

Mehrfach vorhandene ISINs werden nicht behandelt. Sieben ISINs kommen mehrfach vor, eine davon dreimal. Ob das fachlich unterschiedliche Beobachtungen oder Dubletten sind, wird nicht unterschieden.

Diese Fragen werden durch das Entfernen der Bond-Rechner nicht gelöst. Für zuverlässige Spreadvergleiche sollten Einheit, Bezugsgröße, Stichtag und Beobachtungsschlüssel ausdrücklich definiert sein.

C. Der Vergleich und seine Exporte sind inkonsistent

Die Detailtabelle und der PDF-Export enthalten alle gefilterten Emittenten. Der Excel-Export verwendet dagegen filteredMKT() und schließt DZ HYP aus. Das widerspricht dem Kommentar „Einheitliche Datengrundlage für Tabelle + Export“. Siehe Exportlogik (shinyapp3.6.1 R.R:245).

Weitere Einschränkungen:

ISIN, Fälligkeit und Datenstand fehlen in der Detailtabelle und den Vergleichsexporten.
Alle anderen Emittenten werden grafisch unter „Markt“ zusammengefasst.
DZ HYP ist über einen festen Namensvergleich eingebaut; die vorhandene Spalte Herkunft wird dafür nicht verwendet.
Fehlende Pflichtspalten, falsche Datentypen, leere Datenbestände oder nichtnumerische Spreads werden nicht systematisch abgefangen.
Der PDF-Titel verwendet das aktuelle Datum, ohne dieses von einem Bewertungsstichtag zu unterscheiden.
Die Download-Icons werden von einer externen Website geladen; vollständig offline ist die Oberfläche damit nicht.

D. Die Bond-Berechnungen enthalten konkrete Fehler

Für dein Ziel sind diese vor allem ein Argument, den Berechnungsbereich aus dem Dashboard herauszulösen.

Der gravierendste Fehler liegt in helpers_yield.R:36:

cps <- coupon_boundaries(settle, maturity, freq)
last_candidates <- cps[cps < settle]

coupon_boundaries() liefert ausschließlich Termine nach Settlement. Damit ist last_candidates immer leer. Der vorherige Kupontermin wird anschließend auf Settlement gesetzt.

Die Folgen:

Stückzinsen werden in diesen Preis-/Yield-Funktionen immer null.
Clean und Dirty Price fallen zusammen.
Die angebrochene Kuponperiode wird bei der Abzinsung nicht berücksichtigt.

Das habe ich isoliert reproduziert: Settlement 01.07.2025, Fälligkeit 01.01.2030, jährlicher Kupon und YTM jeweils 3 % ergeben clean = 100, dirty = 100, ai = 0.

Zusätzlich:

conv, calendar und bdc werden zwar übergeben, in der Preisberechnung aber nicht ausgewertet.
Die Daycount-Anzeige in module_yield.R berechnet Stückzinsen separat und kann daher andere Ergebnisse zeigen als die Zusammenfassung.
Bei ACT/365 und ACT/360 wird der Jahresbruch nochmals mit einem durch die Frequenz geteilten Kupon multipliziert.
Die Gesamtstückzinsen vermischen Beträge je 100 mit der Anzahl von Nominaleinheiten.
Die FRN-Näherung mischt den Preis je 100 mit input$face, standardmäßig einer Million.
Fehler werden teilweise nur in NA umgewandelt; die Ursache bleibt unsichtbar.

E. Die Callable-Auswertung ist ein Prototyp

In module_mkk.R:283 werden zwei einfache Mittelwerte gebildet:

Mittelwert aller CSV-Spreads bis Call
Mittelwert aller CSV-Spreads bis Endfälligkeit
→ Mischung mit manuell gewählter Call-Wahrscheinlichkeit
→ Abzug des Funding-Levels

Dabei beeinflussen Kupon, Zahlungsfrequenz, Rückzahlung und Hull-White-Parameter das Ergebnis nicht. Eine entsprechende Bewertungsengine ist nicht implementiert.

Auch wird der Zeitraum nicht nach unten durch Settlement begrenzt. Liegen sämtliche CSV-Daten vor dem Call-Datum, können beide Mittelwerte identisch sein. Die Vorzeichenbeschreibung des Funding-Vorteils widerspricht zudem dem Codekommentar.

Mehrere Datumsvalidierungen haben leere Fehlerzweige und melden deshalb keinen Fehler.

F. Unnötige Abhängigkeiten

Für dein geplantes Dashboard ergibt sich folgende Einordnung:

 Abhängigkeit                       Künftige Notwendigkeit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 shiny                              Kern der App
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 readxl, dplyr                      Sinnvoll für Excel-Import und Aufbereitung
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 DT                                 Sinnvoll für interaktive Tabellen
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 ggplot2 und plotly                 Aktuell gemeinsam für interaktive Grafiken verwendet
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 openxlsx                           Bei Beibehaltung des Excel-Exports
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 grid, gridExtra, stringr           Aktuell für den PDF-Export; abhängig von dessen künftiger Umsetzung
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 bslib                              Optional sinnvoll für eine neue Oberfläche, derzeit nur im alternativen Dashboard genutzt
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 here                               Pfadverwaltung; kann bleiben
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 RQuantLib                          Für den Spreadvergleich nicht erforderlich; seine Helper werden nicht genutzt
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 shinyvalidate, readr, lubridate    Aktuell überwiegend durch MKK-/Bond-Funktionen nötig; nach deren Entfernung neu bewerten
─────────────────────────────────  ───────────────────────────────────────────────────────────────────────────────────────────
 shinyWidgets, ggthemes             Werden geladen, aber im vorhandenen Code nicht erkennbar verwendet

Es fehlen außerdem Paketversionsbindung, Startanleitung und Tests. Die .Rproj-Einstellungen überlassen das Wiederherstellen des Workspace den lokalen Defaults; das kann fehlende globale Variablen auf einem Entwicklerrechner verdecken.

Empfohlenes Zielbild für dein Stand-alone-Dashboard

Ich würde den vorhandenen Spreadvergleich weiterverwenden und seine Verantwortung klar begrenzen:

Ein App-Einstieg
    → Datenimport
    → Schema-, Einheiten- und Qualitätsprüfung
    → gemeinsamer gefilterter Datenbestand
    → Spreadgrafik, Detailtabelle und konsistente Exporte

Daraus folgen diese Prioritäten:

Start bereinigen: ein Einstiegspunkt, keine internen Laufwerkspfade, keine mehrfachen source()-Ketten.
Bond- und MKK-Bereiche abtrennen: Yield-/Plausi-/Callable-Module, Bandbreiten und Leitfaden sind für den Spreadvergleich nicht erforderlich.
Datenvertrag festlegen: ISIN, Emittent, Segment, Fälligkeit beziehungsweise klar definierte Laufzeit, Bewertungsstichtag, Spreadtyp und Einheit.
Vergleich verbessern: frei wählbarer Referenzemittent, nachvollziehbare Vergleichsgruppe, aussagekräftige Tooltips und Tabellen.
Ausgaben vereinheitlichen: Grafik, Tabelle und Exporte aus derselben Auswahl mit dokumentiertem Datenstand.

Auch die Renditespalte ist für dieses Ziel nicht erforderlich. Ihre Entfernung würde allerdings nicht bedeuten, einfach auf die ältere Excel-Datei umzuschalten: Deren Datenstand weicht bereits sichtbar ab.

Der entscheidende Architekturpunkt ist bereits günstig: Die Spreadanzeige ist rechnerisch unabhängig von Bond-Kennzahlen und MKK-Bandbreiten. Die größte Arbeit liegt in einem verlässlichen Datenmodell und einem sauberen App-Aufbau.
  Worked for 3m 32s · 4:31 PM
