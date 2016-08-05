# ui.R
library(leaflet)

shinyUI(fluidPage(
  titlePanel(
    "Oklahoma Demographics for Determining Lifeline Broadband Subsidies"
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "var",
        label = "Choose a variable to display",
        choices = c("Percent Below Poverty Line", "Percent Native American"),
        selected = "Percent Below Poverty Line"
      ),
      sliderInput(
        "range",
        label = "Range of interest: (For slider tab)",
        min = 0,
        max = 100,
        value = c(0, 100)
      )
    ),
    
    mainPanel(leafletOutput("map2"))
  )
))