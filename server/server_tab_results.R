hcx <- reactive({
  numextractall(input$hcx) / 100
})

# fit distribution
fit <- reactive({
  df <- get_data()
  fit <-  fitdist(df[[input$y]], input$model)
  fit
})

# calc hcx
hcxs <- reactive({
  fit <- fit()
  hcxs <- quantile(fit, probs = hcx())
  hcxs
})

# bootstrap
boots <- reactive({
  fit <- fit()
  boots <- bootdist(fit, 
                    bootmethod = input$boot_method, 
                    niter = input$nboot)
  boots
})

# confidence interval from bootstreap
cis <- reactive({
  cis <- quantile(boots(), probs = hcx())
  cis
})


pdat <- reactive({
  # predict new distributions on a grid of 1000
  newxs <- 10^(seq(log10(min(df[[input$y]])),
                   log10(max(df[[input$y]])),
                   length.out = 1000))
  # bootstraps
  pp <- apply(boots()$estim, 1,
              switch(input$model,
                     lnorm = function(x) plnorm(newxs, 
                                                meanlog = x[1], sdlog = x[2]),
                     llogis = function(x) pllogis(newxs, 
                                                  shape = x[1], scale = x[2]))
  )
  
  # use actual fit for mean (not boostrap mean)
  fit <- fit()
  pdat <- data.frame(newxs, py = switch(input$model,
                                        lnorm = plnorm(newxs,
                                                       meanlog = fit$estimate[1],
                                                       sdlog = fit$estimate[2]),
                                        llogis = pllogis(newxs,
                                                         shape = fit$estimate[1],
                                                         scale = fit$estimate[2])))
  
  # get CI from bootstraps
  cis <- apply(pp, 1, quantile, c(0.025, 0.975))
  rownames(cis) <- c('lwr' ,'upr')

  # combine mean (from fit) + CI (from bootstrap)
  pdat <- cbind(pdat, t(cis))
  pdat
})


bootdat <- reactive({
  # predict new distributions on a grid of 1000
  newxs <- 10^(seq(log10(min(df[[input$y]])),
                   log10(max(df[[input$y]])),
                   length.out = 1000))
  # use samples to get distribution
  pp <- apply(boots()$estim, 1,
              switch(input$model,
                     lnorm = function(x) plnorm(newxs, 
                                                meanlog = x[1], sdlog = x[2]),
                     llogis = function(x) pllogis(newxs, 
                                                  shape = x[1], scale = x[2]))
  )
  bootdat <- data.frame(pp)
  
  # add x-values
  bootdat$newxs <- newxs
  bootdat <- gather(bootdat, key = 'variable', value = 'value', -newxs)
  bootdat
})


output$plot_model <- renderPlot({
  df <- get_cdata()
  df <- df[order(df[[input$y]]), ]
  df$frac <- ppoints(df[[input$y]], 0.5)
  nobs <- nrow(df)
  df_sort <- df[order(df[[input$y]]), ]
  half <- ceiling(nobs / 2)
  
  pdat <- pdat()
  bootdat <- bootdat()
  
  p <- ggplot() +
    theme_bw() +
    scale_x_log10() +
    labs(x  = 'Concentration', y = 'Potentially Affected Fraction')  +
    theme(legend.position = 'bottom')
  
  if (input$plot_samps)
    p <- p + geom_line(data = bootdat,
                       aes(x = newxs, y = value, group = variable),
                       col = 'steelblue', 
                       alpha = 10 / input$nboot)
  
  if (input$group != '__none__') {
    p <- p + 
      geom_point(data = df,
                 aes_string(x = input$y, 
                            y = 'frac', 
                            col = input$group)) +
      # lowest 35 to the right
      geom_text(data = df_sort[1:half, ], 
                aes_string(x = max(df[[input$y]]), 
                           y = 'frac', 
                           label = input$species,
                           col = input$group), 
                hjust = 1, size = 4, show.legend = FALSE) +
      # highest 35 to the left
      geom_text(data = df_sort[(half + 1):nobs, ], 
                aes_string(x = min(df[[input$y]]), 
                           y = 'frac', 
                           label = input$species,
                           col = input$group), 
                hjust = 0, size = 4, show.legend = FALSE) 
  } else {
    p <- p + 
      geom_point(data = df,
                 aes_string(x = input$y, y = 'frac')) +
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
  }
  
  p <- p + 
    geom_line(data = pdat, aes(x = newxs, y = py), col = 'red') +
    geom_line(data = pdat, aes(x = newxs, y = lwr), linetype = 'dashed') +
    geom_line(data = pdat, aes(x = newxs, y = upr), linetype = 'dashed') 
  p
})
