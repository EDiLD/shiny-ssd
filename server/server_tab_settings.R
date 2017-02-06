# UI Elements -------------------------------------------------------------
output$y = renderUI({
  vars <- get_vars()
  selectInput('y', 'ECx', vars, selected = vars[2])
})

output$species = renderUI({
  vars <- get_vars()
  selectInput('species', 'Species', vars, selected = 1)
})


# aggregate ---------------------------------------------------------------
get_cdata <- reactive({
  df <- get_data()
   
  # aggregate per species using log-mean
  df <- aggregate(df[[input$y]], list(df[[input$species]]), FUN = geomean)
  names(df) <- c(input$species, input$y)
  
  df
})



# Plot output -------------------------------------------------------------
settings_plot <- reactive({
  df <- get_cdata()
  
  if (is.null(df))
    return(NULL)
  
  df <- df[order(df[[input$y]]), ]
  df$frac <- ppoints(df[[input$y]], 0.5)
  nobs <- nrow(df)
  df_sort <- df[order(df[[input$y]]), ]
  half <- ceiling(nobs / 2)
  if (!input$log_x)
    half <- nobs - 1
  lab_right <- df_sort[1:half, ]
  lab_left <- df_sort[(half + 1):nobs, ]
  
  p <- ggplot() +
    theme_edi() +
    labs(x  = 'Concentration', y = 'Potentially Affected Fraction')  +
    theme(legend.position = 'bottom') +
    geom_point(data = df, aes_string(x = input$y, y = 'frac'))
  
  # log x-axis?
  if (input$log_x)
    p <- p + scale_x_log10()
  
  # add species labels
  if (input$label_spec) {
    p <- p +
      geom_text(data = lab_right, 
                aes_string(x = max(df[[input$y]]), 
                           y = 'frac', 
                           label = input$species), 
                hjust = 1, 
                show.legend = FALSE) +
      geom_text(data = lab_left, 
                aes_string(x = min(df[[input$y]]), 
                           y = 'frac', 
                           label = input$species), 
                hjust = 0, 
                show.legend = FALSE) 
  }
  
  p
})


output$plot_settings <- renderPlot({
 print(settings_plot())
})


output$download_plot_settings <- downloadHandler(
  filename = "ssd_settings_plot.png",
  content = function(file) {
    ggsave(file, settings_plot(), scale = 1.4)
  })  
