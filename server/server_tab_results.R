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
  nboot <- input$nboot
  
  if (nboot > 1000) {
    nboot <- 1000
  }
  
  boots <- bootdist(fit, 
                    bootmethod = input$boot_method, 
                    niter = nboot)
  boots
})


# confidence interval from bootstreap
cis <- reactive({
  cis <- quantile(boots(), probs = hcx())
  t(cis$quantCI)
})


get_newxs <- reactive({
  df <- get_cdata()
  
  # predict new distributions on a grid of 1000
  newxs <- 10^(seq(log10(min(df[[input$y]])),
                   log10(max(df[[input$y]])),
                   length.out = 1000))
  
  newxs
})


# calc mean prediction from fit
p_fit <- reactive({
  newxs <- get_newxs()
  fit <- fit()
  p_fit <- data.frame(newxs, 
                      py = switch(input$model, 
                                  lnorm = plnorm(newxs,
                                                 meanlog = fit$estimate[1],
                                                 sdlog = fit$estimate[2]),
                                  llogis = pllogis(newxs,
                                                   shape = fit$estimate[1],
                                                   scale = fit$estimate[2])))
  p_fit
})

pp <- reactive({
  newxs <- get_newxs()
  # bootstrap samples
  pp <- apply(boots()$estim, 1,
              switch(input$model,
                     lnorm = function(x) plnorm(newxs, 
                                                meanlog = x[1], sdlog = x[2]),
                     llogis = function(x) pllogis(newxs, 
                                                  shape = x[1], scale = x[2]))
  )
  pp
})

# calc pointwise ci
p_ci <- reactive({
  pp <- pp()
  # get CI from bootstraps
  cis <- apply(pp, 1, quantile, c(0.025, 0.975))
  cis <- data.frame(t(cis))
  names(cis) <- c('lwr' ,'upr')
  cis
})



results_plot <- reactive({
  
  # prepare data
  df <- get_cdata()
  df <- df[order(df[[input$y]]), ]
  df$frac <- ppoints(df[[input$y]], 0.5)
  
  # calc label positions
  nobs <- nrow(df)
  df_sort <- df[order(df[[input$y]]), ]
  half <- ceiling(nobs / 2)
  if (!input$log_x)
    half <- nobs - 1
  lab_right <- df_sort[1:half, ]
  lab_left <- df_sort[(half + 1):nobs, ]

  # base plot
  p <- ggplot() +
    theme_edi() +
    labs(x  = 'Concentration', y = 'Potentially Affected Fraction')  +
    theme(legend.position = 'bottom')
  
  if (input$log_x)
    p <- p + scale_x_log10()
  
  # add labels & points
  if (input$group != '__none__') {
    p <- p + 
      geom_point(data = df,
                 aes_string(x = input$y, 
                            y = 'frac', 
                            col = input$group)) +
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
  } else {
    p <- p + 
      geom_point(data = df,
                 aes_string(x = input$y, y = 'frac')) +
      geom_text(data = df_sort[1:half, ], 
                aes_string(x = max(df[[input$y]]), 
                           y = 'frac', 
                           label = input$species), 
                hjust = 1, 
                show.legend = FALSE) +
      geom_text(data = df_sort[(half + 1):nobs, ], 
                aes_string(x = min(df[[input$y]]), 
                           y = 'frac', 
                           label = input$species), 
                hjust = 0, 
                show.legend = FALSE) 
  }
  
  # mean fit
  pf <- p_fit()
  p <- p + 
    geom_line(data = pf, aes(x = newxs, y = py))
  
  # add ci bands
  pci <- p_ci()
  p <- p +
    geom_line(data = pci, aes(x = newxs, y = lwr), linetype = 'dashed') +
    geom_line(data = pci, aes(x = newxs, y = upr), linetype = 'dashed') 
  
  p
})




output$plot_model <- renderPlot({
 print(results_plot())
})
output$download_plot_results <- downloadHandler(
  filename = "ssd_results_plot.png",
  content = function(file) {
    ggsave(file, results_plot(), scale = 1.4)
  }) 



results_table <- reactive({
  req(input$y)
  
  est <- t(hcxs()$quantiles)
  cis <- cis()
  out <- data.frame(HC = hcx(),
                    Estimate = est,
                    Lower = cis[ , 1],
                    Upper = cis[ , 2])
  colnames(out) <- c('HC', 'Estimate', 'LowerCI', 'UpperCI')
  rownames(out) <- NULL
  # out <- round_df(out, digits = 4)
  out
})
output$table_hcx <- renderTable({
  results_table()
  },
  digits = 3)


output$download_table_hc <- downloadHandler(
  filename = "ssd_results_table_hc.png",
  content = function(file) {
    write.csv(results_table(), file)
  }) 

output$table_hcx2 <- renderTable({
  results_table()
  },
  digits = 3)
output$download_estimates <- downloadHandler(
  filename = "ssd_estimates.png",
  content = function(file) {
    write.csv(results_table(), file)
  }) 


gof_r <- reactive({
  f <- fit()
  data.frame(logLik = f$loglik,
             AIC = f$aic,
             BIC = f$bic
  )
})
output$gof <- renderTable({
  gof_r()
})
output$download_gof <- downloadHandler(
  filename = "ssd_gof.png",
  content = function(file) {
    write.csv(gof_r(), file)
  }) 


details_r <- reactive({
  f <- fit()
  data.frame(Fit_Method = f$method,
             Distribution = f$distname,
             Boot_Method = input$boot_method,
             Boot_n = input$nboot
  )
})
output$details <- renderTable({
  details_r()
})
output$download_details <- downloadHandler(
  filename = "ssd_details.png",
  content = function(file) {
    write.csv(details_r(), file)
  }) 


output$plot_diag <- renderPlot({
  plot(fit())
})
output$download_diag <- downloadHandler(
  filename = "ssd_diag.png",
  content = function(file) {
    png(file)
    plot(fit())
    dev.off()
  }) 
