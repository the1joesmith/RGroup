  # R Group errors
  # Anna Moeller
  # 9/11/2017

  # Set working directory
  setwd("/Users/annamoeller/GitHub/RGroup") # Mac
  setwd("C:/Users/anna.moeller/Documents/GitHub") # PC
  
  # Most common problems: 
  # typos, 
  # punctuation error,
  # class mismatches, 
  # forgetting to run something, 
  # overwriting objects/functions,
  # not matching function requirements

  # http://blog.revolutionanalytics.com/2015/03/the-most-common-r-error-messages.html
  # "could not find function" errors, usually caused by typos or not loading a required package
  # "Error in if" errors, caused by non-logical data or missing values passed to R's "if" conditional statement
  # "Error in eval" errors, caused by references to objects that don't exist
  # "cannot open" errors, caused by attempts to read a file that doesn't exist or can't be accessed
  read.csv("tidyverse/R_group_formatting.csv")
  # "no applicable method" errors, caused by using an object-oriented function on a data type it doesn't support
  # "subscript out of bounds" errors, caused by trying to access an element or dimension that doesn't exist
  # package errors caused by being unable to install, compile or load a package.
  
  ### Tangent: save vs. saveRDS
  x <- 1:10
  save(x, file = "RGroup/testx.RData")
  load("RGroup/testx.RData")
  
  saveRDS(x, "RGroup/testx.rds")
  newobj <- readRDS("RGroup/testx.rds")
  
  ### End tangent
  
  # Object not found error
  a <- c(1, 4, 6, 2, 6)
  a + b
  
  my.fn(5)
  my.fn <- function(x){
    x + 3
  }
  myfn(5)
  
  # Class mismatch error
  b <- c("Anna", "Jenny", "Molly", "Kelsey")
  a + b
  
  # Punctuation errors
  head(a))
  
  c <- NULL
  for(i in 1:length(a){
    c[i] <- a[i] + 3
  }
  
  # Package overwriting
  library(dplyr)
  library(raster)
  
  xx <- iris %>%
    select(Sepal.Length, Species)
  
  # Fix
  xx <- iris %>%
    dplyr::select(Sepal.Length, Species)
  
  # Fix packages
  detach("package:dplyr", unload = T)
  detach("package:raster", unload = T)

  # More intense versions
  r <- raster(1:100, nrow = 5)
  ?raster
  r <- raster(matrix(1:100, nrow = 5))
  plot(r)
  
  ### Tangent:  S4 objects have attributes in slots
  str(r)
  slotNames(r)
  r@extent@xmin
  ### End tangent
  
  # What other things can we do when creating our raster? 
  # Read help file to find additional arguments
  mat <- matrix(1:100, nrow = 5)
  ?raster
  r <- raster(mat, xmx = 0.5)
  
  # Write your own error message
  # stopifnot, stop, warning, assert_that/see_if/validate_that
  # All work inside functions, which is a great reason for using functions!
  
  # stopifnot creates its own error message for you.
  # Write your own with stop() and warning()
  my.fn <- function(x){
    # takes x: a length > 0 numeric input
    if(!is.numeric(x)){
      stop("x isn't numeric")
    }
    stopifnot(length(x) > 0)
    if(any(is.na(x))){
      warning("You fed this an NA")
    }
    x + 5
  }
  my.fn(2)
  my.fn("b")
  my.fn(as.numeric(c(2, NA)))
  
  # assertthat
  # https://github.com/hadley/assertthat
  library(assertthat)
  x <- "RGroup"
  
  assert_that(is.numeric(x))
  see_if(is.numeric(x))
  validate_that(is.numeric(x))
  
  tst <- assert_that(is.numeric(x))
  tst 
  class(tst)
  
  tst <- see_if(is.numeric(x))
  tst <- validate_that(is.numeric(x))

  
  my.fn <- function(x, y){
    assert_that(is.numeric(x))
    assert_that(is.numeric(y))
    x + y
  }
  
  on_failure(my.fn) <- function(call, env) {
    paste0("The value of x is ", deparse(call$x),
           "The value of y is ", deparse(call$y))
  }
  # This doesn't work yet, but we'll try to fix it. 
  
  out <- my.fn(2, 5)
  out2 <- my.fn(2, "b")
  