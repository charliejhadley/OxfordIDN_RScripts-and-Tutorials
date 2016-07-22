library(rfigshare)



shinyServer(
  function(input, output){
    
    output$summary <- renderUI({
      article_details <- fs_details(article_id = 3425729)

      print(class(article_details))

      h2(article_details$title)
    })
    
  }
)