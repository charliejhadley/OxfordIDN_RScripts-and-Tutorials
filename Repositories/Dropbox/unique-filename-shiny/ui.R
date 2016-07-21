shinyUI(
  fluidPage(
    sliderInput('n', label = "n", min = 1, max = 3, value = 2),
    actionButton("update", label = "update"),
    dataTableOutput("summary")
  )
)