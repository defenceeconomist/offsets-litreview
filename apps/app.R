library(shiny)
library(DT)
library(dplyr)
library(stringr)

data_path <- file.path("../","data", "cmo_statements.csv")
cmo <- read.csv(data_path, stringsAsFactors = FALSE, na.strings = c("", "NA"))

split_tags <- function(x) {
  if (is.na(x) || !nzchar(x)) return(character())
  tags <- unlist(strsplit(x, "[,;\\s]+"))
  tags[nzchar(tags)]
}

unique_sorted <- function(x) sort(unique(x))

context_tags <- unique_sorted(unlist(lapply(cmo$context_tags, split_tags)))
mechanism_tags <- unique_sorted(unlist(lapply(cmo$mechanism_tags, split_tags)))
outcome_tags <- unique_sorted(unlist(lapply(cmo$outcome_tags, split_tags)))
rq_tags <- unique_sorted(unlist(lapply(cmo$research_questions_mapped, split_tags)))
countries <- unique_sorted(cmo$country[!is.na(cmo$country)])
evidence_types <- unique_sorted(cmo$evidence_type[!is.na(cmo$evidence_type)])

default_cols <- intersect(
  c("cmo_id", "context", "mechanism", "outcome", "supporting_evidence_paraphrase",
    "country", "evidence_type", "research_questions_mapped"),
  names(cmo)
)

ui <- fluidPage(
  titlePanel("CMO Explorer"),
  sidebarLayout(
    sidebarPanel(
      textInput("search_text", "Search text", placeholder = "context / mechanism / outcome / evidence"),
      radioButtons("tag_mode", "Tag match mode", choices = c("Match any" = "any", "Match all" = "all")),
      selectizeInput("context_tags", "Context tags", choices = context_tags, multiple = TRUE),
      selectizeInput("mechanism_tags", "Mechanism tags", choices = mechanism_tags, multiple = TRUE),
      selectizeInput("outcome_tags", "Outcome tags", choices = outcome_tags, multiple = TRUE),
      selectizeInput("rq_tags", "Research questions", choices = rq_tags, multiple = TRUE),
      selectizeInput("countries", "Country", choices = countries, multiple = TRUE),
      selectizeInput("evidence_types", "Evidence type", choices = evidence_types, multiple = TRUE),
      selectizeInput(
        "columns",
        "Columns to display",
        choices = names(cmo),
        selected = default_cols,
        multiple = TRUE,
        options = list(plugins = list("remove_button"))
      )
    ),
    mainPanel(
      DTOutput("cmo_table")
    )
  )
)

server <- function(input, output, session) {
  matches_tags <- function(row_val, selected, mode) {
    if (length(selected) == 0) return(TRUE)
    tags <- split_tags(row_val)
    if (length(tags) == 0) return(FALSE)
    if (mode == "all") return(all(selected %in% tags))
    any(selected %in% tags)
  }

  filtered <- reactive({
    df <- cmo

    if (nzchar(input$search_text)) {
      hay <- paste(
        df$context, df$mechanism, df$outcome,
        df$supporting_evidence, df$supporting_evidence_paraphrase,
        sep = " "
      )
      keep <- str_detect(tolower(hay), fixed(tolower(input$search_text)))
      df <- df[keep, , drop = FALSE]
    }

    mode <- input$tag_mode
    if (length(input$context_tags)) {
      df <- df[sapply(df$context_tags, matches_tags, selected = input$context_tags, mode = mode), , drop = FALSE]
    }
    if (length(input$mechanism_tags)) {
      df <- df[sapply(df$mechanism_tags, matches_tags, selected = input$mechanism_tags, mode = mode), , drop = FALSE]
    }
    if (length(input$outcome_tags)) {
      df <- df[sapply(df$outcome_tags, matches_tags, selected = input$outcome_tags, mode = mode), , drop = FALSE]
    }
    if (length(input$rq_tags)) {
      df <- df[sapply(df$research_questions_mapped, matches_tags, selected = input$rq_tags, mode = mode), , drop = FALSE]
    }
    if (length(input$countries)) {
      df <- df[df$country %in% input$countries, , drop = FALSE]
    }
    if (length(input$evidence_types)) {
      df <- df[df$evidence_type %in% input$evidence_types, , drop = FALSE]
    }

    df
  })

  output$cmo_table <- renderDT({
    df <- filtered()
    cols <- input$columns
    if (length(cols) == 0) cols <- names(df)
    cols <- intersect(cols, names(df))
    df <- df[, cols, drop = FALSE]
    datatable(
      df,
      rownames = FALSE,
      options = list(pageLength = 25, scrollX = TRUE)
    )
  })
}

shinyApp(ui, server)
