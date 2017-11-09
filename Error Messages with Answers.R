  # R Group errors - with answers
  # Anna Moeller
  # 9/11/2017
  
  # Most common R errors
  # http://blog.revolutionanalytics.com/2015/03/the-most-common-r-error-messages.html
  # "could not find function" errors, usually caused by typos or not loading a required package
  # "Error in if" errors, caused by non-logical data or missing values passed to R's "if" conditional statement
  # "Error in eval" errors, caused by references to objects that don't exist
  # "cannot open" errors, caused by attempts to read a file that doesn't exist or can't be accessed
  # "no applicable method" errors, caused by using an object-oriented function on a data type it doesn't support
  # "subscript out of bounds" errors, caused by trying to access an element or dimension that doesn't exist
  # package errors caused by being unable to install, compile or load a package.
  
  # Most common problems: 
  # typos, class mismatches, forgetting to run something, overwriting objects/functions
  
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
  
  # Fix packages
  detach("package:dplyr", unload = T)
  detach("package:raster", unload = T)
  
  # More intense versions
  r <- raster(1:100, nrow = 5)
  ?raster
  r <- raster(matrix(1:100, nrow = 5))
  plot(r)
  
  # What other things can we do when creating our raster? 
  # Read help file to find additional arguments
  mat <- matrix(1:100, nrow = 5)
  ?raster
  r <- raster(mat, xmx = 0.5)
  
  # Write your own error message
  # stopifnot, stop, warning, assert_that/see_if/validate_that
  # All work inside functions, which is a great reason for using functions!
  
  # stopifnot creates its own error message for you.
  my.fn <- function(x){
    # x must be numeric
    
    
    x + 5
  }
  my.fn(c(1, 1, 23, 4, "b"))
  
  # With stop, you can create your own error message
  my.fn <- function(x){
    # x must be numeric
    
    
    x + 5
  }
  my.fn(c(1, 1, 23, 4))
  my.fn(c(1, 1, 23, 4, "b"))
  
  # Try creating a warning 
  
