## ==== Packages to load for server

library(shiny) # Some advanced functionality depends on the shiny package being loaded server-side, including plot.ly
library(plotly)
library(scales)
library(dplyr)
library(plyr)
library(lubridate)

## ==== Global Variables (server-side)

## ==== Tab selection variables (these are required to support anchor links, see within shinyServer)
url1 <- url2 <- ""

## ==== shinyServer

### ============= Data Processing  ========================= 
### ========================================================

## Import file
example_map_data <- read.csv(file ="data/example-map-data.csv", stringsAsFactors = FALSE)
example_map_data$Date <- force_tz(ymd(example_map_data$Date, quiet = TRUE), tzone = "GMT")

## Coerce dates into dates:
all_countries <- unique(c(example_map_data$Sender.Country, example_map_data$Receiver.Country))

## Make a set of location -> name replacements
location_name_df <- data.frame("LatLong" = c(example_map_data$Sender.LatLong.String,example_map_data$Receiver.LatLong.String),
                               "Location.Name" = c(example_map_data$Sender.Location, example_map_data$Receiver.Location))

### ============= Find duplicate locations
location_name_df <- location_name_df[!duplicated(location_name_df),]
location_name_df$LatLong <- as.character(location_name_df$LatLong)
location_name_df$Location.Name <- as.character(location_name_df$Location.Name)
duplicate_locations <- subset(location_name_df, LatLong %in% location_name_df[duplicated(location_name_df$LatLong),]$LatLong)
# Remove duplicates
location_name_df <- location_name_df[!duplicated(location_name_df$LatLong),]

### ============= Letter Series

example_map_data$Category <- as.factor(example_map_data$Category)
                                       
### ============= shinyServer =============================                                      
### =======================================================

