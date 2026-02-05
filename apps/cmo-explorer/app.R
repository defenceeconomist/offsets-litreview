library(shiny)
library(reactable)
library(dplyr)
library(htmltools)
library(plotly)
library(yaml)

nav_bar <- function(active = "cmo") {
  nav_base <- Sys.getenv("SHINY_NAV_BASE", "localhost:8081")
  nav_url <- function(subdomain) {
    paste0("http://", subdomain, ".", nav_base)
  }
  is_active <- function(name) if (identical(active, name)) "active" else ""

  tags$nav(
    class = "navbar navbar-default",
    tags$div(
      class = "container-fluid",
      tags$div(
        class = "navbar-header",
        tags$span(class = "navbar-brand", "Offsets Explorers")
      ),
      tags$ul(
        class = "nav navbar-nav",
        tags$li(class = is_active("cmo"), tags$a(href = nav_url("cmo"), "CMO Explorer")),
        tags$li(class = is_active("demi"), tags$a(href = nav_url("demi"), "Demi-regularities")),
        tags$li(class = is_active("proto"), tags$a(href = nav_url("proto"), "Proto Mechanisms"))
      )
    )
  )
}

ui <- fluidPage(
  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css?family=Nunito:400,600,700&display=fallback"
    ),
    tags$style(
      HTML(
        ".cmo-explorer {\n",
        "  font-family: Nunito, \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n",
        "  padding: 12px 18px 24px;\n",
        "}\n",
        ".cmo-title {\n",
        "  font-size: 1.5rem;\n",
        "  font-weight: 600;\n",
        "  margin-bottom: 12px;\n",
        "}\n",
        ".cmo-controls {\n",
        "  display: flex;\n",
        "  gap: 12px;\n",
        "  align-items: flex-end;\n",
        "  flex-wrap: wrap;\n",
        "  margin-bottom: 12px;\n",
        "}\n",
        ".cmo-charts {\n",
        "  display: grid;\n",
        "  grid-template-columns: 320px 220px 280px 280px 260px 320px;\n",
        "  gap: 12px;\n",
        "  width: 100%;\n",
        "  margin-bottom: 18px;\n",
        "}\n",
        "@media (max-width: 1400px) {\n",
        "  .cmo-charts {\n",
        "    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));\n",
        "  }\n",
        "}\n",
        ".cmo-chart {\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  background: #fff;\n",
        "  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.06);\n",
        "  padding: 4px 4px 0;\n",
        "}\n",
        ".cmo-table {\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);\n",
        "}\n",
        ".cmo-table-meta {\n",
        "  font-size: 0.9rem;\n",
        "  color: rgba(0, 0, 0, 0.6);\n",
        "  margin: 0 0 6px;\n",
        "}\n",
        ".reactable-search {\n",
        "  display: flex;\n",
        "  align-items: center;\n",
        "  gap: 8px;\n",
        "}\n",
        ".reactable-search .cmo-table-meta {\n",
        "  margin: 0 8px 0 0;\n",
        "}\n",
        ".cmo-header {\n",
        "  background-color: hsl(213, 45%, 97%);\n",
        "  border-bottom-color: hsl(213, 33%, 93%);\n",
        "  color: hsl(213, 13%, 33%);\n",
        "}\n",
        ".cmo-detail {\n",
        "  padding: 18px 24px;\n",
        "  background: hsl(213, 20%, 99%);\n",
        "  box-shadow: inset 0 1px 3px #dbdbdb;\n",
        "}\n",
        ".detail-label {\n",
        "  margin: 10px 0 4px;\n",
        "  font-size: 0.85rem;\n",
        "  color: rgba(0, 0, 0, 0.6);\n",
        "  text-transform: uppercase;\n",
        "  letter-spacing: 0.04em;\n",
        "}\n",
        ".detail-value {\n",
        "  margin: 0 0 6px;\n",
        "  font-size: 0.95rem;\n",
        "}\n",
        ".note {\n",
        "  font-size: 0.85rem;\n",
        "  color: rgba(0, 0, 0, 0.6);\n",
        "}\n"
      )
    ),
    tags$script(
      HTML(
        "$(document).on('shiny:connected', function() {\n",
        "  var moveRowCount = function() {\n",
        "    var meta = $('#row_count');\n",
        "    var search = $('.reactable-search');\n",
        "    if (meta.length && search.length && !search.find('#row_count').length) {\n",
        "      meta.appendTo(search);\n",
        "    }\n",
        "  };\n",
        "  moveRowCount();\n",
        "  $(document).on('reactable:rendered', moveRowCount);\n",
        "});\n"
      )
    )
  ),
  nav_bar("cmo"),
  div(
    class = "cmo-explorer",
    div(class = "cmo-title", "CMO Explorer"),
    div(
      class = "cmo-controls",
      selectInput("file_id", "Filter by file_id", choices = NULL, width = "320px"),
      selectInput("confidence", "Filter by confidence", choices = NULL, width = "220px"),
      selectizeInput(
        "country",
        "Filter by country",
        choices = NULL,
        multiple = TRUE,
        width = "280px",
        options = list(placeholder = "Select one or more")
      ),
      selectizeInput(
        "programme",
        "Filter by programme",
        choices = NULL,
        multiple = TRUE,
        width = "280px",
        options = list(placeholder = "Select one or more")
      ),
      selectInput("evidence_type", "Filter by evidence type", choices = NULL, width = "260px"),
      selectizeInput(
        "research_question",
        "Filter by research question",
        choices = NULL,
        multiple = TRUE,
        width = "320px",
        options = list(placeholder = "Select one or more")
      )
    ),
    div(
      class = "cmo-charts",
      div(class = "cmo-chart", plotlyOutput("chart_file_id", height = "135px")),
      div(class = "cmo-chart", plotlyOutput("chart_confidence", height = "135px")),
      div(class = "cmo-chart", plotlyOutput("chart_country", height = "135px")),
      div(class = "cmo-chart", plotlyOutput("chart_programme", height = "135px")),
      div(class = "cmo-chart", plotlyOutput("chart_evidence_type", height = "135px")),
      div(class = "cmo-chart", plotlyOutput("chart_research_question", height = "135px"))
    ),
    div(
      class = "cmo-table-meta",
      textOutput("row_count", inline = TRUE, container = span)
    ),
    reactableOutput("cmo_table")
  )
)

