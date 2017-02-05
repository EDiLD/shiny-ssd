# UI Elements -------------------------------------------------------------
output$y = renderUI({
  vars <- get_vars()
  selectInput('y', 'ECx', vars, selected = vars[2])
})

output$species = renderUI({
  vars <- get_vars()
  selectInput('species', 'Species', vars, selected = 1)
})

output$group = renderUI({
  vars <- get_vars()
  vars <- c(None  = '__none__', vars)
  selectInput('group', 'Color group', vars)
})



# aggregate ---------------------------------------------------------------
get_cdata <- reactive({
  req(input$y)
  df <- get_data()
  
  if (input$group == '__none__') {
    group <-  list(df[[input$species]])
    nams <- c(input$species, input$y)
  } else {
    group <- list(df[[input$species]],  df[[input$group]])
    nams <- c(input$species, input$group, input$y)
  }
   
  # aggregate per species using log-mean
  df <- aggregate(df[[input$y]], group, FUN = geomean)
  names(df) <- nams
  
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
    theme(legend.position = 'bottom')
  
  if (input$group != '__none__')
    p <- p + aes_string(col = input$group)
  
  p <- p + 
    geom_point(data = df, aes_string(x = input$y, y = 'frac')) +
    # lowest 35 to the right
    geom_text(data = lab_right, 
              aes_string(x = max(df[[input$y]]), 
                         y = 'frac', 
                         label = input$species), 
              hjust = 1, 
              show.legend = FALSE) +
    # highest 35 to the left
    geom_text(data = lab_left, 
              aes_string(x = min(df[[input$y]]), 
                         y = 'frac', 
                         label = input$species), 
              hjust = 0, 
              show.legend = FALSE) 
  
  if (input$log_x) {
    p <- p + scale_x_log10()
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
