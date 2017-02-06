tabPanel(
  title = 'Settings',
  id = 'tab_settings',
  value = 'tab_settings',
  icon = icon('wrench'),
  
  sidebarLayout(
    sidebarPanel(
      h4('Specify variables'),
      uiOutput('y'),
      uiOutput('species'),
      br(),
      h4('Plot settings'),
      checkboxInput('log_x', 'Logarithmic x-axis?', value = TRUE),
      checkboxInput('label_spec', 'Label species?', value = TRUE)
    ),
    
    mainPanel(
      plotOutput('plot_settings'),
      downloadButton('download_plot_settings', 'Download Plot')
    )
  )
)
