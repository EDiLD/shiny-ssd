output$downloadReport <- downloadHandler(
  filename = function() {
    paste('my-report', sep = '.', switch(
      input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
    ))
  },
  
  content = function(file) {
    # data for report
    df_raw <- get_data()
    df <- get_cdata()
    input <- input
    hcx <- hcx()
    hcxs <- hcxs()
    cis <- cis()
    pdat <- pdat()
    bootdat <- bootdat()
    
    # # setup
    # src <- normalizePath('report.Rmd')
    # # temporary folder
    # owd <- setwd(tempdir())
    # on.exit(setwd(owd))
    # file.copy(src, 'report.Rmd', overwrite = TRUE)
    
    library(rmarkdown)
    out <- render('report.Rmd', switch(
      input$format,
      PDF = pdf_document(), HTML = html_document(), Word = word_document()
    ))
    file.rename(out, file)
  }
)
