## =========================== Load Data ====================================
## ==============================================================================

# Load in shapefiles from FCC https://www.fcc.gov/general/oklahoma-enhanced-lifeline-support-maps
aesa <- readOGR(dsn = "./data", layer = "adopted_enhanced_support_area")
chero <- readOGR(dsn = "./data/", layer = "cherokee_outlet")

# Load in GEOJSON of OK county lines from http://catalog.opendata.city/dataset/oklahoma-counties-polygon/resource/75b87ccf-da9e-464e-814b-16985041d2ca
okgj <- readOGR(dsn="./data/okcounties.geojson", layer="OGRGeoJSON")

df_rds2 <- readRDS("./data/okdem2.RDS")
okgj@data <- df_rds2

## =========================== Percent Map ====================================
## ==============================================================================

percent_map2 <- function(var, col, legend.title) {

  # generate vector of fill colors for map
  pal <- colorNumeric(palette = col, domain = var)

  # create pop-up on click
  county_popup <- paste0("<strong>Name: </strong>", okgj$name, "<br><strong>",legend.title,", 2014: </strong>", var*100, "%")

  # produce base map
  map <- leaflet(data=okgj) %>% addTiles()
  
  # add specs
  map %>% 
  addPolygons(
    stroke = FALSE, 
    smoothFactor = 0.2, 
    fillOpacity = 0.8, 
    fillColor = ~pal(var), 
    weight = 1, 
    popup = county_popup) %>% 
  addLegend(
    "bottomleft",
    pal = pal, 
    values = ~var,
    title = legend.title,
    labFormat = labelFormat(suffix = "%"),
    opacity = 1) %>% 
  addPolylines(data=aesa, color="red", popup="Enhanced Support Area") %>% 
  addPolylines(data=chero, color="blue", popup="Cherokee Outlet")
}
