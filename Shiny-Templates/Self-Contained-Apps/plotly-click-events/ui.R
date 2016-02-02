## ui.R

library(shiny)
library(plotly)

shinyUI(fluidPage(
  mainPanel(
    plotlyOutput("trendPlot"),
    verbatimTextOutput("results"),
    verbatimTextOutput("clickPrint"),
    tags$head(tags$script(src="clickhandler.js")),
    tags$script('
    document.getElementById("trendPlot").onclick = function() {
                var number = Math.random();
                Shiny.onInputChange("mydata", number);
                };
                ')
  )
))
