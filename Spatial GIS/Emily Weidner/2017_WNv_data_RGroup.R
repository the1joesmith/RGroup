# ============================================================================ #

# WEST NILE VIRUS MONITORING PROJECT
# RGROUP - OCTOBER 5TH, 2017

# ============================================================================ #


# Brief overview ------------------------------------------------------------- #


  # CRS = coordinate reference system
    # Defines, with the help of coordinates, how the two-dimensional projection 
    # is related to places on the Earth.


    # IMPORTANT: in R, the notation used to describe the CRS is proj4string 
    # from the PROJ.4 library that performs conversions between projections. 
    # PROJ.4 strings are a compact way to identify a spatial reference system. 
    # Projection, ellipsoid, and datum are attributes of the CRS. 


# A few definitions ---------------------------------------------------------- #


  # proj = projection
    # A means by which you display the coordinate system and your data on a 
    # flat surface. Many different projections exist. Some preserve shape while
    # others preserve distance.


  # ellps = ellipsoid
    # Simple model that descibes the generalized shape of the earth.
    # All mapping and coordinate systems begin with this description.
    # Some ellipsoids fit local regions.
    # Some ellipsoids fit the whole earth.
    # Local ellipses can be more accurate but not useful for other regions.


  # datum = datum
    # Defines the reference/origin and orientation of the coordinate axes.
    # Base information needed to draw the coordinates on a map as it specifies
    # where a clearly identifiable point on earth should appear on a spheriod.


  # EPSG = almost all common spatial reference systems have a recognized
  # integer ID called an EPSG code (from the now-defunct European Petroleum 
  # Survey Group). If you know the EPSG code you won't have to rememeber the 
  # longer projection form. To find codes, you can use an online spatial 
  # reference search or the package rgdal. 


# Commonly used coordinate reference systems --------------------------------- #
 

    # World Gedetic Reference System = WGS
      # Datum = WGS84 (EPSG: 4326)
      # Ellipsoid = WGS84 (originally used GRS80 ellipsoid)
      # Geographic coordinate system = Latitude/Longitude
        # Geographic coordinate reference system based on spheroidal surface 
        # that approximates the surface of Earth.
      # Used by Google Earth and Department of Defense


    # National American Datum = NAD 
      # Datum = NAD83
      # Ellipsoid = GRS80.
      # Projected coordinate system = UTM (Universal Transverse Mercator)
        # UTM, Zone 10 (EPSG: 32610)
        # Projected data - think round object on a flat surface 
        # Projection is a series of transformations which convert the location
        # of points on a curved surface to locations on a flat plane.
      # Divides Earth into sixty zones (6 degree band of Longitude)
      # More locally accurate
      # Commonly used by federal agencies


# Reminder ------------------------------------------------------------------- #


  # NAD 1983 is tied to the North American tectonic plate, which minimizes 
  # changes to coordinate values over time. However, this caused NAD 1983 and 
  # WGS 1984 to drift apart. Coordinates in WGS 1984 and NAD 1983 are around 
  # one to two millimeters apart. GPS systems use the WGS 1984 as a reference 
  # coordinate system. Having all data in same coordinate system not super 
  # important for display purposes but important for complex geoprocessing.


# Useful links --------------------------------------------------------------- #


  # http://resources.esri.com/help/9.3/arcgisengine/dotnet/89b720a5-7339-44b0-8b58-0f5bf2843393.htm
  # http://www.spatialreference.org/
  # https://www.nceas.ucsb.edu/scicomp/recipes/projections
  # https://cran.r-project.org/web/packages/tmap/vignettes/tmap-nutshell.html
  # http://von-tijn.nl/tijn/research/presentations/tmap_user2015.pdf
  # https://cmerow.github.io/RDataScience/05_Raster.html


# Packages ------------------------------------------------------------------- #

  
  library(lubridate)  # makes working with dates and times easier
  library(ggthemes)   # extra themes, geoms, and scales for ggplot2
  library(viridis)    # color scales, colorful and robust to colorblindness
  library(scales)     # good for formatting axes, legends, and breaks
  library(raster)     # required to writeRaster - loads sp as well
  library(rgdal)      # required for GTiff...among other things
  library(FedData)    # to pull elevation data
  library(rasterVis)  # required for gplot (also loads lattice, RColorBrewer)
  library(tidyverse)  # includes the following packages:
                          # ggplot2, for data visualisation
                          # dplyr, for data manipulation
                          # tidyr, for data tidying
                          # readr, for data import
                          # purrr, for functional programming
                          # tibble, for tibbles, re-imagining of dataframes
    

