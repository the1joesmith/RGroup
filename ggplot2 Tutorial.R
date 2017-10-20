## DATA VISUALIZATION WITH GGPLOT2
## OCTOBER 26, 2017
## Kelsey Wellington

##----------------------------------------------------------------------------##

## Limits to plotting with base plot:
    # Plot is drawn as an image, cannot manipulate it once it's made
        # Can only add to it
    # Need to add legend manually
    # Many base package plotting functions each with their own code; difficult
    # to master individually

## Install either the tidyverse:
    install.packages("tidyverse")
    library(tidyverse)
#  or just the package:
    install.packages("ggplot2")
    library(ggplot2)

##----------------------------------------------------------------------------##

## The Grammar of Graphics
    
    # Enables us to concisely describe the components of a graphic, provides a 
    # strong foundation for understanding many graphics.

    # Graphics are distinct layers of grammatical elements:
        # Data
        # Aesthetics: the scales onto which data is mapped; represent variables
        # Geometries: the visual elements used for data; represent data points;
        #     control the type of plot
        # Others: facets, statistics, coordinates, themes

  # Begin all plots with the function ggplot().  This creates a coordinate
  # system that you can add layers to.  The first argument is the dataset,
  # followed by the variables you wish to map.
    
  # Example:

  ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width))
    
    # iris = dataset
    # aes = aesthetics
  
  #But this only creates an empty plot.  We need to add our geometry:
  
  ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) + geom_point()
  
    # geom_point() = geometry

    # We can assign the base layer to an object, then recycle it with a variety
    # of plot types.

##----------------------------------------------------------------------------##

## Aesthetics

   # Try to keep data and aesthetics layer in same ggplot function definition.
    # Typical visible aesthetics:
        # x
        # y
        # color (or col): color of dots, outlines of shapes
        # fill: fill color
        # size: point diameter, line thickness, font size
        # alpha: transparency of shape
        # linetype: line dash pattern (equivalent to lty in base plot)
        # labels: direct labels of an item directly on a plot
        # shape: shape of point (equivalent to pch in base plot)
        # stroke: modify border width of shapes

    # Many of the above function as both aesthetic mappings and attributes.
        # Easy to confuse the two.
        # Variables in a data frame are mapped to aesthetics in aes()
        #   within ggplot().
        # Visual elements are set by attributes in specific geom layers.

        # Examples of mapping aesthetics:
  
          ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, col = Species)) + 
            geom_point()

          ggplot(mtcars, aes(x = mpg, y = qsec, col = factor(cyl))) + geom_point()
          
          ggplot(mtcars, aes(x = mpg, y = qsec, col = factor(cyl),
                             shape = factor(am))) + geom_point()
          
          ggplot(mtcars, aes(x = mpg, y = qsec, col = factor(cyl),
                             shape = factor(am), size = hp/wt)) + geom_point()
       
        # Important not to include too many aesthetic mappings.  This makes the
        # plot too complex and therefore less readable.
        
        # A note on the "shape" call: ggplot2 only uses six shapes at a time.
        # By default, additional groups will go unplotted if you assign a
        # variable with more than six categories to "shape".
          
          #Example:
          
          ggplot(mpg, aes(x = displ, y = hwy, shape = class)) + geom_point()
        
      # Aesthetics vs. attributes:
          
          ggplot(mtcars, aes(x = wt, y = mpg, col = factor(cyl), size =4)) + 
            geom_point()
          
          ggplot(mtcars, aes(x = wt, y = mpg, col = factor(cyl))) + 
            geom_point(size = 4)

##----------------------------------------------------------------------------##
          
## Geometries
  
  #Visual elements of a plot: points, lines, bars, ribbons, etc.
  
  # The type of plot will be determined by the number of variables and the
  # type of variable (discrete vs. continuous).
  
    # Bar charts use bar geoms, line charts use line geoms, etc.
          
  # We can also assign aesthetics mappings inside a specific geom in order to layer
  # geoms on top of each other. This means we can control the aesthetic mappings
  # of each layer independently.
          
  # eg, + geom_point(aes(col = Species))
  
  # geom_point() = scatterplot
  # geom_smooth() = fits a smooth line to the data
  # geom_bar() = bar chart
  # geom_boxplot() = boxplot
  
  # There are over 30 geoms in the ggplot2 package, with more in extension
  # packages. The cheatsheet is a good resource for this.
          
  # We can use multiple geoms in the same plot:
         
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + geom_point() + 
      geom_smooth()

##----------------------------------------------------------------------------##          

## Facets
  
  # Divide a plot into subplots based on the values of discrete variables.
  
  # Faceting with a single variable: 
          
    ggplot(mpg, aes(displ, hwy)) + geom_point() + facet_wrap( ~ class, nrow = 2)
    
    #Advantages to plotting with facets vs. colors to distinguish variables:
    
    ggplot(mpg, aes(displ, hwy, col = class)) + geom_point()
    
  # Can facet plots with combinations of multiple variables using facet_grid().
  
