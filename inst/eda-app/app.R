# Shiny dashboard using packaged data object `Data` (no read.csv)
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

# Load dataset directly from your package
data("Data", package = "Rpackage")

# Clean/order for plotting
Data <- Data |>
  mutate(
    category  = factor(category, levels = c("HAP","SSI","BSI","UTI","CDI")),
    component = factor(component, levels = c("YLD","YLL"))
  )

components <- levels(Data$component)

# ===== Theme =====
crimson_theme <- bs_theme(
  version = 5,
  base_font = font_google("DM Sans"),
  heading_font = font_google("Playfair Display"),
  primary = "#991b1b",
  secondary = "#7f1d1d",
  bg = "#f9fafb",
  fg = "#16181d"
)

# ===== UI =====
ui <- page_fluid(
  theme = crimson_theme,
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "www/styles.css")),

  div(class = "app-header", h4("DALY Dashboard — Infections")),

  navset_tab(
    # ---- CHART TAB ----
    nav(
      "Chart",
      layout_columns(
        col_widths = c(8, 4),

        # Left: Plot card
        card(
          card_header(
            "DALYs per 100,000 by Infection Type",
            downloadButton("dl_png", "Download Plot (PNG)", class = "btn btn-sm btn-primary")
          ),
          plotlyOutput("p", height = 520)
        ),

        # Right: Filters card
        card(
          card_header("Filters"),
          checkboxGroupInput(
            "component", "Component (DALY type)",
            choices = components, selected = components, inline = TRUE
          ),
          radioButtons(
            "position", "Bar mode",
            choices = c("Stacked" = "stack", "Side-by-side" = "dodge"),
            selected = "stack", inline = TRUE
          ),
          checkboxInput("show_err", "Show error bars", value = TRUE)
        )
      ),

      # Below both: Explanation card
      div(class = "app-card", style = "margin-top: 16px;",
          h5("What you’re seeing"),
          accordion(
            open = c("fields","interpret"),
            accordion_panel(
              "Data fields", value = "fields",
              tags$ul(
                tags$li(tags$b("group:"), " study source (German PPS vs ECDC PPS)."),
                tags$li(tags$b("category:"), " infection type (HAP, SSI, BSI, UTI, CDI)."),
                tags$li(tags$b("component:"), " DALY component — ",
                        tags$b("YLD"), " (Years Lived with Disability) or ",
                        tags$b("YLL"), " (Years of Life Lost)."),
                tags$li(tags$b("value:"), " DALYs per 100,000 population for each component."),
                tags$li(tags$b("se:"), " uncertainty for the ",
                        tags$b("stacked total"), " (used for error bars when enabled).")
              )
            ),
            accordion_panel(
              "How to interpret the chart", value = "interpret",
              tags$ul(
                tags$li("Bars are grouped by infection type and faceted by study group."),
                tags$li(tags$b("Stacked:"), " YLD and YLL add to a total height; error bars show ± SE."),
                tags$li(tags$b("Side-by-side:"), " YLD and YLL appear next to each other; SE hidden."),
                tags$li("Color coding: ", tags$b("orange = YLD"), ", ",
                        tags$b("blue = YLL"), " — compare proportions for burden balance.")
              )
            )
          )
      )
    ),

    # ---- DATA TAB ----
    nav(
      "Data",
      card(
        card_header("Filtered data"),
        div(class = "app-card",
            p("This table reflects current filter selections.")
        ),
        DTOutput("tbl")
      )
    )
  ),

  div(class = "footer", "© 2025 Bhuvana Chandrashekar — DALY Dashboard for ETC5523")
)

# ===== SERVER =====
server <- function(input, output, session){

  filtered <- reactive({
    Data |> filter(component %in% input$component)
  })

  totals <- reactive({
    filtered() |>
      group_by(group, category) |>
      summarise(total = sum(value), se = first(se), .groups = "drop") |>
      mutate(ymin = pmax(0, total - se), ymax = total + se)
  })

  base_plot <- reactive({
    df  <- filtered()
    pos <- if (input$position == "stack") "stack" else "dodge"
    pal <- c(YLD = "#d08b3e", YLL = "#9bc7df")

    p <- ggplot(df, aes(x = category, y = value, fill = component)) +
      geom_col(position = pos, width = 0.7, color = "grey20") +
      scale_fill_manual(values = pal, name = NULL) +
      labs(x = NULL, y = "DALYs per 100,000") +
      facet_wrap(~ group, nrow = 1) +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "top",
        panel.grid.major.x = element_blank(),
        strip.text = element_text(face = "bold", color = "#991b1b"),
        axis.text.x = element_text(size = 12)
      )

    if (input$show_err && input$position == "stack") {
      p <- p +
        geom_errorbar(
          data = totals(),
          aes(x = category, ymin = ymin, ymax = ymax, group = category),
          width = 0.15, inherit.aes = FALSE
        )
    }
    p
  })

  output$p <- renderPlotly({
    ggplotly(base_plot(), tooltip = c("x","y","fill")) |>
      layout(legend = list(orientation = "h", x = 0, y = 1.12))
  })

  output$tbl <- renderDT({
    filtered() |>
      arrange(group, category, component) |>
      datatable(
        options = list(pageLength = 10, dom = "tip"),
        rownames = FALSE
      )
  })

  output$dl_png <- downloadHandler(
    filename = function() paste0("daly-bars-", Sys.Date(), ".png"),
    content  = function(file){
      g <- base_plot()
      ggsave(file, g, width = 9.5, height = 4.8, dpi = 300)
    }
  )
}

# ===== RUN APP =====
shinyApp(ui, server)
