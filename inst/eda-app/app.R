# Shiny dashboard using packaged data object `Data` (no read.csv)
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

# Load the dataset directly from your package
data("Data", package = "DALY")    # <-- replace Rpackage with your package name

# Clean/order for plotting
Data <- Data |>
  mutate(
    category  = factor(category, levels = c("HAP","SSI","BSI","UTI","CDI")),
    component = factor(component, levels = c("YLD","YLL"))
  )

components <- levels(Data$component)

# ===== Theme + small custom CSS (crimson, cardy) =====
crimson_theme <- bs_theme(
  version = 5,
  base_font = font_google("DM Sans"),
  heading_font = font_google("Playfair Display"),
  primary = "#991b1b",
  secondary = "#7f1d1d",
  bg = "#f9fafb",
  fg = "#16181d"
)

extra_css <- HTML("
  .app-header{
    background: linear-gradient(135deg, #3a0000, #991b1b);
    color:#fff; padding: 14px 18px; border-radius: 12px;
    box-shadow: 0 8px 18px rgba(58,0,0,.25); margin-bottom: 16px;
  }
  .app-card{
    background: #ffffff; border-radius: 14px; padding: 16px 18px;
    box-shadow: 0 10px 24px rgba(0,0,0,.08); border-top: 4px solid #991b1b;
  }
  .accordion-button:not(.collapsed){ color:#991b1b; background:#fff5f5; }
  .form-check-inline .form-check-input{ margin-top: 6px; }
")

# ===== UI =====
ui <- page_fluid(
  theme = crimson_theme,
  tags$head(tags$style(extra_css)),

  div(class = "app-header", h4("DALY Dashboard — Infections")),

  navset_tab(
    # ---- CHART TAB ----
    nav(
      "Chart",
      layout_columns(
        col_widths = c(8, 4),

        # Left: Plot card
        card(
          card_header("DALYs per 100,000 by Infection Type",
                      downloadButton("dl_png", "Download Plot (PNG)", class = "btn btn-sm btn-primary", style = "float:right;")),
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
                tags$li(tags$b("value:"), " DALYs per 100,000 population for the component."),
                tags$li(tags$b("se:"), " uncertainty for the ", tags$b("stacked total"),
                        " (used to draw error bars when enabled).")
              )
            ),
            accordion_panel(
              "How to read this chart", value = "interpret",
              tags$ul(
                tags$li("Bars are shown ", tags$b("by infection type"),
                        " and faceted ", tags$b("by study group"), "."),
                tags$li(tags$b("Stacked"), ": YLD and YLL add to a total height; the error bar shows total ± SE."),
                tags$li(tags$b("Side-by-side"), ": YLD and YLL appear next to each other; error bars are hidden (SE is for totals)."),
                tags$li("Compare the ", tags$b("colors"),
                        " to see burden split (orange = YLD, blue = YLL).")
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
            p("This table reflects the current filter selections (Component & Bar mode do not change values).")
        ),
        DTOutput("tbl")
      )
    )
  )
)

# ===== Server =====
server <- function(input, output, session){

  filtered <- reactive({
    Data |> filter(component %in% input$component)
  })

  totals <- reactive({
    filtered() |>
      group_by(group, category) |>
      summarise(total = sum(value), se = dplyr::first(se), .groups = "drop") |>
      mutate(ymin = pmax(0, total - se), ymax = total + se)
  })

  base_plot <- reactive({
    df  <- filtered()
    pos <- if (input$position == "stack") "stack" else "dodge"
    pal <- c(YLD = "#d08b3e", YLL = "#9bc7df")  # warm brown + cool blue

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

shinyApp(ui, server)
