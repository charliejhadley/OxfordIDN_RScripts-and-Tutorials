library(shiny)
library(visNetwork)



library(shinyjs)
jscode <- "
shinyjs.clickfunc = function(link) {
alert(link);  
Shiny.onInputChange('current_node_id', link);
}"

shinyServer(function(input, output, session) {
  
  ## =========================== Reactive Part ====================================
  ## ==============================================================================
  
  v <- reactiveValues(selected_node = NULL, destructive_inputs = NULL, both = NULL)
  
  observeEvent(input$current_node_id, {
    v$selected_node <- input$current_node_id
  })
  
  observeEvent(input$reset, {
    v$data <- NULL
  })  
  
  ## =========================== Section Title ====================================
  ## ==============================================================================
  
  
  visN_edges <- reactive({
    data.frame(
      "from" = c(1, 5, 7, 6, 5, 4, 2, 8, 2, 4),
      "to" = c(3, 6, 1, 6, 7, 8, 3, 2, 7, 5),
      "colour" = rep(input$colour_dontchange, 10)
    )
  })
  
  visN_nodes <- data.frame("id" = 1:8)
  
  select_invalidate <- eventReactive(input$shape_do_change, {
    foo_invalidate <- "it changed"
  })
  
  output$the_network <- renderVisNetwork({
    visN_edges <- visN_edges()
    
    visNetwork(node = visN_nodes,
               edges = visN_edges) %>% visNodes(shape = input$shape_do_change) %>%
      visEvents(selectNode = "function(nodes) {
                Shiny.onInputChange('current_node_id', nodes);
                ;}")
})
  
  output$selected_node <- renderText({
    print(input$current_node_id)
    input$current_node_id$nodes[[1]]
  })
  
})