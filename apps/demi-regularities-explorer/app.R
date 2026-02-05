library(shiny)
library(reactable)
library(dplyr)
library(htmltools)
library(tibble)
library(yaml)

nav_bar <- function(active = "demi") {
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
        ".demi-explorer {\n",
        "  font-family: Nunito, \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n",
        "  padding: 16px 18px 28px;\n",
        "}\n",
        ".demi-title {\n",
        "  font-size: 1.5rem;\n",
        "  font-weight: 600;\n",
        "  margin-bottom: 12px;\n",
        "}\n",
        ".demi-controls {\n",
        "  display: flex;\n",
        "  gap: 12px;\n",
        "  align-items: flex-end;\n",
        "  flex-wrap: wrap;\n",
        "  margin-bottom: 12px;\n",
        "}\n",
        ".demi-summary {\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 8px;\n",
        "  background: hsl(213, 45%, 97%);\n",
        "  padding: 12px 16px;\n",
        "  margin-bottom: 12px;\n",
        "  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.06);\n",
        "}\n",
        ".summary-title {\n",
        "  font-size: 1rem;\n",
        "  font-weight: 600;\n",
        "  margin-bottom: 6px;\n",
        "}\n",
        ".summary-text {\n",
        "  font-size: 0.95rem;\n",
        "  margin: 0 0 8px;\n",
        "}\n",
        ".summary-grid {\n",
        "  display: grid;\n",
        "  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));\n",
        "  gap: 8px;\n",
        "  margin-bottom: 8px;\n",
        "}\n",
        ".summary-pill {\n",
        "  background: #fff;\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  padding: 6px 8px;\n",
        "  font-size: 0.85rem;\n",
        "}\n",
        ".summary-label {\n",
        "  text-transform: uppercase;\n",
        "  letter-spacing: 0.04em;\n",
        "  color: rgba(0, 0, 0, 0.55);\n",
        "  font-size: 0.7rem;\n",
        "}\n",
        ".summary-value {\n",
        "  font-weight: 600;\n",
        "  margin-top: 2px;\n",
        "}\n",
        ".demi-meta {\n",
        "  font-size: 0.9rem;\n",
        "  color: rgba(0, 0, 0, 0.6);\n",
        "  margin: 0 0 8px;\n",
        "}\n",
        ".demi-table {\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);\n",
        "}\n",
        ".demi-header {\n",
        "  background-color: hsl(213, 45%, 97%);\n",
        "  border-bottom-color: hsl(213, 33%, 93%);\n",
        "  color: hsl(213, 13%, 33%);\n",
        "}\n",
        ".demi-detail {\n",
        "  padding: 16px 20px;\n",
        "  background: hsl(213, 20%, 99%);\n",
        "  box-shadow: inset 0 1px 3px #dbdbdb;\n",
        "}\n",
        ".detail-title {\n",
        "  font-size: 1rem;\n",
        "  font-weight: 600;\n",
        "  margin: 0 0 8px;\n",
        "}\n",
        ".detail-statement {\n",
        "  font-size: 0.95rem;\n",
        "  margin: 0 0 10px;\n",
        "}\n",
        ".detail-section {\n",
        "  margin-bottom: 10px;\n",
        "}\n",
        ".detail-label {\n",
        "  font-size: 0.75rem;\n",
        "  text-transform: uppercase;\n",
        "  letter-spacing: 0.04em;\n",
        "  color: rgba(0, 0, 0, 0.55);\n",
        "  margin-bottom: 4px;\n",
        "}\n",
        ".detail-card {\n",
        "  padding: 8px 10px;\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  background: #fff;\n",
        "  margin-bottom: 8px;\n",
        "}\n",
        ".detail-id {\n",
        "  font-size: 0.8rem;\n",
        "  color: rgba(0, 0, 0, 0.55);\n",
        "  margin-bottom: 4px;\n",
        "}\n",
        ".detail-note {\n",
        "  font-size: 0.9rem;\n",
        "  margin: 0;\n",
        "}\n",
        ".detail-empty {\n",
        "  font-size: 0.85rem;\n",
        "  color: rgba(0, 0, 0, 0.55);\n",
        "  margin: 0;\n",
        "}\n",
        ".detail-list {\n",
        "  margin: 0;\n",
        "  padding-left: 18px;\n",
        "}\n",
        ".confidence-pill {\n",
        "  display: inline-block;\n",
        "  padding: 2px 8px;\n",
        "  border-radius: 999px;\n",
        "  font-size: 0.75rem;\n",
        "  font-weight: 600;\n",
        "  text-transform: uppercase;\n",
        "  background: hsl(213, 45%, 94%);\n",
        "  color: hsl(213, 40%, 35%);\n",
        "}\n"
      )
    )
  ),
  nav_bar("demi"),
  div(
    class = "demi-explorer",
    div(class = "demi-title", "Demi-Regularities Explorer"),
    div(
      class = "demi-controls",
      selectizeInput(
        "theme_id",
        "Filter by theme",
        choices = NULL,
        multiple = TRUE,
        width = "360px",
        options = list(placeholder = "Select theme(s)")
      ),
      selectInput("confidence", "Filter by confidence", choices = NULL, width = "220px")
    ),
    uiOutput("theme_summary"),
    div(class = "demi-meta", textOutput("row_count", inline = TRUE, container = span)),
    reactableOutput("demi_table")
  )
)

