library(shiny)
library(visNetwork)
library(shinyjs)

shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      useShinyjs(),
      extendShinyjs(text = jscode),
      textInput("link", ""),
      selectInput(
        "colour_dontchange",
        label = "Colour (don't change click)",
        choices = c("red", "blue")
      ),
      selectInput(
        "shape_do_change",
        label = "shape (do change)",
        choices = c("circle", "square")
      )
    ),
    mainPanel(visNetworkOutput("the_network"))
  ),
  conditionalPanel(
    "typeof input.current_node_id !== 'undefined'",
    verbatimTextOutput("selected_node")
    
  )
))