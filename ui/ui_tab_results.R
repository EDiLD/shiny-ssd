tabPanel(
  title = 'Run',
  id = 'tab_results',
  value = 'tab_results',
  icon = icon('play'),
  
  sidebarLayout(
    sidebarPanel(      
      checkboxGroupInput("model",
                         label = h3("Distribution"),
                         choices = list("Log-Normal" = 'lnorm',
                                        "Log-Logistic" = 'llogis'),
                         selected = 1),
      selectInput("boot_method",
                  label = h3("Bootstrap methods"),
                  choices = list("Parametric" = 'param',
                                 "Non-Parametric" = 'nonparam'),
                  selected = 1),
      textInput('hcx', 'HCx (separated by comma): ',
                '5, 10, 50')
    ),
    mainPanel(
    )
  )
)
