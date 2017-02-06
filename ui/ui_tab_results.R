tabPanel(
  title = 'Model SSD',
  id = 'tab_results',
  value = 'tab_results',
  icon = icon('play'),
  
  sidebarLayout(
    sidebarPanel(   
      h3("Model + HC"),
      selectInput("model",
                         label = "Distribution",
                         choices = list("Log-Normal" = 'lnorm',
                                        "Log-Logistic" = 'llogis'),
                         selected = 1),
      textInput('hcx', 'HCx (separated by comma): ',
                '5, 10, 50'),
      h3("Bootstrap CI"),
      numericInput("nboot", 
                   label = "No. Bootstraps (<1000)", 
                   value = 100,
                   min = 100, 
                   max = 1000,
                   step = 100), 
      selectInput("boot_method",
                  label = "Bootstrap method",
                  choices = list("Parametric" = 'param',
                                 "Non-Parametric" = 'nonparam'),
                  selected = 1)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel('Summary',
                 plotOutput('plot_model'),
                 br(),
                 h3('Estimated Hazardous Concentrations'), 
                 tableOutput('table_hcx'),
                 downloadButton('download_plot_results', 'Download Plot'),
                 downloadButton('download_table_hc', 'Download Table')
                 ),
        tabPanel('Model Details',
                 h3('Estimates'),
                 tableOutput('table_hcx2'),
                 h3('Goodness-of-fit'),
                 tableOutput('gof'),
                 h3('Methods'),
                 tableOutput('details'),
                 h3('Diagnostics'),
                 plotOutput('plot_diag'),
                 downloadButton('download_estimates', 'Download Estimates Table'),
                 downloadButton('download_gof', 'Download GOF Table'),
                 downloadButton('download_methods', 'Download Methods Table'),
                 downloadButton('download_diag', 'Download Plots')
                 )
        )
    )
  )
)
