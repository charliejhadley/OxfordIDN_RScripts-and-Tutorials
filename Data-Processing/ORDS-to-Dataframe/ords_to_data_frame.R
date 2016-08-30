ords_to_data_frame <- function(url){
  library(jsonlite)  
  ords_import <- fromJSON(url,
                          simplifyDataFrame = TRUE)
  
  ords_column_names <- colnames(ords_import$rows$cell)
  ## Extraxt out values, checking for numbers and converting to numeric
  data_for_analysis <- lapply(ords_column_names, function(x){
    values <- simplifified_dataframe$rows$cell[,x]$value
    if(sum(grepl("[0-9]",values)) > 0){
      values <- as.numeric(values)
    }
    values
  })
  ## Convert to data.frame
  data_for_analysis <- as.data.frame(data_for_analysis)
  ## Update column names
  colnames(data_for_analysis) <- ords_column_names
  ## Return
  data_for_analysis
}

ords_to_data_frame("http://ords2-kjpopen.rhcloud.com/api/1.0/database/514/MAIN/tabledata/latters_maxqda_format?rowsPerPage=50&startIndex=0")