shinyServer(function(input, output, session){

  ### ============= Main Map Section ========================= ###
  
  output$show_timeslider_UI <- renderUI({
    checkboxInput("show_timeslider", label = "Filter data by date?", value = TRUE)
  })
  
  output$show_letters_before_date_UI <- renderUI({
    
    dates <- example_map_data$Date
    if (is.null(input$show_timeslider)) {
      return()
    }
    
    if (input$show_timeslider == FALSE) {
      sliderInput(
        "show_letters_before_date", "Show letters up to",
        min = min(dates),
        max = max(dates),
        step = 365*24*60*60,
        value = min(dates),
        width = "800px",
        timeFormat = "%F",
        animate = animationOptions(interval = 500, loop = FALSE)
      )
    }
    
  })
  
  output$time_period_of_interest_UI <- renderUI({
    dates <- example_map_data$Date
    if (is.null(input$show_timeslider)) {
      return()
    }
    
    if (input$show_timeslider == TRUE) {
      sliderInput(
        "time_period_of_interest", "Time period of interest:",
        min = min(dates),
        max = max(dates),
        step = 10,
        value = c(min(dates), max(dates)),
        width = "800px",
        timeFormat = "%F"
      )
    }
  })
  

  ### ==== Location Tallies
  
  location_tallies <- reactive({
    
    if(is.null(input$show_timeslider)){
      return()
    }
    
    if(input$show_timeslider == TRUE){
      subset_entries <- subset(example_map_data,
                               Date >= as.POSIXct(paste0(input$time_period_of_interest[1]-1,"/12/31")) &
                                 Date <= as.POSIXct(paste0(input$time_period_of_interest[2]+1,"/01/01")))
      
    } else {
      subset_entries <- subset(example_map_data,
                                 Date <= as.POSIXct(paste0(input$show_letters_before_date,"/01/01")))
      
    }
    
    if(empty(subset_entries)){
      return()
    }
    
    
    
    all_locations <- unique(c(subset_entries$Sender.LatLong.String, subset_entries$Receiver.LatLong.String))
    
    ## sent location tallies
    sent_tallies <- table(subset_entries$Sender.LatLong.String)
    sent_tallies <- as.data.frame(sent_tallies)
    ## use mapvalues to replace names with tallies
    sent_tallies_vec <- mapvalues(all_locations, from = sent_tallies$Var1, to = sent_tallies$Freq)
    ## Find latlongs by looking for " " and replace values with 0
    sent_tallies_vec[grepl(" ",sent_tallies_vec)] <- 0
    ## convert to numeric:
    sent_tallies_vec <- as.numeric(sent_tallies_vec)
    
    ## receive location tallies
    receive_tallies <- table(subset_entries$Receiver.LatLong.String)
    receive_tallies <- as.data.frame(receive_tallies)
    ## use mapvalues to replace names with tallies
    receive_tallies_vec <- mapvalues(all_locations, from = receive_tallies$Var1, to = receive_tallies$Freq)
    ## Find latlongs by looking for " " and replace values with 0
    receive_tallies_vec[grepl(" ",receive_tallies_vec)] <- 0
    ## convert to numeric:
    receive_tallies_vec <- as.numeric(receive_tallies_vec)
    
    ## Use sapply to extract out latitudes
    lat_vec <- sapply(strsplit(all_locations, " "), "[[", 1)
    ## Use sapply to extract out longitudes
    lon_vec <- sapply(strsplit(all_locations, " "), "[[", 2)
    
    ### Get location names
    location_name_vec <- as.character()
    look.up.location <- function(lat_long){
      name <- location_name_df[location_name_df$LatLong == lat_long,"Location.Name"]
      name <- unique(as.character(name))[1]
      location_name_vec <<- append(location_name_vec, name)
    }
    invisible(lapply(all_locations, function(x) look.up.location(x)))

    # Spit into lat and long for plotting
    location_tallies <- data.frame("lat" = lat_vec,
                                   "lon" = lon_vec,
                                   "Letters.Sent" = sent_tallies_vec,
                                   "Letters.Received" = receive_tallies_vec,
                                   "Name" = location_name_vec)
    
    ## =====  Get category for each location - as a send location
    ## create empty vector
    category.per.location <- as.character()
    get.category.for.location <- function(location){
      
      send <- paste(location$lat, location$lon)
      entries <- subset_entries[subset_entries$Sender.LatLong.String == send, ]
      
      letter.category.for.route <- as.character(entries$Category)
      
      if (nrow(entries) == 0) {
        category.per.location <<-
          append(category.per.location, "none sent")
      } else {
        if (length(unique(letter.category.for.route)) > 1) {
          
          joined.strings <- paste0(unique(letter.category.for.route), collapse = "", sep = "<br>")
          
          joined.strings <- strtrim(joined.strings,nchar(joined.strings)-4)
          

          category.per.location <<-
            append(category.per.location, joined.strings)
          
        } else {
          category.per.location <<-
            append(category.per.location, unique(letter.category.for.route))
        }
      }
    }
    ## populate category.per.location vector
    for (i in 1:nrow(location_tallies)) {
      get.category.for.location(location_tallies[i,])
    }
    
    ## Add category.per.location to location_tallies
    location_tallies$Letter.Category <- category.per.location
    
    ## Order dataframe by letter series
    location_tallies <- location_tallies[order(location_tallies$Letter.Category),]
    
    # Return object
    location_tallies
  })
  
  output$nothing_to_display_UI <- renderUI({
    
    if(empty(location_tallies())){
    wellPanel(
      HTML("<p>There is no data to display!</p>")
    )
    }
  })
  
  output$europe_map <- renderPlotly({
    
    if(is.null(input$show_timeslider)){
      return()
    }
    
    if(input$show_timeslider & is.null(input$time_period_of_interest)){
      return()
    }
    
    # route_tallies <- route_tallies()
    location_tallies <- location_tallies()
    
    if(empty(location_tallies)){
      return()
    }
    
    
    geo_layout <- list(
      scope = "world",
      showland = TRUE,
      showcountries = FALSE,
      landcolor = toRGB("gray85"),
      #   subunitwidth = 1,
      #   countrywidth = 1,
      subunitcolor = toRGB("white"),
      countrycolor = toRGB("white"),
      showlakes = TRUE,
      lakecolor = "#999999")
    
    ## locations first
    plot_ly(location_tallies, lon = lon, lat = lat, marker = list(size = rescale(Letters.Sent + Letters.Received, to = c(7,20))),
            type = "scattergeo", locationmode = "country",
            text = paste0("Location Name: ",Name,"<br>",
                          "Letters sent from location: ",Letters.Sent,"<br>",
                          "Letters received at location: ",Letters.Received,"<br>",
                          "Letter Category: ",Letter.Category),
            hoverinfo = "text",inherit = FALSE,
            group = Letter.Category, showlegend = TRUE) %>%
      layout(
        #          title = "The ‘New’ Germans: Rethinking Integration by understanding the <br>
        #          Historical Experience of German Migrants in the US", 
        geo = geo_layout,
        legend = list(x = 1.1, y = 0.5),
        height = "1400px",
        legend = list(
          xanchor = "auto",
          yanchor = "top"
        )
      )
  })
  
  


  
})