server <- function(input, output, session) {
  build_theme_map <- function(theme_path) {
    empty <- data.frame(
      chunk_id = character(),
      mechanism_theme_id = character(),
      mechanism_theme = character(),
      mechanism_theme_explanation = character(),
      mechanism_theme_rationale = character(),
      stringsAsFactors = FALSE
    )

    if (!file.exists(theme_path)) {
      return(empty)
    }

    themes <- yaml::read_yaml(theme_path)
    theme_list <- themes$proto_mechanism_themes
    if (is.null(theme_list) || length(theme_list) == 0) {
      return(empty)
    }

    rows <- lapply(theme_list, function(theme) {
      mechs <- theme$mechanisms
      if (is.null(mechs) || length(mechs) == 0) {
        return(NULL)
      }

      ids <- vapply(mechs, function(m) as.character(m$id), character(1))
      rationales <- vapply(mechs, function(m) as.character(m$rationale), character(1))
      data.frame(
        chunk_id = ids,
        mechanism_theme_id = as.character(theme$theme_id),
        mechanism_theme = as.character(theme$theme_label),
        mechanism_theme_explanation = as.character(theme$mechanism_explanation),
        mechanism_theme_rationale = rationales,
        stringsAsFactors = FALSE
      )
    })

    out <- do.call(rbind, rows)
    if (is.null(out)) {
      empty
    } else {
      out
    }
  }

  cmo_data <- utils::read.csv(
    file.path("..", "..", "data", "cmo_statements.csv"),
    stringsAsFactors = FALSE
  )
  theme_map <- build_theme_map(
    file.path("..", "..", "data", "mechanism_themes", "proto_themes.yml")
  )
  cmo_data <- dplyr::left_join(cmo_data, theme_map, by = "chunk_id")

  updateSelectInput(
    session,
    "file_id",
    choices = c("All" = "", sort(unique(cmo_data$file_id)))
  )

  updateSelectInput(
    session,
    "confidence",
    choices = c("All" = "", sort(unique(cmo_data$confidence)))
  )

  split_values <- function(x) {
    values <- strsplit(as.character(x), ";")
    lapply(values, trimws)
  }

  updateSelectizeInput(
    session,
    "country",
    choices = sort(unique(unlist(split_values(cmo_data$country)))),
    server = TRUE
  )

  updateSelectizeInput(
    session,
    "programme",
    choices = sort(unique(unlist(split_values(cmo_data$programme)))),
    server = TRUE
  )

  updateSelectInput(
    session,
    "evidence_type",
    choices = c("All" = "", sort(unique(cmo_data$evidence_type)))
  )

  all_questions <- cmo_data %>%
    mutate(research_questions = strsplit(as.character(research_question_mapped), ";")) %>%
    tidyr::unnest_longer(research_questions) %>%
    mutate(research_questions = trimws(research_questions)) %>%
    filter(!is.na(research_questions), research_questions != "") %>%
    distinct(research_questions) %>%
    arrange(research_questions) %>%
    pull(research_questions)

  updateSelectizeInput(
    session,
    "research_question",
    choices = all_questions,
    server = TRUE
  )

  filtered_data <- reactive({
    data <- cmo_data

    if (!is.null(input$file_id) && input$file_id != "") {
      data <- dplyr::filter(data, file_id == input$file_id)
    }

    if (!is.null(input$confidence) && input$confidence != "") {
      data <- dplyr::filter(data, confidence == input$confidence)
    }

    if (!is.null(input$country) && length(input$country) > 0) {
      data <- data %>%
        mutate(country_value = split_values(country)) %>%
        tidyr::unnest_longer(country_value) %>%
        filter(country_value %in% input$country) %>%
        select(-country_value) %>%
        distinct()
    }

    if (!is.null(input$programme) && length(input$programme) > 0) {
      data <- data %>%
        mutate(programme_value = split_values(programme)) %>%
        tidyr::unnest_longer(programme_value) %>%
        filter(programme_value %in% input$programme) %>%
        select(-programme_value) %>%
        distinct()
    }

    if (!is.null(input$evidence_type) && input$evidence_type != "") {
      data <- dplyr::filter(data, evidence_type == input$evidence_type)
    }

    if (!is.null(input$research_question) && length(input$research_question) > 0) {
      data <- data %>%
        mutate(research_questions = strsplit(as.character(research_question_mapped), ";")) %>%
        tidyr::unnest_longer(research_questions) %>%
        mutate(research_questions = trimws(research_questions)) %>%
        filter(research_questions %in% input$research_question) %>%
        distinct()
    }

    data
  })

  output$row_count <- renderText({
    paste0(nrow(filtered_data()), " rows")
  })

  output$cmo_table <- renderReactable({
    data <- filtered_data()

    get_field <- function(row, name) {
      if (name %in% names(row)) {
        row[[name]]
      } else {
        NA_character_
      }
    }

    details_row <- function(index) {
      row <- data[index, , drop = FALSE]
      tags$div(
        class = "cmo-detail",
        tags$div(class = "detail-label", "File ID"),
        tags$div(class = "detail-value", row$file_id),
        tags$div(class = "detail-label", "Chunk ID"),
        tags$div(class = "detail-value", row$chunk_id),
        tags$div(class = "detail-label", "Evidence Paraphrase"),
        tags$div(class = "detail-value", row$evidence_paraphrase),
        tags$div(class = "detail-label", "Evidence Quote"),
        tags$div(class = "detail-value", row$evidence_quote),
        tags$div(class = "detail-label", "Country"),
        tags$div(class = "detail-value", get_field(row, "country")),
        tags$div(class = "detail-label", "Programme"),
        tags$div(class = "detail-value", get_field(row, "programme")),
        tags$div(class = "detail-label", "Evidence Type"),
        tags$div(class = "detail-value", get_field(row, "evidence_type")),
        tags$div(class = "detail-label", "Evidence Type Narrative"),
        tags$div(class = "detail-value", get_field(row, "evidence_type_narrative")),
        tags$div(class = "detail-label", "Mechanism Theme"),
        tags$div(class = "detail-value", get_field(row, "mechanism_theme")),
        tags$div(class = "detail-label", "Mechanism Explanation"),
        tags$div(class = "detail-value", get_field(row, "mechanism_theme_explanation")),
        tags$div(class = "detail-label", "Theme Rationale"),
        tags$div(class = "detail-value", get_field(row, "mechanism_theme_rationale"))
      )
    }

    reactable(
      data %>%
        select(
          context_statement,
          mechanism_statement,
          mechanism_theme,
          outcome_statement,
          confidence,
          confidience_justification
        ),
      columns = list(
        context_statement = colDef(name = "Context Statement", minWidth = 220),
        mechanism_statement = colDef(name = "Mechanism Statement", minWidth = 220),
        mechanism_theme = colDef(name = "Mechanism Theme", minWidth = 200),
        outcome_statement = colDef(name = "Outcome Statement", minWidth = 220),
        confidence = colDef(name = "Confidence", width = 120),
        confidience_justification = colDef(name = "Confidence Justification", minWidth = 240)
      ),
      details = details_row,
      onClick = "expand",
      resizable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      defaultPageSize = 15,
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 15, 30, 50),
      class = "cmo-table",
      rowStyle = list(cursor = "pointer"),
      defaultColDef = colDef(headerClass = "cmo-header"),
      wrap = TRUE
    )
  })

  count_single <- function(data, field) {
    data %>%
      dplyr::count(.data[[field]], sort = TRUE) %>%
      dplyr::rename(label = 1, n = n) %>%
      mutate(label = as.character(label)) %>%
      filter(!is.na(label), label != "")
  }

  count_multi <- function(data, field) {
    data %>%
      mutate(value = split_values(.data[[field]])) %>%
      tidyr::unnest_longer(value) %>%
      mutate(value = trimws(value)) %>%
      filter(!is.na(value), value != "") %>%
      count(value, sort = TRUE) %>%
      rename(label = value, n = n)
  }

  render_count_chart <- function(df) {
    if (nrow(df) == 0) {
      return(plot_ly())
    }

    df <- df %>%
      mutate(label = factor(label, levels = label))

    plot_ly(
      df,
      x = ~label,
      y = ~n,
      type = "bar",
      hovertemplate = "%{x}<br>%{y} items<extra></extra>"
    ) %>%
      layout(
        margin = list(l = 10, r = 10, t = 40, b = 10),
        xaxis = list(
          title = "",
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE,
          showline = FALSE
        ),
        yaxis = list(
          title = "",
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE,
          showline = FALSE,
          rangemode = "tozero"
        )
      ) %>%
      config(displayModeBar = FALSE, displaylogo = FALSE)
  }

  output$chart_file_id <- renderPlotly({
    render_count_chart(count_single(filtered_data(), "file_id"))
  })

  output$chart_confidence <- renderPlotly({
    render_count_chart(count_single(filtered_data(), "confidence"))
  })

  output$chart_country <- renderPlotly({
    render_count_chart(count_multi(filtered_data(), "country"))
  })

  output$chart_programme <- renderPlotly({
    render_count_chart(count_multi(filtered_data(), "programme"))
  })

  output$chart_evidence_type <- renderPlotly({
    render_count_chart(count_single(filtered_data(), "evidence_type"))
  })

  output$chart_research_question <- renderPlotly({
    data <- filtered_data()
    field_name <- if ("research_question_mapped" %in% names(data)) {
      "research_question_mapped"
    } else if ("research_questions_mapped" %in% names(data)) {
      "research_questions_mapped"
    } else {
      NULL
    }

    if (is.null(field_name)) {
      render_count_chart(dplyr::tibble(label = character(), n = integer()))
    } else {
      render_count_chart(count_multi(data, field_name))
    }
  })
}

shinyApp(ui, server)
