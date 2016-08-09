shinyUI(
  fluidPage(
    uiOutput("master_ui"),
    "Secondary Output below",
    uiOutput("slave_ui")
  )
)