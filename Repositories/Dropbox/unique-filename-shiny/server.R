library(xlsx)
library(shiny)
library(rdrop2)
library(lubridate)
library(digest)
library(plyr)

token <- readRDS("droptoken.rds")
print(token)
drop_acc(dtoken = token)

original_file_name <- "pms_data.csv"
unique_name_fn <-
  function() {
    sprintf("%s_%s.csv",
            digest::digest(paste0(as.integer(Sys.time(
              
            )), runif(1))),
            "user_downloaded")
  }

shinyServer(function(input, output) {
  uk_prime_ministers <- eventReactive(input$update,
                                      {
                                        all_local_files <-
                                          c("pms_data.csv", list.files()[grepl(pattern = "user[_]downloaded", list.files())])
                                        
                                        all_local_files_mtime <-
                                          unlist(lapply(all_local_files, function(x)
                                            file.mtime(x)))
                                        
                                        remote_file_mtime <-
                                          dmy_hms(drop_history('/Private_Cache-Tests/UK_Prime_Ministers.csv', dtoken = token)[1, modified])
                                        
                                        if (!any(all_local_files_mtime > as.integer(remote_file_mtime))) {
                                          store_fname <- unique_name_fn()
                                          drop_get(
                                            '/Private_Cache-Tests/UK_Prime_Ministers.csv',
                                            local_file = store_fname,
                                            overwrite = T,
                                            dtoken = token
                                          )
                                          all_local_files <-
                                            c(all_local_files, store_fname)
                                        }
                                        
                                        all_local_files_mtime <-
                                          unlist(lapply(all_local_files, function(x)
                                            file.mtime(x)))
                                        all_local_files <-
                                          all_local_files[order(all_local_files_mtime)]
                                        
                                        data_to_show <- read.csv(all_local_files[length(all_local_files)])
                                        data_to_show
                                        if(length(all_local_files) > 3){
                                          lapply(all_local_files[2:{length(all_local_files)-1}], function(x)file.remove(x))
                                          data_to_show
                                        } else {
                                          data_to_show
                                        }

                                        
                                        
                                        # lapply(all_local_files[1:{length(all_local_files)-1}], function(x)file.remove(x))
                                        
                                        },
                                        ignoreNULL=FALSE
                                        # 
                                        # data_to_use <-
                                        #   join_all(lapply(all_local_files, function(x) {
                                        #     read.csv(x)
                                        #   }),
                                        #   match = "all",
                                        #   type = "right")
                                        # data_to_use <-
                                        #   data_to_use[!duplicated(data_to_use),]
                                        # data_to_use
                                      )
  
  output$summary <- renderDataTable({
    uk_prime_ministers()
  })
  
})