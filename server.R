
# allow uploading files up to 10MB
options(shiny.maxRequestSize = 10*1024^2) 

shinyServer(function(input, output, session) {
  source(file.path("server", "server_tab_load.R"), local = TRUE)$value
})