server <- function(input, output, session) {
  `%||%` <- function(x, fallback) {
    if (is.null(x)) fallback else x
  }

  safe_chr <- function(x) {
    if (is.null(x)) NA_character_ else as.character(x)
  }

  safe_vec <- function(x) {
    if (is.null(x)) character() else as.character(x)
  }

  build_demi_data <- function(base_dir) {
    empty_demi <- tibble(
      theme_id = character(),
      theme_label = character(),
      mechanism_explanation = character(),
      demi_regularity_id = character(),
      statement = character(),
      context_conditions = list(),
      outcome_tendencies = list(),
      supporting_cmo_ids = list(),
      anchor_quotes = list(),
      moderators = list(),
      boundary_conditions = list(),
      counterexamples = list(),
      confidence = character(),
      confidence_justification = character(),
      cmo_ids_in_theme = list(),
      missing_cmo_ids = list(),
      theme_notes = list(),
      suggested_quarto_note = list()
    )

    empty_themes <- tibble(
      theme_id = character(),
      theme_label = character(),
      mechanism_explanation = character(),
      demi_count = integer(),
      cmo_count = integer(),
      missing_cmo_count = integer(),
      cmo_ids_in_theme = list(),
      missing_cmo_ids = list(),
      theme_notes = list(),
      suggested_quarto_note = list()
    )

    files <- list.files(base_dir, pattern = "^demi_regularities_.*\\.yml$", full.names = TRUE)
    if (length(files) == 0) {
      return(list(demi = empty_demi, themes = empty_themes))
    }

    demi_rows <- list()
    theme_rows <- list()

    for (path in files) {
      doc <- yaml::read_yaml(path)
      theme_list <- doc$demi_regularities_by_theme
      if (is.null(theme_list) || length(theme_list) == 0) {
        next
      }

      for (theme in theme_list) {
        demi_list <- theme$demi_regularities %||% list()
        theme_rows[[length(theme_rows) + 1]] <- tibble(
          theme_id = safe_chr(theme$theme_id),
          theme_label = safe_chr(theme$theme_label),
          mechanism_explanation = safe_chr(theme$mechanism_explanation),
          demi_count = length(demi_list),
          cmo_count = length(safe_vec(theme$cmo_ids_in_theme)),
          missing_cmo_count = length(safe_vec(theme$missing_cmo_ids)),
          cmo_ids_in_theme = list(safe_vec(theme$cmo_ids_in_theme)),
          missing_cmo_ids = list(safe_vec(theme$missing_cmo_ids)),
          theme_notes = list(safe_vec(theme$theme_notes)),
          suggested_quarto_note = list(theme$suggested_quarto_note)
        )

        if (length(demi_list) == 0) {
          next
        }

        for (demi in demi_list) {
          demi_rows[[length(demi_rows) + 1]] <- tibble(
            theme_id = safe_chr(theme$theme_id),
            theme_label = safe_chr(theme$theme_label),
            mechanism_explanation = safe_chr(theme$mechanism_explanation),
            demi_regularity_id = safe_chr(demi$demi_regularity_id),
            statement = safe_chr(demi$statement),
            context_conditions = list(safe_vec(demi$context_conditions)),
            outcome_tendencies = list(safe_vec(demi$outcome_tendencies)),
            supporting_cmo_ids = list(safe_vec(demi$supporting_cmo_ids)),
            anchor_quotes = list(demi$anchor_quotes %||% list()),
            moderators = list(demi$moderators %||% list()),
            boundary_conditions = list(demi$boundary_conditions %||% list()),
            counterexamples = list(demi$counterexamples %||% list()),
            confidence = safe_chr(demi$confidence),
            confidence_justification = safe_chr(demi$confidence_justification),
            cmo_ids_in_theme = list(safe_vec(theme$cmo_ids_in_theme)),
            missing_cmo_ids = list(safe_vec(theme$missing_cmo_ids)),
            theme_notes = list(safe_vec(theme$theme_notes)),
            suggested_quarto_note = list(theme$suggested_quarto_note)
          )
        }
      }
    }

    list(
      demi = if (length(demi_rows) == 0) empty_demi else bind_rows(demi_rows),
      themes = if (length(theme_rows) == 0) empty_themes else bind_rows(theme_rows)
    )
  }

  data <- build_demi_data(file.path("..", "..", "data", "mechanism_themes"))

  demi_data <- data$demi %>%
    mutate(
      supporting_cmo_count = vapply(supporting_cmo_ids, length, integer(1)),
      anchor_quote_count = vapply(anchor_quotes, length, integer(1)),
      moderator_count = vapply(moderators, length, integer(1)),
      boundary_count = vapply(boundary_conditions, length, integer(1)),
      counterexample_count = vapply(counterexamples, length, integer(1))
    )

  theme_data <- data$themes %>%
    arrange(theme_id)

  theme_choices <- if (nrow(theme_data) == 0) {
    character()
  } else {
    setNames(theme_data$theme_id, paste0(theme_data$theme_id, " - ", theme_data$theme_label))
  }

  updateSelectizeInput(
    session,
    "theme_id",
    choices = theme_choices,
    server = TRUE
  )

  confidence_choices <- sort(unique(na.omit(demi_data$confidence)))
  updateSelectInput(
    session,
    "confidence",
    choices = c("All", confidence_choices),
    selected = "All"
  )

  filtered_data <- reactive({
    data <- demi_data

    if (!is.null(input$theme_id) && length(input$theme_id) > 0) {
      data <- data %>% filter(.data$theme_id %in% input$theme_id)
    }

    if (!is.null(input$confidence) && input$confidence != "All") {
      data <- data %>% filter(.data$confidence == input$confidence)
    }

    data %>% arrange(.data$theme_id, .data$demi_regularity_id)
  })

  output$row_count <- renderText({
    paste0(nrow(filtered_data()), " demi-regularities")
  })

  output$theme_summary <- renderUI({
    if (is.null(input$theme_id) || length(input$theme_id) != 1) {
      return(
        div(
          class = "demi-summary",
          div(class = "summary-title", "Theme overview"),
          div(class = "summary-text", "Select a single theme to view summary details.")
        )
      )
    }

    theme <- theme_data %>% filter(.data$theme_id == input$theme_id)
    if (nrow(theme) == 0) {
      return(NULL)
    }

    note <- theme$suggested_quarto_note[[1]]
    note_path <- if (!is.null(note) && !is.null(note$path)) as.character(note$path) else NA_character_
    note_outline <- if (!is.null(note) && !is.null(note$outline)) as.character(note$outline) else character()

    div(
      class = "demi-summary",
      div(class = "summary-title", paste0(theme$theme_id, " - ", theme$theme_label)),
      div(class = "summary-text", theme$mechanism_explanation),
      div(
        class = "summary-grid",
        div(
          class = "summary-pill",
          div(class = "summary-label", "Demi-regularities"),
          div(class = "summary-value", theme$demi_count)
        ),
        div(
          class = "summary-pill",
          div(class = "summary-label", "CMO IDs"),
          div(class = "summary-value", theme$cmo_count)
        ),
        div(
          class = "summary-pill",
          div(class = "summary-label", "Missing CMO IDs"),
          div(class = "summary-value", theme$missing_cmo_count)
        )
      ),
      if (length(theme$theme_notes[[1]]) > 0) {
        tagList(
          div(class = "detail-label", "Theme notes"),
          tags$ul(
            class = "detail-list",
            lapply(theme$theme_notes[[1]], tags$li)
          )
        )
      },
      if (!is.na(note_path)) {
        tagList(
          div(class = "detail-label", "Suggested quarto note"),
          div(class = "detail-note", paste0("Path: ", note_path)),
          if (length(note_outline) > 0) {
            tags$ul(
              class = "detail-list",
              lapply(note_outline, tags$li)
            )
          }
        )
      }
    )
  })

  build_list_section <- function(label, values) {
    if (length(values) == 0) {
      return(
        div(
          class = "detail-section",
          div(class = "detail-label", label),
          div(class = "detail-empty", "None noted")
        )
      )
    }

    div(
      class = "detail-section",
      div(class = "detail-label", label),
      tags$ul(class = "detail-list", lapply(values, tags$li))
    )
  }

  build_support_section <- function(label, values) {
    if (length(values) == 0) {
      return(NULL)
    }

    div(
      class = "detail-note",
      paste0(label, ": ", paste(values, collapse = ", "))
    )
  }

  build_cards_section <- function(label, items, renderer) {
    if (length(items) == 0) {
      return(
        div(
          class = "detail-section",
          div(class = "detail-label", label),
          div(class = "detail-empty", "None noted")
        )
      )
    }

    div(
      class = "detail-section",
      div(class = "detail-label", label),
      tagList(lapply(items, renderer))
    )
  }

  output$demi_table <- renderReactable({
    data <- filtered_data()

    details_row <- function(index) {
      row <- data[index, ]

      tags$div(
        class = "demi-detail",
        tags$div(
          class = "detail-title",
          paste0(row$demi_regularity_id, " - ", row$theme_id)
        ),
        tags$div(
          class = "detail-statement",
          row$statement
        ),
        build_list_section("Context conditions", row$context_conditions[[1]]),
        build_list_section("Outcome tendencies", row$outcome_tendencies[[1]]),
        build_list_section("Supporting CMO IDs", row$supporting_cmo_ids[[1]]),
        build_cards_section(
          "Anchor quotes",
          row$anchor_quotes[[1]],
          function(item) {
            tags$div(
              class = "detail-card",
              tags$div(class = "detail-id", safe_chr(item$cmo_id)),
              tags$p(class = "detail-note", safe_chr(item$quote))
            )
          }
        ),
        build_cards_section(
          "Moderators",
          row$moderators[[1]],
          function(item) {
            tags$div(
              class = "detail-card",
              tags$div(class = "detail-note", safe_chr(item$condition)),
              tags$div(class = "detail-id", paste0("Effect: ", safe_chr(item$effect))),
              build_support_section("Supporting CMO IDs", safe_vec(item$supporting_cmo_ids))
            )
          }
        ),
        build_cards_section(
          "Boundary conditions",
          row$boundary_conditions[[1]],
          function(item) {
            tags$div(
              class = "detail-card",
              tags$div(class = "detail-note", safe_chr(item$condition)),
              build_support_section("Supporting CMO IDs", safe_vec(item$supporting_cmo_ids))
            )
          }
        ),
        build_cards_section(
          "Counterexamples",
          row$counterexamples[[1]],
          function(item) {
            tags$div(
              class = "detail-card",
              tags$div(class = "detail-id", safe_chr(item$cmo_id)),
              tags$div(class = "detail-note", safe_chr(item$note))
            )
          }
        ),
        if (!is.na(row$confidence_justification)) {
          div(
            class = "detail-section",
            div(class = "detail-label", "Confidence justification"),
            div(class = "detail-note", row$confidence_justification)
          )
        }
      )
    }

    reactable(
      data %>%
        select(
          theme_id,
          theme_label,
          demi_regularity_id,
          statement,
          confidence,
          supporting_cmo_count,
          anchor_quote_count
        ),
      columns = list(
        theme_id = colDef(name = "Theme ID", width = 110),
        theme_label = colDef(name = "Theme label", minWidth = 200),
        demi_regularity_id = colDef(name = "Demi-regularity ID", width = 160),
        statement = colDef(name = "Statement", minWidth = 320),
        confidence = colDef(
          name = "Confidence",
          width = 120,
          align = "center",
          cell = function(value) {
            if (is.na(value) || value == "") {
              return("")
            }
            tags$span(class = "confidence-pill", value)
          }
        ),
        supporting_cmo_count = colDef(name = "Supporting CMOs", width = 150, align = "right"),
        anchor_quote_count = colDef(name = "Anchor quotes", width = 140, align = "right")
      ),
      details = details_row,
      onClick = "expand",
      resizable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      defaultPageSize = 20,
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 20, 40, 80),
      class = "demi-table",
      rowStyle = list(cursor = "pointer"),
      defaultColDef = colDef(headerClass = "demi-header"),
      wrap = TRUE
    )
  })
}

shinyApp(ui, server)
