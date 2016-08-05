library(markdown)

shinyUI(navbarPage("Navbar!",
                   tabPanel("Plot",
                            sidebarLayout(
                              sidebarPanel(
                                radioButtons("plotType", "Plot type",
                                             c("Scatter"="p", "Line"="l")
                                )
                              ),
                              mainPanel(
                                plotOutput("plot")
                              )
                            )
                   ),
                   tabPanel("Summary",
                            verbatimTextOutput("summary")
                   ),
                   navbarMenu("More",
                              tabPanel("Table",
                                       dataTableOutput("table")
                              ),
                              tabPanel("About",
                                       fluidRow(
                                         column(6,
                                                "Foobar"
                                         ),
                                         column(3,
                                                "Meta-syntactic variable name"
                                         )
                                       )
                              )
                   )
))