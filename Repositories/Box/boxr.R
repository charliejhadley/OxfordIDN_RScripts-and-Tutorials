## =========================== Section Title ====================================
## ==============================================================================



library(boxr)


box_auth(client_id = "m2wypo7lyldmwe7w5kooh21y65dg17b4", client_secret = "K5amICAOLCcUxXFm3LAVJvsKf2iizH58")


box_data_to_plot <- box_read_csv(file_id = "68041898313")


library(plotly)

shiny

plot_ly(data = box_data_to_plot,
        x = X,
        y = Y,
        colors = terrain.colors(10))

plot_ly(data = box_data_to_plot,
        x = X,
        y = Y,
        colors = "greens")

ggplot(box_data_to_plot, aes(x = X, y = Y)) + geom_point(colour = "red")
