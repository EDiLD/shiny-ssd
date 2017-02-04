hcx <- reactive({
  numextractall(input$hcx) / 100
})

fits <- reactive({
  df <- get_data()
  
  # fit distributions
  fits <- lapply(input$model, function(y) fitdist(df[[input$y]], y))
  fits
})

hcxs <- reactive({
  fits <- fits()
  
  # extract quantiles
  hcxs <- lapply(fits, quantile, probs = hcx())
  hcxs
})

boots <- reactive({
  fits <- fits()
  boots <- lapply(fits, function(y) bootdist(y, 
                                             bootmethod = input$boot_method, 
                                             niter = 1000))
  hcxs <- lapply(boots, quantile, probs = hcx())
  hcxs
})


