shinyUI(
  fluidPage(
    wellPanel(""),
    actionButton("update", label = "update"),
    dataTableOutput("summary")
  )
)