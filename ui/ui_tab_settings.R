tabPanel(
  title = 'Settings',
  id = 'tab_settings',
  value = 'tab_settings',
  icon = icon('wrench'),
  
  sidebarLayout(
    sidebarPanel(
      uiOutput('y'),
      uiOutput('species'),
      uiOutput('group'),
      checkboxInput('log_x', 'Logarithmic x-axis?', value = TRUE)
    ),
    
    mainPanel(
      tableOutput('head_data'),
      plotOutput('plot_settings')
    )
  )
)
