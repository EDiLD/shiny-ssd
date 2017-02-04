tabPanel(
  title = 'Settings',
  id = 'tab_settings',
  value = 'tab_settings',
  icon = icon('wrench'),
  
  sidebarLayout(
    sidebarPanel(
      uiOutput('y'),
      uiOutput('species')
    ),
    mainPanel(
      plotOutput('plot_settings')
    )
  )
)