# Ask a couple of questions -------------------------------------------------- #


  # Make EPSG object - from the package rgdal
  # This makes a dataframe of all EPSG codes
  EPSG <- make_EPSG()
  
  
  # Search for Montana state projections
  # The grep function searches for matches to argument pattern (i.e. "montana")
  # The result displays all EPSG codes for the state of Montana
  EPSG[grep("montana", EPSG$note, ignore.case = TRUE), 1:2]

  
  # Get PROJ.4 information for a particular code
  # You're subsetting a specific code so you'll only see that code's info
  subset(EPSG, code==2818)
  
  
  # If you want a list of projections, ellipsoids, and datums
  projInfo("proj")
  projInfo("ellps")
  projInfo("datum")

  
# Load and arrange data ------------------------------------------------------ #

  
  # Read in data
  # stringsAsFactors converts characters to factors, default = TRUE
  # See stringsAsFactors: An unauthorized biography for additional questions.
  wnvData <- read.csv("2017_WNv_data_combined.csv", 
                      stringsAsFactors = FALSE)


  # Change Date from character to Date
  wnvData$Date <- mdy(wnvData$Date, 
                      quiet  = FALSE,
                      locale = Sys.getlocale("LC_TIME"))

  
  # Same as above
  wnvData$Trap.Session <- mdy(wnvData$Trap.Session,
                              quiet  = FALSE,
                              locale = Sys.getlocale("LC_TIME"))
  

# Make spatial data ---------------------------------------------------------- #


  # Pull lat and long from dataframe and make new dataframe
  # dplyr is dead useful for manipulation
  LongLat <- dplyr::select(wnvData,
                           Longitude,
                           Latitude)
  

  # Add a coordinate reference system and make a dataframe
  # Don't use spaces in the string otherwise you'll receive an error message
  wnvLL <- SpatialPointsDataFrame(coords = LongLat,
                                data = wnvData,
                                proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))

  
  # Double-check that wnvLL has projection/coordinate system assigned
  proj4string(wnvLL)


# Change Long/Lat to UTMs ---------------------------------------------------- #

  
  # Question: Is there a way to make a function that will convert lat/long to 
  # UTM and vice versa?

  
  # Transform to UTMs, include your dataframe (wnvLL), and the string or 
  # EPSG code
  wnvUTM <- spTransform(wnvLL,
                     CRS("+proj=utm +zone=10 +ellps=GRS80 +proj=NAD83"))
  
  
  # What does our data look like?
  # str displays the structure of a dataframe
  str(wnvUTM)
  
  
    # The output of str includes:
      # 1. The original data we read
      # 2. The data type of the coordinates
      # 3. The coordinates
      # 4. The bounding box of the coordinates (bbox)
      # 5. The coordinate reference system

  
  # Look at the bounding box (original dataframe)
  wnvUTM@bbox
  
  
  # Look at the proj$string and coordintes
  # Unique simply extracts all unique names with duplicate rows removed
  wnvUTM@proj4string
  unique(wnvUTM@coords)
  
  
  # Look at trap site names
  unique(wnvUTM$Site.name)


# Get FedData ---------------------------------------------------------------- #

  
  # Question: is there a way to make a function that can pull min and max 
  # values from a spatial points dataframe (with a buffer) so you can make a
  # polygon from extent?

  
  # Make extent of map, order = xmin, xmax, ymin, ymax
  ex <- extent(c(-120.983434, -120.397992, 43.449509, 43.834399))
  
  
  # Make a spatial reference
  sr <- "+proj=longlat +ellps=WGS84 +datum=WGS84"
  
  
  # Make polygon from extent and spatial reference
  wnvpoly <- polygon_from_extent(raster::extent(ex), 
                                 proj4string = sr)
  
  
  # Using FedData, pull National Elevation Data (NED)
  ned <- get_ned(template = wnvpoly, 
                 label = "WNv Project NED",
                 res = 13) #13 denotes the 1/3 arc-second dataset - 10m res
  
  
  # Write NED raster for later use
  writeRaster(ned, "WNvElevationRaster", format = "GTiff", overwrite = TRUE)


