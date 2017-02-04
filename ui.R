tagList(
  useShinyjs(),
  navbarPage(
    title = 'SSD',
    id = 'main_nav',
    inverse = TRUE,
    fluid = FALSE,
    collapsible = TRUE
    
    # tabs
    , source(file.path('ui/ui_tab_load.R'), local = TRUE)$value
    , source(file.path('ui/ui_tab_settings.R'), local = TRUE)$value
    , source(file.path('ui/ui_tab_results.R'), local = TRUE)$value
  )
)
