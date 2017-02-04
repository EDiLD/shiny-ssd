# UI Elements -------------------------------------------------------------
output$y = renderUI({
  vars <- get_vars()
  selectInput('y', 'ECx', vars)
})

output$species = renderUI({
  vars <- get_vars()
  selectInput('species', 'Species', vars)
})



# Plot output -------------------------------------------------------------


output$plot_settings <- renderPlot({
  df <- get_data()
  df <- df[order(df[[input$y]]), ]
  df$frac <- ppoints(df[[input$y]], 0.5)
  
  p <- ggplot(data = df) +
    geom_point(aes_string(x = input$y, y = 'frac'), size = 5) +
    geom_text(aes_string(x = input$y, y = 'frac', label = input$species), 
              hjust = 1.1, size = 4) +
    theme_bw() +
    scale_x_log10(limits = c(min(df[[input$y]])/10, max(df[[input$y]]))) +
    labs(x  = 'Concentration', y = 'Potentially Affected Fraction')
  p
})
