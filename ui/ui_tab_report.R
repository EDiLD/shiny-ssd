tabPanel(
  title = 'Report',
  id = 'tab_report',
  value = 'tab_report',
  icon = icon('book'),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons('report_format', 'Download format', c('PDF', 'HTML', 'Word'),
                   inline = TRUE),
      downloadButton(outputId = 'report', label = 'Download Report')
    ),
    mainPanel(
    )
  )
)
