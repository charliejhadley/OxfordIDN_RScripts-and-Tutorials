# server.R

library(maps)
library(mapproj)
library(leaflet)
library(rgdal)

source("helpers.R")

shinyServer(
  function(input, output) {
    
    output$map2 <- renderLeaflet({
      args2 <- switch(input$var,
                     "Percent Below Poverty Line" = list(okgj@data$incomeBelowPoverty, "YlGnBu", "% Below Poverty Line"),
                     "Percent Native American" = list(okgj@data$raceNativeAmerican, "YlOrRd", "% Native American"))      
      do.call(percent_map2, args2)
    })
  }
)