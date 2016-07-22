shinyUI(
  fluidPage(
    selectInput("colour", label = "colour", choices = c("red","blue","green")),
    plotOutput("plotlyPlot")
  )
)