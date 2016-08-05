library(xlsx)
library(shiny)
library(rdrop2)
library(lubridate)
library(digest)
library(plyr)

token <- readRDS("droptoken.rds")

original_file_name <- "pms_data.csv"
unique_name_fn <-
  function() {
    sprintf("%s_%s.csv", digest::digest(paste0(as.integer(Sys.time(
    )), runif(1))), "user_downloaded")
  }

sort_locals_by_date <- function() {
  all_local_files <-
    c(original_file_name, list.files()[grepl(pattern = "user[_]downloaded", list.files())])
  all_local_files_mtime <-
    unlist(lapply(all_local_files, function(x)
      file.mtime(x)))
  sort_locals_by_date <-
    all_local_files[order(all_local_files_mtime)]
  sort_locals_by_date
}

clear_downloaded_files <- function() {
  if (sum(grepl(pattern = "user[_]downloaded", list.files())) > 5) {
    sorted_files <- sort_locals_by_date()
    sorted_files <-
      sorted_files[grepl(pattern = "user[_]downloaded", sorted_files)]
    lapply(sorted_files[1:3], function(x)
      file.remove(x))
  }
}

shinyServer(function(input, output) {
  uk_prime_ministers <- eventReactive(input$update,
                                      {
                                        if (drop_exists('/Private_Cache-Tests/UK_Prime_Ministers.csv', dtoken = token)) {
                                          if (any(grepl(pattern = "user[_]downloaded", list.files()))) {
                                            ## there are updated files
                                            ## Get modification times for local and external file
                                            all_local_files <-
                                              c(original_file_name, list.files()[grepl(pattern = "user[_]downloaded", list.files())])
                                            all_local_files_mtime <-
                                              unlist(lapply(all_local_files, function(x)
                                                file.mtime(x)))
                                            remote_file_mtime <-
                                              dmy_hms(drop_history('/Private_Cache-Tests/UK_Prime_Ministers.csv', dtoken = token)[1, modified])
                                            
                                            if (!any(all_local_files_mtime > as.integer(remote_file_mtime))) {
                                              drop_get(
                                                '/Private_Cache-Tests/UK_Prime_Ministers.csv',
                                                local_file = unique_name_fn(),
                                                overwrite = T,
                                                dtoken = token
                                              )
                                              sorted_files <- sort_locals_by_date()
                                              ## Import most recently updated file
                                              data_to_use <-
                                                read.csv(sorted_files[length(sorted_files)])
                                              clear_downloaded_files()
                                              data_to_use
                                            } else {
                                              sorted_files <- sort_locals_by_date()
                                              ## Import most recently updated file
                                              data_to_use <-
                                                read.csv(sorted_files[length(sorted_files)])
                                              data_to_use
                                            }
                                          } else {
                                            ## first deploy, get file and import
                                            drop_get(
                                              '/Private_Cache-Tests/UK_Prime_Ministers.csv',
                                              local_file = unique_name_fn(),
                                              overwrite = T,
                                              dtoken = token
                                            )
                                            sorted_files <- sort_locals_by_date()
                                            ## Import most recently updated file
                                            data_to_use <-
                                              read.csv(sorted_files[length(sorted_files)])
                                            clear_downloaded_files()
                                            data_to_use
                                          }
                                        } else {
                                          ## if external file does not exist
                                          sorted_files <- sort_locals_by_date()
                                          ## Import most recently updated file
                                          data_to_use <- read.csv(sorted_files[length(sorted_files)])
                                          data_to_use
                                        }
                                      },
                                      ignoreNULL = FALSE)
                                      #
                                      # data_to_use <-
                                      #   join_all(lapply(all_local_files, function(x) {
                                      #     read.csv(x)
                                      #   }),
                                      #   match = "all",
                                      #   type = "right")
                                      # data_to_use <-
                                      #   data_to_use[!duplicated(data_to_use),]
                                      # data_to_use)
                                      
                                      output$summary <- renderDataTable({
                                        uk_prime_ministers()
                                      })
                                      
})