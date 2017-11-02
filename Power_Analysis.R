################################################################################
# Power analysis demonstration
# Kenneth Loonam
# October, 2017
################################################################################
#Install Packages
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
# set packages
packages <- c("ggplot2","pwr")

# run install and load function
ipak(packages)

################################################################################
install.packages("ggplot2")
install.packages("pwr")
library("pwr")
library("ggplot2")

################################################################################
# Intro to pwr package
# Can be used to calculate number of covariates, sample size, significance 
# level, effect size, or power given the other four.
# Contains functions for multiple analysis methods including chi squared, ANOVA,
# t-tests, and GLMs. We'll use the GLM function for most of the demonstration.

# GLM power analysis
pwr.f2.test(u=2, v=20, f2=NULL, sig.level=.05, power=.9)
# u is the number of covariates (degrees of freeedom 1)
# v is the number of samples (n) (degrees of freedom 2)
# f2 is the effect size (solving for)
# sig.level is the p value being used
# power is the probability of detecting effect

# Equivalent ANOVA power analysis, demonstrates higher power of GLMs
pwr.anova.test(k=2, n=10, f=NULL, sig.level=.05, power=.9)

# Can calculate any of the values 
pwr.f2.test(u=2, v=100, f2=.05, sig.level=.05, power=NULL)
pwr.f2.test(u=2, v=NULL, f2=.1, sig.level=.05, power=.9)

################################################################################
# But who really knows 4 of those 5 things? No one in their first year. 
#   If you do, share your magic with me
# So wouldn't it be a lot more interesting to look at a response variable across
# a range of values for a manipulated variable holding the other three constant?
# I'll save you some time and say yes.
# So lets try to build a function to iterate it over a range for one variable!
# No! Try not. Do, or do not.

strwrs <- function(u,v,f2,sl){
  #A function to return a data frame of power and effect size given p and df
  dthstr <- numeric(1)
  for(i in 1:length(f2)){
    result <- pwr.f2.test(u=u, v=v, f2=f2[i], sig.level = sl, power = NULL)
    dthstr <- c(dthstr, as.numeric(result[5]))
  }
  Power <- dthstr[-1] # Pretty sloppy...
  Effect <- f2
  out <- data.frame(Effect, Power)
  return(out)
}

# Run strwrs with 'x' values for effect size and record the output as empire
x <- c((1:100)/100) # Is there a better way to do this?
lapply(x=x, FUN = pwr.f2.test(u=2,v=50,f2=x,sl=.05))


empire <- strwrs(u=2, v=50, f2=x, sl=.05)
empire
plot(empire)
rebellion <- strwrs(u=2, v=25, f2=x, sl=.05)
plot(rebellion)

################################################################################
# So we can iterate it, and we can visualize it, but damn if it isn't as scruffy
# looking as a nerf herder. The odds of someone liking those plots are 
# approximately 3720 to 1. Let's try to do better.
# There is no try.

# Rephrase for compatability with ggplot2 stat_function (plots a function)
# The output of the function must be single number for stat_function to work
theforce <- function(u,n,f2,sl){
  y <- pwr.f2.test(u=u, v=n, f2=f2, sig.level=sl, power=NULL)
  y$power
}

# Plot that function with different values for n (sample size)
plot <- ggplot(data.frame(x = c(0,1)), aes(x))
plot + stat_function(fun=theforce, args=list(u=1, n=30, sl=.05), 
                         aes(colour="30")) + # Sets values for legend display
  stat_function(fun=theforce, args=list(u=1, n=20, sl=.05), 
                aes(colour="20")) + 
  stat_function(fun=theforce, args=list(u=1, n=10, sl=.05), 
                aes(colour="10")) + 
  scale_colour_manual("N equals", values = rainbow(n=3)) + # Legend title and
  # color values
  labs(title="Effect of Sample Size on Power", x="Effect Size", y="Power")