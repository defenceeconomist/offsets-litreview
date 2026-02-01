library(shiny)
library(reactable)
library(dplyr)
library(htmltools)
library(tibble)
library(yaml)

ui <- fluidPage(
  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css?family=Nunito:400,600,700&display=fallback"
    ),
    tags$style(
      HTML(
        ".proto-explorer {\n",
        "  font-family: Nunito, \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n",
        "  padding: 16px 18px 24px;\n",
        "}\n",
        ".proto-title {\n",
        "  font-size: 1.4rem;\n",
        "  font-weight: 600;\n",
        "  margin-bottom: 12px;\n",
        "}\n",
        ".proto-meta {\n",
        "  font-size: 0.9rem;\n",
        "  color: rgba(0, 0, 0, 0.6);\n",
        "  margin: 0 0 8px;\n",
        "}\n",
        ".proto-table {\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);\n",
        "}\n",
        ".proto-header {\n",
        "  background-color: hsl(213, 45%, 97%);\n",
        "  border-bottom-color: hsl(213, 33%, 93%);\n",
        "  color: hsl(213, 13%, 33%);\n",
        "}\n",
        ".proto-detail {\n",
        "  padding: 16px 20px;\n",
        "  background: hsl(213, 20%, 99%);\n",
        "  box-shadow: inset 0 1px 3px #dbdbdb;\n",
        "}\n",
        ".detail-title {\n",
        "  font-size: 0.95rem;\n",
        "  font-weight: 600;\n",
        "  margin: 0 0 10px;\n",
        "}\n",
        ".detail-card {\n",
        "  padding: 10px 12px;\n",
        "  border: 1px solid hsl(213, 33%, 93%);\n",
        "  border-radius: 6px;\n",
        "  background: #fff;\n",
        "  margin-bottom: 10px;\n",
        "}\n",
        ".detail-id {\n",
        "  font-size: 0.8rem;\n",
        "  color: rgba(0, 0, 0, 0.55);\n",
        "  margin-bottom: 6px;\n",
        "}\n",
        ".detail-text {\n",
        "  font-size: 0.95rem;\n",
        "  margin: 0 0 8px;\n",
        "}\n",
        ".detail-rationale-label {\n",
        "  font-size: 0.75rem;\n",
        "  text-transform: uppercase;\n",
        "  letter-spacing: 0.04em;\n",
        "  color: rgba(0, 0, 0, 0.55);\n",
        "  margin-bottom: 3px;\n",
        "}\n",
        ".detail-rationale {\n",
        "  font-size: 0.9rem;\n",
        "  margin: 0;\n",
        "}\n"
      )
    )
  ),
  div(
    class = "proto-explorer",
    div(class = "proto-title", "Proto Mechanism Themes"),
    div(class = "proto-meta", textOutput("row_count", inline = TRUE, container = span)),
    reactableOutput("theme_table")
  )
)

server <- function(input, output, session) {
  build_theme_table <- function(theme_path) {
    empty <- tibble(
      theme_id = character(),
      theme_label = character(),
      mechanism_explanation = character(),
      mechanism_count = integer(),
      mechanisms = list()
    )

    if (!file.exists(theme_path)) {
      return(empty)
    }

    themes <- yaml::read_yaml(theme_path)
    theme_list <- themes$proto_mechanism_themes
    if (is.null(theme_list) || length(theme_list) == 0) {
      return(empty)
    }

    safe_field <- function(item, field) {
      value <- item[[field]]
      if (is.null(value)) {
        NA_character_
      } else {
        as.character(value)
      }
    }

    rows <- lapply(theme_list, function(theme) {
      mechs <- theme$mechanisms
      if (is.null(mechs)) {
        mechs <- list()
      }

      mech_df <- tibble(
        id = vapply(mechs, safe_field, field = "id", FUN.VALUE = character(1)),
        text = vapply(mechs, safe_field, field = "text", FUN.VALUE = character(1)),
        rationale = vapply(mechs, safe_field, field = "rationale", FUN.VALUE = character(1))
      )

      tibble(
        theme_id = as.character(theme$theme_id),
        theme_label = as.character(theme$theme_label),
        mechanism_explanation = as.character(theme$mechanism_explanation),
        mechanism_count = nrow(mech_df),
        mechanisms = list(mech_df)
      )
    })

    dplyr::bind_rows(rows)
  }

  theme_data <- build_theme_table(
    file.path("..", "..", "data", "mechanism_themes", "proto_themes.yml")
  ) %>%
    arrange(desc(mechanism_count), theme_label)

  output$row_count <- renderText({
    paste0(nrow(theme_data), " themes")
  })

  output$theme_table <- renderReactable({
    details_row <- function(index) {
      mechs <- theme_data$mechanisms[[index]]

      if (nrow(mechs) == 0) {
        return(tags$div(class = "proto-detail", "No mechanisms allocated."))
      }

      tags$div(
        class = "proto-detail",
        tags$div(
          class = "detail-title",
          paste0("Mechanisms (", nrow(mechs), ")")
        ),
        tagList(
          lapply(seq_len(nrow(mechs)), function(i) {
            tags$div(
              class = "detail-card",
              tags$div(class = "detail-id", mechs$id[i]),
              tags$div(class = "detail-text", mechs$text[i]),
              tags$div(class = "detail-rationale-label", "Rationale"),
              tags$div(class = "detail-rationale", mechs$rationale[i])
            )
          })
        )
      )
    }

    reactable(
      theme_data %>%
        select(theme_id, theme_label, mechanism_explanation, mechanism_count),
      columns = list(
        theme_id = colDef(name = "Proto mechanism ID", width = 160),
        theme_label = colDef(name = "Proto mechanism label", minWidth = 240),
        mechanism_explanation = colDef(name = "Mechanism explanation", minWidth = 340),
        mechanism_count = colDef(name = "Mechanisms", width = 120, align = "right")
      ),
      details = details_row,
      onClick = "expand",
      resizable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      defaultPageSize = 20,
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 20, 40, 80),
      class = "proto-table",
      rowStyle = list(cursor = "pointer"),
      defaultColDef = colDef(headerClass = "proto-header"),
      wrap = TRUE
    )
  })
}

shinyApp(ui, server)
