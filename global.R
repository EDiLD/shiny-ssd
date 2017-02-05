# Packages ----------------------------------------------------------------
library(shiny)
library(shinyjs)
library(ggplot2)
library(fitdistrplus)
library(actuar)
library(tidyr)


# Functions ---------------------------------------------------------------

numextractall <- function(string) { 
  # http://stackoverflow.com/questions/19252663/extracting-decimal-numbers-from-a-string
  as.numeric(unlist(regmatches(string, gregexpr("[[:digit:]]+\\.*[[:digit:]]*", string)), 
                    use.names = FALSE))
} 


geomean = function(x, na.rm = TRUE){
  # http://stackoverflow.com/questions/2602583/geometric-mean-is-there-a-built-in
  exp(sum(log(x[x > 0]), na.rm = na.rm) / length(x))
}
