# Packages ----------------------------------------------------------------
library(shiny)
library(shinyjs)
library(ggplot2)
library(fitdistrplus)
library(actuar)


# Functions ---------------------------------------------------------------

numextractall <- function(string) { 
  # http://stackoverflow.com/questions/19252663/extracting-decimal-numbers-from-a-string
  as.numeric(unlist(regmatches(string, gregexpr("[[:digit:]]+\\.*[[:digit:]]*", string)), 
                    use.names = FALSE))
} 
