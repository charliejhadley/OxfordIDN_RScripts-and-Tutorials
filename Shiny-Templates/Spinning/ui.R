## Full Credit to http://stackoverflow.com/a/37240424/1659890
library(shiny)

shinyUI(
  fluidPage(theme="simplex.min.css",
            tags$style(type="text/css",
                       "label {font-size: 12px;}",
                       ".recalculating {opacity: 1.0;}"
            ),
            tags$head(
              tags$style(HTML("
                              @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
                              
                              h1 {
                              font-family: 'Lobster', cursive;
                              font-weight: 500;
                              line-height: 1.1;
                              color: #48ca3b;
                              }
                              
                              ")),
              tags$script(HTML("$(function() {
var $elie = $('div');
                               rotate(25);
                               function rotate(degree) {        
                               $elie.css({ WebkitTransform: 'rotate(' + degree + 'deg)'});  
                               $elie.css({ '-moz-transform': 'rotate(' + degree + 'deg)'});
                               timer = setTimeout(function() {
                               rotate(++degree);
                               },100);
                               }
                               });"))
              ),
            
            # Application title
            tags$h2("Google!!!"),
            p("An adaptation of the",
              tags$a(href="https://google.com", "Google"),
              "from",
              tags$a(href="https://duckduckgo.com/", "DuckDuckGo"),
              "to get the best possible results without selling yourself"),
            hr(),
            
            fluidRow(
              column(6, tags$h3("Scenario A")),
              column(6, tags$h3("Scenario B"))
            ),
            fluidRow(
              column(12, renderInputs("a"))
            ),
            fluidRow(
              column(6,
                     plotOutput("a_distPlot", height = "600px")
              ),
              column(6,
                     plotOutput("b_distPlot", height = "600px")
              )
            )
              )
  
)