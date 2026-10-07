
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(grid)

source("R/data.R", local = TRUE, encoding = "UTF-8")

# Statische Stammdaten ereinladen
issuer_master <- read_issuer_master(here::here("data", "issuer_master.csv"))
df_raw <- read_market_data("MarktdatenSpreadsbereinigtmitRendite.xlsx")
min_lz <- min(df_raw$`Laufzeit in Jahren`, na.rm = TRUE)
max_lz <- max(df_raw$`Laufzeit in Jahren`, na.rm = TRUE)
zinsarten <- sort(unique(df_raw$Zinsart))
emittenten <- sort(unique(df_raw$Emittent))

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background: linear-gradient(270deg, #e5e5e5, #f0f2f6, #cccccc);
        bSackground-size: 600% 600%;
        animation: gradientBG 2s ease forwards;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      }
      @keyframes gradientBG {
        0% { background-position: 0% 50%; }
        100% { background-position: 100% 50%; }
      }
      .glass-box {
        background: linear-gradient(to bottom, #f0f8ff, #ddeeff);
        border: 1px solid #819cd6;
        border-radius: 10px;
        box-shadow: inset 0 1px 0 #ffffff, 0 2px 5px rgba(0, 0, 0, 0.2);
        padding: 20px;
        margin: 10px;
      }
      .issuer-profile {
        background: #f8fafc;
        border-radius: 8px;
        padding: 16px;
        margin-top: 20px;
        overflow-wrap: anywhere;
        color: #25374a;
      }
      .issuer-profile h4 { margin: 0 0 16px; font-size: 16px; }
      .issuer-profile-name { font-size: 16px; font-weight: 600; margin-bottom: 4px; }
      .issuer-profile-location, .issuer-profile-hint { color: #657485; font-size: 12px; }
      .issuer-profile-group { margin-top: 14px; }
      .issuer-profile-label { font-size: 11px; font-weight: 600; color: #657485; margin-bottom: 3px; }
      .issuer-profile p { line-height: 1.5; margin-bottom: 0; }
      .issuer-profile-links { margin-top: 14px; font-size: 12px; }
      .issuer-profile-links a { color: #37658a; }
      .issuer-profile .shiny-input-container {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0;
        margin-bottom: 16px;
      }
      .issuer-profile .shiny-input-container label { font-size: 11px; color: #657485; }
      .issuer-profile .form-control, .issuer-profile .form-control:hover {
        border-color: #cbd5df !important;
        box-shadow: none !important;
        font-size: 12px;
        width: 100%;
      }
      .neon-title {
        font-family: 'Arial Black', sans-serif;
        font-size: 32px;
        color: #1E90FF;
        text-shadow:
          -1px -1px 0 black,
           1px -1px 0 black,
          -1px 1px 0 black,
           1px 1px 0 black,
           0 0 4px #1E90FF;
        margin-bottom: 20px;
      }
      .form-control, .selectize-input, .dataTable, .shiny-input-container, .selectize-control {
        background-color: #ffffff !important;
        border-radius: 6px !important;
        border: 1px solid #7da2ce !important;
        box-shadow: 0 0 2px #b0cfff !important;
        padding: 5px;
      }
      .form-control:hover, .btn:hover, .selectize-input:hover, .selectize-input.focus, .dataTable:hover {
        box-shadow: 0 0 5px #b0cfff !important;
        border-color: #4686ff !important;
      }
      .btn {
        background: linear-gradient(to bottom, #e2efff, #b0d2ff);
        border: 1px solid #7da2ce;
        border-radius: 6px;
        color: #003366;
        font-weight: bold;
        text-shadow: 1px 1px #ffffff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      }
      .dataTables_wrapper, table.dataTable td, table.dataTable th {
        color: #222 !important;
        background-color: #ffffff !important;
      }
      ::-webkit-scrollbar-thumb {
        background-color: #c0d3ff;
        border-radius: 10px;
      }
      #download_excel, #download_pdf {
  background: none;
  border: none;
  padding: 6px;
  margin-right: 10px;
      }

#download_excel::before {
  content: url('https://cdn-icons-png.flaticon.com/24/732/732220.png'); /* Excel-Icon */
}

#download_pdf::before {
  content: url('https://cdn-icons-png.flaticon.com/24/337/337946.png'); /* PDF-Icon */
}
    "))
  ),
  
  tags$div(
    class = "neon-title",
    "DZ HYP (Beispiel für einen internen Emittenten) & Markt-Betrachtung (externe Emittenten zum Vergleich)"
  ),
  
  tags$div(
    class = "data-note",
    "*Für die Darstellung wurden ausschließlich Anleihen mit öffentlich verfügbaren Emissionsbedingungen herangezogen."
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "zinsart",
        "Zinsart wählen:",
        choices = zinsarten,
        multiple = TRUE,
        selected = "H"
      ),
      
      sliderInput(
        "laufzeit",
        "Gesamtlaufzeit (Jahre):",
        min = min_lz,
        max = max_lz,
        value = c(min_lz, max_lz)
      ),
      
      selectizeInput(
        "emittenten",
        "Emittent(en) auswählen:",
        choices = emittenten,
        multiple = TRUE,
        selected = c("DZ HYP AG", "AAREAL BANK AG")
      ),
      
      tags$div(
        class = "glass-box",
        
        radioButtons(
          "spread_type",
          "Spread-Typ wählen:",
          choices = c(
            "Asset Swap Spread" = "AssetSwapSpreadMid",
            "REFZS Spread (SCD)" = "REFZS_SPREAD_SCD_BPS"
          ),
          selected = "AssetSwapSpreadMid"
        )
      ),
      tags$section(
        class = "issuer-profile",
        `aria-label` = "Emittentenprofil",
        h4("Emittentenprofil"),
        uiOutput("issuerProfileSelector"),
        uiOutput("issuerProfile")
      )
    ),

        mainPanel(
          fluidRow(
            column(6, tags$div(class = "glass-box", plotlyOutput("spreadPlot"))),
            column(6, tags$div(class = "glass-box", plotlyOutput("renditePlot")))
          ),
          tags$div(class = "glass-box",
                   h4("Detaillierte Tabelle (inkl. Spread + Rendite)"),
                   downloadButton("download_excel", label = NULL),
                   downloadButton("download_pdf", label = NULL),
                   DT::DTOutput("renditeTabelle")
          )
        )
    )
  )


