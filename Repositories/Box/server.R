library(boxr)
library(shiny)
library(ggplot2)

box_auth(client_id = "m2wypo7lyldmwe7w5kooh21y65dg17b4", client_secret = "K5amICAOLCcUxXFm3LAVJvsKf2iizH58", interactive = F)

shinyServer(
  function(input, output){
    
    box_data_to_plot <- box_read_csv(file_id = "68041898313")
    
    output$plotlyPlot <- renderPlot({
      
      ggplot(box_data_to_plot, aes(x = X, y = Y)) + geom_point(colour = input$colour)
      
    })
    
  }
)