library(xlsx)
library(shiny)
library(rdrop2)

token <- readRDS("droptoken.rds")
drop_acc(dtoken = token)

if(drop_get('/Private_Cache-Tests/UK_Prime_Ministers.xlsx', local_file = "pms_data.xlsx", overwrite = T)){
  dropbox_get_success <- TRUE
} else {
  dropbox_get_success <- FALSE
}

if(dropbox_get_success){
  file.rename(from = "pms_data.xlsx", to = "up-to-date_pms_data.xlsx")
}

dropbox_data <- read.xlsx("up-to-date_pms_data.xlsx", sheetIndex = 1)

shinyServer(
  function(input, output){
    
    output$summary <- renderDataTable({
      dropbox_data
    })
    
  }
)