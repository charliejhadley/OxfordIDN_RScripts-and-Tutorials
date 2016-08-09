## http://stackoverflow.com/questions/36677726/r-how-do-i-automatically-scroll-to-the-bottom-of-a-div-in-shinyapp

library(shiny)

ui <- fluidPage(
  tags$head(
    # Some css to style the div to make it more easily visible
    tags$style(
      '#outDiv{
      height:150px;
      overflow-y:scroll;
      border: 1px solid black;
      border-radius:15px;
      padding:15px;
      }
      '
    ),
    # Custom shiny to javascript binding
    # scrolls "outDiv" to bottom once called
    tags$script(
      '
      Shiny.addCustomMessageHandler("scrollCallback",
      function(color) {
      var objDiv = document.getElementById("outDiv");
      objDiv.scrollTop = objDiv.scrollHeight;
      }
      );'
    )
    ),
  sidebarLayout(
    sidebarPanel(
      actionButton('go','Start Printing')
    ),
    mainPanel(
      div(id='outDiv',
          htmlOutput('out')
      )
      # Text output
      
    )
  )
    )

server <- function(input, output, session) {
  autoInvalidate <- reactiveTimer(250, session) # Timer function
  
  ptm      <- proc.time() # Start time
  startTxt <- ''          # Start string to show on screen
  
  # Function to print new line when reactiveTimer invalidates
  startPrint <- function(){
    output$out <- renderText({ 
      ctm <- proc.time() - ptm
      autoInvalidate() # Start invalidating function every n miliseconds
      
      # Format string to print
      curr.font <- sample(colours(distinct=T), 1) 
      curr.txt  <- sprintf('<font color="%s"> %4.2f</font> seconds from start <br>', curr.font, ctm[[3]]) 
      startTxt  <<- paste(startTxt, curr.txt, collapse = '')
      
      # Call custom javascript to scroll window
      session$sendCustomMessage(type = "scrollCallback", 1)
      
      return(startTxt)
    })
  }
  
  observeEvent(input$go,{
    startPrint()
  })
}

runApp(shinyApp(ui,server))