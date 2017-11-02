  # R Group errors
  # Anna Moeller
  # 9/11/2017

  # Object doesn't exist error
  a <- c(1, 4, 6, 2, 6)
  a + b
  
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
  