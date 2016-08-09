library(shiny)


master_df <- data.frame(
  "id" = letters[1:5],
  "value" = as.character(1:5),
  stringsAsFactors = F
)

list_1 <- list("a" = 1:15, "b" = 21:25)

slave_df <- list("a")

shinyServer(
  function(input, output){
    
    output$master_ui <- renderUI({
      selectInput("master", label = "master", choices = 1:5)
    })
    
    slave_choices <- reactive({
      print(list_1[master_df$id[as.numeric(input$master)]])
      list_1[master_df$id[as.numeric(input$master)]]
    })
    
    output$slave_ui <- renderUI({
      
      if(is.null(input$master)){
        return()
      }
      
      selectInput("slave", label = "slave",
                  choices = slave_choices())
      
    })
    
  }
)