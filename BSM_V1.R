# Einziger aktiver App-Einstieg: shiny::runApp("BSM_V1.R")
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(grid)

source("R/data.R", local = TRUE, encoding = "UTF-8")
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
        background-size: 600% 600%;
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
  
  tags$div(class = "neon-title", "DZ HYP & Markt Betrachtung"),
 
      sidebarLayout(
        sidebarPanel(
          selectInput("zinsart", "Zinsart wählen:", choices = zinsarten, multiple = TRUE, selected = "H"),
          sliderInput("laufzeit", "Gesamtlaufzeit (Jahre):", min = min_lz, max = max_lz, value = c(min_lz, max_lz)),
          selectizeInput("emittenten", "Emittent(en) auswählen:", choices = emittenten, multiple = TRUE, selected = c("DZ HYP AG", "AAREAL BANK AG")),
          tags$div(class = "glass-box",
                   radioButtons("spread_type", "Spread-Typ wählen:",
                                choices = c("Asset Swap Spread" = "AssetSwapSpreadMid",
                                            "REFZS Spread (SCD)" = "REFZS_SPREAD_SCD_BPS"),
                                selected = "AssetSwapSpreadMid")
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