##----------------------------------------------------------------------------##
          
## Statistics

  # Can be called independently and from within a geom, can generally use geoms
  # and stats interchangeably because every geom has a default stat and every
  # stat has a default geom.
  
  # Example:
    
    ggplot(data = diamonds) + geom_bar(aes(x = cut))
    
    ggplot(data = diamonds) + stat_count(aes(x = cut))
    
  # Main reasons for explicitly using stats:
      # Want to override the default stat
      # Want to override the default mapping
      # Want to highlight certain statistical transformations in your code
    
##----------------------------------------------------------------------------##
    
## Position Adjustments
    
  # Determine how to arrange geoms, ie, stacked bars, side-by-side bars,
  # jittered points.
  
  # Example:
    
    ggplot(diamonds) + 
      geom_bar(aes(x = cut, fill = clarity), position = "fill")
    
    ggplot(diamonds) + 
      geom_bar(aes(x = cut, fill = clarity), position = "dodge")
    
    
##----------------------------------------------------------------------------##          

## Coordinates          
  
  # Default coordinate system is the Cartesian coordinate system.
  
  # coord_flip() will flip the x and y axes; use for horizontal barcharts.
  # coord_polar() will turn a bar chart into a pie chart.

##----------------------------------------------------------------------------##

## Scales
    
  # Use for mapping data values to visual values of an aesthetic.
  # Color and fill scales, x and y location scales (eg, log10), shape and size
  # scales.
  
##----------------------------------------------------------------------------##
          
## Themes          
  
  # Determine the appearance of your plot, specifically the background color
  # and grid lines.
    
  # theme_bw() = white background with grid lines
  # theme_dark() = dark backgournd for contrast
  # See cheatsheet for more.
    
##----------------------------------------------------------------------------##

## qplot
    
  # Stands for "quick plot, fairly similar to base blot.
  # Enables you to quickly produce graphs using ggplot2, but you lose a fair
  # bit of complexity.
    
    qplot(Sepal.Length, Sepal.Width, data=iris, shape=Species, col = Species)
  
  # Can call geom within the qplot function to specify a plot type.
    
    qplot(Species, Sepal.Width, data = iris, geom=c("boxplot"), col = Species)
    
##----------------------------------------------------------------------------##

## Examples and Fun Stuff    

ggplot(mpg, aes(cty)) + 
  geom_density(aes(fill = factor(cyl)), alpha = 0.8) + 
      labs(title="Density Plot", 
           subtitle="City Mileage Grouped by Number of Cylinders",
           caption="Source: mpg",
           x="City Mileage",
           fill="# Cylinders") +
  theme_classic()

ggplot(diamonds, aes(carat, price)) +
  geom_point(aes(colour = cut), alpha = .05) +
  guides(col = guide_legend(override.aes = list(alpha = 1)))


df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)
ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_fill_gradient(low = "white", high = "red") +
  coord_fixed()

best_in_class <- mpg %>%
  group_by(class) %>%
  filter(row_number(desc(hwy)) == 1)
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(col = class)) +
  geom_label(aes(label = model), data = best_in_class, nudge_y = 2, alpha = 0.5) 

library(wesanderson) # Color palettes from Wes Anderson movies.
ggplot(mtcars, aes(wt, mpg, col = factor(cyl))) + 
  geom_point(size = 3) + 
  scale_color_manual(values = wes_palette("FantasticFox"))

library(maps)
library(grid)
library(gridExtra)
state_map <- map_data("state")
x = data.frame(region = tolower(rownames(state.x77)), 
               murder = state.x77[, "Murder"], 
               stringsAsFactors = FALSE)
ggplot(x, aes(map_id = region)) + 
  geom_map(aes(fill = murder), map = state_map) + 
  scale_fill_gradient2(name = NULL, low = "aquamarine", 
                       mid = "cyan3", high = "darkorchid", 
                       na.value = "grey50", guide = "colourbar") + 
  expand_limits(x = state_map$long, y = state_map$lat) + 
  labs(x = "Longitude", y = "Latitude", 
       title = "1976 U.S. Murders and Non-negligent 
       Manslaughters per 100,000 People") + 
  theme_bw()

##----------------------------------------------------------------------------##

## Helpful Resources

  # The "Data visualization" chapter from "R for Data Science":
      # http://r4ds.had.co.nz/data-visualisation.html
          
  # The "Graphics for communication" chapter from "R for Data Science":
      # http://r4ds.had.co.nz/graphics-for-communication.html
  
  # All "Data Visualization with ggplot2" courses from DataCamp.
          
  # The ggplot2 reference page from tidyverse:
      # http://ggplot2.tidyverse.org/reference/