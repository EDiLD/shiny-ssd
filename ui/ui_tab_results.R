tabPanel(
  title = 'Model SSD',
  id = 'tab_results',
  value = 'tab_results',
  icon = icon('play'),
  
  sidebarLayout(
    sidebarPanel(      
      selectInput("model",
                         label = "Distribution",
                         choices = list("Log-Normal" = 'lnorm',
                                        "Log-Logistic" = 'llogis'),
                         selected = 1),
      textInput('hcx', 'HCx (separated by comma): ',
                '5, 10, 50'),
      h3("Bootstrap"),
      numericInput("nboot", 
                   label = "No. Bootstraps", 
                   value = 100,
                   min = 100, 
                   max = 1000,
                   step = 100), 
      selectInput("boot_method",
                  label = "Bootstrap method",
                  choices = list("Parametric" = 'param',
                                 "Non-Parametric" = 'nonparam'),
                  selected = 1),
      checkboxInput('plot_samps', 'Show bootstrap samples?', value = TRUE)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel('Plot',
                 plotOutput('plot_model')),
        tabPanel('Model Diagnostics'),
        tabPanel('Model Details')
        )
    )
  )
)
