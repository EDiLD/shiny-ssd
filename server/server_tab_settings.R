# UI Elements -------------------------------------------------------------
output$y = renderUI({
  vars <- get_vars()
  selectInput('y', 'ECx', vars)
})

output$species = renderUI({
  vars <- get_vars()
  selectInput('species', 'Species', vars)
})

output$group = renderUI({
  vars <- get_vars()
  vars <- c(None  = '__none__', vars)
  selectInput('group', 'Color group', vars)
})



# aggregate ---------------------------------------------------------------
get_cdata <- reactive({
  df <- get_data()
  
  # do nothing when not numeric
  if (is.character(df[[input$y]]))
    return(NULL)
  
  if (input$group == '__none__') {
    group <-  list(df[[input$species]])
    nams <- c(input$species, input$y)
  } else {
    group <- list(df[[input$species]],  df[[input$group]])
    nams <- c(input$species, input$group, input$y)
  }
   
  # aggregate per species using log-mean
  df_agg <- aggregate(df[[input$y]], group, FUN = geomean)
  names(df_agg) <- nams
  
  df_agg
})


# Plot output -------------------------------------------------------------


output$plot_settings <- renderPlot({
  df <- get_cdata()
  
  if (is.null(df))
    return(NULL)
  
  df <- df[order(df[[input$y]]), ]
  df$frac <- ppoints(df[[input$y]], 0.5)
  nobs <- nrow(df)
  df_sort <- df[order(df[[input$y]]), ]
  half <- ceiling(nobs / 2)
  
  p <- ggplot() +
    theme_bw() +
    scale_x_log10() +
    labs(x  = 'Concentration', y = 'Potentially Affected Fraction')  +
    theme(legend.position = 'bottom')
  
  if (input$group != '__none__')
    p <- p + aes_string(col = input$group)
  
  p <- p + 
    geom_point(data = df, aes_string(x = input$y, y = 'frac')) +
    # lowest 35 to the right
    geom_text(data = df_sort[1:half, ], 
              aes_string(x = max(df[[input$y]]), 
                         y = 'frac', 
                         label = input$species), 
              hjust = 1, size = 4, show.legend = FALSE) +
    # highest 35 to the left
    geom_text(data = df_sort[(half + 1):nobs, ], 
              aes_string(x = min(df[[input$y]]), 
                         y = 'frac', 
                         label = input$species), 
              hjust = 0, size = 4, show.legend = FALSE) 
  p
})