# SERVER

server <- function(input, output, session) {
  # Diese Auswahl steuert ausschließlich das statische Profil.
  profileSelection <- reactiveVal(NULL)
  observeEvent(input$emittenten, {
    selected <- input$emittenten
    profileSelection(if (length(selected)) selected[[1L]] else NULL)
  }, ignoreNULL = FALSE, priority = 10)

  observeEvent(input$profile_emittent, {
    if (input$profile_emittent %in% input$emittenten) {
      profileSelection(input$profile_emittent)
    }
  })

  output$issuerProfileSelector <- renderUI({
    selected <- input$emittenten
    if (length(selected) <= 1L) return(NULL)
    selectInput("profile_emittent", "Profil anzeigen für:",
                choices = selected, selected = selected[[1L]],
                selectize = FALSE, width = "100%")
  })

  profileIssuer <- reactive({
    selected <- input$emittenten
    if (!length(selected)) return(NULL)
    choice <- profileSelection()
    if (length(choice) == 1L && choice %in% selected) choice else selected[[1L]]
  })

  issuerProfile <- reactive({
    issuer <- profileIssuer()
    if (is.null(issuer)) return(NULL)
    issuer_master[issuer_master$Emittent == issuer, , drop = FALSE]
  })

  output$issuerProfile <- renderUI({
    profile <- issuerProfile()
    if (is.null(profile)) {
      return(tags$p(class = "issuer-profile-hint", "Bitte einen Emittenten auswählen."))
    }
    if (!nrow(profile)) {
      return(tags$p(class = "issuer-profile-hint",
                    "Für diesen Emittenten sind derzeit keine Stammdaten hinterlegt."))
    }
    # Fehlende Werte weglassen; Text wird durch Shiny-Tags HTML-escaped.
    value <- function(field) {
      text <- profile[[field]][[1L]]
      if (is.na(text) || !nzchar(trimws(text))) NULL else text
    }
    group <- function(field, label = NULL) {
      text <- value(field)
      if (is.null(text)) return(NULL)
      tags$div(class = "issuer-profile-group",
               if (!is.null(label)) tags$div(class = "issuer-profile-label", label),
               tags$p(text))
    }
    link <- function(field, label) {
      url <- value(field)
      if (is.null(url)) return(NULL)
      tags$a(label, href = url, target = "_blank", rel = "noopener noreferrer")
    }
    links <- Filter(Negate(is.null), list(
      link("Website", "Website"), link("Investor_Relations_URL", "Investor Relations")
    ))
    tagList(
      tags$div(class = "issuer-profile-name", value("Emittent")),
      if (!is.null(value("Sitz")) || !is.null(value("Land")))
        tags$div(class = "issuer-profile-location",
                 paste(c(value("Sitz"), value("Land")), collapse = " · ")),
      group("Institutstyp"),
      group("Geschaeftsmodell", "Geschäftsmodell"),
      group("Funding_Profil", "Funding"),
      group("Kurzprofil"),
      if (length(links)) tags$div(class = "issuer-profile-links",
        if (length(links) == 2L) tagList(links[[1L]], " · ", links[[2L]]) else links[[1L]])
    )
  })
  
  # Reactives 
  
  filteredData <- reactive({
    data <- df_raw %>%
      filter(
        Zinsart %in% input$zinsart,
        `Laufzeit in Jahren` >= input$laufzeit[1],
        `Laufzeit in Jahren` <= input$laufzeit[2]
      )
    if (!is.null(input$emittenten) && length(input$emittenten) > 0) {
      data <- data[data$Emittent %in% input$emittenten, ]
    }
    data
  })
  
  # Nur für den bestehenden Excel-Export; Exportangleichung folgt separat.
  filteredMKT <- reactive({ filteredData() %>% filter(Emittent != "DZ HYP AG") })

  # Detailansicht des gemeinsamen Filterbestands; DT-Suche bleibt tabellenlokal.
  df_detail <- reactive({
    filteredData()[, c("Emittent", "Laufzeit in Jahren",
                       "AssetSwapSpreadMid", "REFZS_SPREAD_SCD_BPS", "Rendite")]
  })
  
# Plots
  output$spreadPlot <- renderPlotly({
    selected_spread <- input$spread_type
    
    combined <- filteredData() %>%
      mutate(Source = if_else(Emittent %in% "DZ HYP AG", "DZ HYP", "Markt"),
             Spread = .data[[selected_spread]])

    title_text <- if (selected_spread == "AssetSwapSpreadMid") {
      "Asset Swap Spread Vergleich"
    } else {
      "REFZS Spread Vergleich"
    }
    
    p <- ggplot(combined, aes(x = `Laufzeit in Jahren`, y = Spread, color = Source, shape = Source,
                              text = paste("Emittent:", Emittent,
                                           "<br>Gesamtlaufzeit (Jahre):", `Laufzeit in Jahren`,
                                           "<br>Spread (bp):", round(Spread, 2)))) +
      geom_point(size = 3, alpha = 0.9) +
      scale_color_manual(values = c("DZ HYP" = "blue", "Markt" = "orange")) +
      scale_shape_manual(values = c("DZ HYP" = 17, "Markt" = 16)) +
      labs(title = title_text, y = "Spread (bps)", x = "Gesamtlaufzeit (Jahre)") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text")
  })
  
  output$renditePlot <- renderPlotly({
    data <- filteredData() %>% filter(!is.na(Rendite))
    p <- ggplot(data, aes(x = `Laufzeit in Jahren`, y = Rendite,
                          text = paste("Emittent:", Emittent,
                                       "<br>Gesamtlaufzeit (Jahre):", `Laufzeit in Jahren`,
                                       "<br>Rendite:", round(Rendite, 3)))) +
      geom_point(color = "purple", size = 3) +
      labs(title = "Renditen ausgewählter Emittenten", y = "Rendite (%)", x = "Gesamtlaufzeit (Jahre)") +
      theme_minimal()
    ggplotly(p, tooltip = "text")
  })
  
#Tabellen
  output$renditeTabelle <- DT::renderDT({
    DT::datatable(df_detail(),
                  colnames = c("Emittent", "Gesamtlaufzeit (Jahre)",
                               "Asset Swap Spread (bp)", "REFZS Spread (bp)", "Rendite (%)"),
                  options = list(pageLength = 5, scrollX = TRUE))
  })
  
  # Excel-Download
  output$download_excel <- downloadHandler(
    filename = function() paste0("Marktvergleich_", Sys.Date(), ".xlsx"),
    content = function(file) {
      openxlsx::write.xlsx(filteredMKT()[, c("Emittent","Laufzeit in Jahren",
                                             "AssetSwapSpreadMid","REFZS_SPREAD_SCD","Rendite")],
                           file, asTable = TRUE)
    }
  )
  
# PDF-Download
  output$download_pdf <- downloadHandler(
    filename    = function() paste0("DZ_HYP_Markt_Tabelle_", Sys.Date(), ".pdf"),
    contentType = "application/pdf",
    content = function(file) {
      
      dat <- filteredData()[, c("Emittent", "Laufzeit in Jahren",
                                "AssetSwapSpreadMid", "REFZS_SPREAD_SCD", "Rendite")]
      dat <- as.data.frame(dat)
  
      dat$Emittent <- stringr::str_wrap(dat$Emittent, width = 32)
      
      # Falls kein Ergebnis: leere PDF mit Hinweis
      if (nrow(dat) == 0) {
        pdf(file, width = 11.69, height = 8.27)  # A4 landscape (inches)
        grid::grid.newpage()
        grid::grid.text("Keine Daten für die gewählten Filter.", gp = grid::gpar(cex = 1.2))
        dev.off()
        return(invisible())
      }
      
      # Mehrseitig: in Blöcke aufteilen
      rows_per_page <- 30
      parts <- split(dat, (seq_len(nrow(dat)) - 1) %/% rows_per_page + 1L)
      
      # PDF starten (A4 landscape)
      pdf(file, width = 11.69, height = 8.27)  # 11.69x8.27 inches
      
      # dezentes Tabellen-Theme
      tt <- gridExtra::ttheme_minimal(
        base_size = 8,
        core = list(fg_params = list(cex = 0.8), padding = unit(c(3,3), "pt")),
        colhead = list(fg_params = list(fontface = "bold"))
      )
      
      # Seiten zeichnen
      for (i in seq_along(parts)) {
        grid::grid.newpage()
        
        title <- grid::textGrob(
          label = sprintf("DZ HYP vs. Markt – Detailtabelle (%s)   |   Seite %d/%d",
                          format(Sys.Date()), i, length(parts)),
          x = 0.5, y = 0.98, gp = grid::gpar(fontsize = 12, fontface = "bold")
        )
        
        tbl  <- gridExtra::tableGrob(parts[[i]], rows = NULL, theme = tt)
        
        page <- gridExtra::arrangeGrob(title, tbl, ncol = 1, heights = c(0.06, 0.94))
        grid::grid.draw(page)
      }
      
      dev.off()
    }
  )
  
}

shinyApp(ui = ui, server = server)
