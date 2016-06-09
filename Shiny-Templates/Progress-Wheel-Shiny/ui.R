shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "progress-style.css")
  ),
  sidebarLayout(sidebarPanel(actionButton(
    'goTable', 'Go table'
  )),
  mainPanel(tableOutput("table")))
))