# Data visualization ----------------------------------------------------------#
  
  
  
  # A levelplot is a type of graph used to display a surface in two rather
  # than three dimensions.levelplot is from the package rasterVis, follow link 
  # for a nice demo about various package functions:
  # https://oscarperpinan.github.io/rastervis/
  
  
  # What does "ned" data look like on a levelplot? It looks freaking sexy...
  levelplot(ned, contour = TRUE)
  
  
  # SPDF more difficult to work with - make df
  wnvdf <- as.data.frame(wnvLL)

  
  # Subset data - lose date
  wnvsub <- dplyr::select(wnvdf,
                          Site.name,
                          Mosquitoes,
                          Longitude,
                          Latitude)
  
  
  # Sum number of mosquitoes by site and location
  wnvsub <- aggregate(Mosquitoes ~ Site.name + Longitude + Latitude,
                       data = wnvdf,
                       FUN  = sum)
 
  
  # If you need more than 9-12 colors (I have 16 sites), you can create a color
  # palette with colorRampPalette where you specify the max number of colors (9)
  # and the palette ("Oranges"). You use getPalette when plotting
  # See link for in-depth explanation and lists of diverging, sequential, and 
  # qualitative colors. http://www.sthda.com/english/wiki/colors-in-r
  
  
  # Create a color palette to support 16 sites. I HATE pastels but they show up
  # well on the plot. Play around with this and find what works.
  getPalette <- colorRampPalette(brewer.pal(9, "Pastel1"))
 
  
  # Pull and plot elevation data, I'm positive you can make a funciton for this
  gplot(ned) + 
    
    # Fills tile based on values - in this case elevation
    geom_tile(aes(x    = x, 
                  y    = y, 
                  fill = value)) +
    
    # Wraps 1d sequence into 2d
    facet_wrap(~ variable) +
    
    # Fills elevation gradient and labels legent
    scale_fill_viridis(option = "magma", 
                       "Elevation (m)") +
    
    # Add locations sized based on total # of mosquitoes caught at site
    geom_point(data      = wnvsub,
               aes(x     = Longitude, 
                   y     = Latitude,
                   size  = Mosquitoes,
                   color = Site.name)) +
    
    # Fills sites so all 16 are different colors
    scale_color_manual(values = getPalette(16)) +
    
    # Labels plot legend and axes, the "\n" denotes a line break
    labs(color = "Sites") +
    xlab("\nLongitude") +
    ylab("Latitude\n") +
    
    # Gets rid of gray background
    theme_bw() +
    
    # Alters elements of plot 
    theme(axis.line        = element_line(colour = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border     = element_blank(),
          strip.text       = element_blank(),
          axis.title       = element_text(size = 14),
          axis.text.x      = element_text(size = 12),
          axis.text.y      = element_text(size = 12),
          legend.title     = element_text(size = 12),
          legend.text      = element_text(size = 12)) +
    
    # Changes the order of the legend
    guides(color = guide_legend(order = 1),
           size  = guide_legend(order = 2))  

  
  # Remember, this is just one map. You can do eight bajillion things with sp,
  # raster, rasterVis, ggplot2, ggmap, tmap etc. The sky is the limit.
  

# More data visualization ---------------------------------------------------- #


  # Get rid of unneeded columns for the first figures
  wnvPlot <- dplyr::select(wnvdf,
                           Trap.Session,
                           Site.name,
                           Mosquitoes)
  
  ggplot(wnvPlot,
         aes(x    = Trap.Session,
             y    = Mosquitoes,
             fill = Site.name)) +
    
    
    # Add bars with black outline and appropriately spaced apart
    geom_bar(color    = "black",
             stat     = "identity",
             position = "dodge") + 
    
    
    # Fill bars with color based on "Trap site"
    scale_fill_viridis(discrete  = TRUE,
                       name      = "Trap site") +
    
    
    # Change x-axis label, breaks, and limits
    scale_x_date(name   = "\nTrap Session",
                 breaks = wnv$Trap.Session,
                 labels = date_format("%b %d")) +
    
    
    # Change y-axis name, breaks, and limit
    scale_y_continuous(name  = "Number of mosquitoes trapped\n",
                       limits = c(0, 60),
                       breaks = seq(0, 55, by = 5)) +
    
    
    # Change text size of axes, title, and legend
    theme(axis.title   =  element_text(size  = 14),
          axis.text.x  =  element_text(size  = 12, angle  = 45, hjust  = 1),
          axis.text.y  =  element_text(size  = 12),
          legend.title =  element_text(size  = 12),
          legend.text  =  element_text(size  = 12))



# A handy function for coordinate conversion --------------------------------- #
  
  
  # Coordinate conversion function from Longitude/Latitude to UTMs
  LongLatToUTM<-function(x,y,zone){
    
    xy <- data.frame(ID = 1:length(x), 
                     X = x, 
                     Y = y)
    
    coordinates(xy) <- c("X", "Y")
    
    proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")  
    
    res <- spTransform(xy, 
                       CRS(paste("+proj=utm +zone=",zone," ellps=GRS80",sep='')))
    
    return(as.data.frame(res))
  }

  
  # Give it a whirl
  LongLatToUTM(wnvLL$Longitude, wnvLL$Latitude, 10)
  
  
# A function to write df to clipboard -----------------------------------------#
  
  
  # Write dataframe to excel to make table
  write.excel <- function(x,row.names = FALSE,
                          col.names = TRUE,...) {
    write.table(x,
                "clipboard",
                sep = "\t",
                row.names = row.names,
                col.names = col.names,...)
  }
  
  
  # copy to clipboard and then paste in your program of choice
    write.excel(wnvData)
  