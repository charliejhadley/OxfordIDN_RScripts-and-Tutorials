## server.R

library(shiny)
library(plotly)

x = c(1, 2, 3)
y = c(4, 2, 4)
links = c("https://plot.ly/r/", 
          "https://plot.ly/r/shiny-tutorial", 
          "https://plot.ly/r/click-events")

df = data.frame(x, y, links)

shinyServer(function(input, output) {
  
  output$trendPlot <- renderPlotly({
#     # Create a ggplot
#     g = ggplot(data=df, aes(x = x, y = y)) + geom_point()
#     # Serialize as Plotly's graph universal format
#     p = plotly_build(g)
#     # Add a new key, links, that JS will access on click events
#     p$data[[1]]$links = links
#     p
    
    # Alternatively, use Plotly's native syntax. More here: https://plot.ly/r
    plot_ly(df, x=x,y=y,links=links)
  })
  
  output$results = renderPrint({
    input$mydata
  })
  
  output$clickPrint <- renderPrint({
    
    input$click_data
  })
  
})