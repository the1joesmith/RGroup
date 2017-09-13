  # R object classes
  # Anna Moeller
  # 9/12/2017

  # Vectors
  a <- c(1, 5, 235, pi)
  b <- c("A", "B", "f", "gorilla")
  c <- as.factor(seq(1:4))
  d <- as.Date(c("2017-04-05", "2017-04-09", "2017-04-01", "2017-03-05"))
  is.female <- c(T, F, T, T)

  # Data.frame
  dat <- data.frame(weight = a,
                    name = b,
                    finisher = c,
                    date = d,
                    is.female = is.female,
                    stringsAsFactors = F)

  # Examples with vectors
  a
  a + 3
  a + c(1, 2, 1, 2)
  a + c(4, 2, 1) # Warning

  # Making a change just to see what happens. Playing with atom.
