sample_ords_data <- ords_to_data_frame("http://ords2-kjpopen.rhcloud.com/api/1.0/database/514/MAIN/tabledata/latters_maxqda_format?rowsPerPage=50&startIndex=0")

## Remove rows where there aren't send and receive locations:
sample_ords_data <- sample_ords_data[!{is.na(sample_ords_data$Sender.Location.GIS.Longitude) | 
    is.na(sample_ords_data$Receiver.Location.GIS.Latitude)},]

### ===== plot_ly
library(plotly)
plot_ly(
  data = sample_ords_data, lon = Sender.Location.GIS.Longitude, lat = Sender.Location.GIS.Latitude,
  type = "scattergeo", locationmode = "country",
  inherit = FALSE,
  showlegend = TRUE
) %>%
  add_trace(
    data = sample_ords_data, lat = list(
      Sender.Location.GIS.Latitude, Receiver.Location.GIS.Latitude
    ),
    lon = list(
      Sender.Location.GIS.Longitude, Receiver.Location.GIS.Longitude
    ),
    type = 'scattergeo',
    inherit = FALSE,
    group = ID,
    mode = 'lines',
    line = list(
      width = 0.4, color = "#6db8de", opacity = 1
    ),
    showlegend = FALSE
  ) %>%
  layout(
    geo = list(
      scope = "world",
      showland = TRUE,
      landcolor = toRGB("gray85"),
      showcountries = TRUE,
      subunitcolor = toRGB("white"),
      countrycolor = toRGB("white"),
      showlakes = TRUE,
      lakecolor = "#999999"
    )
  )
