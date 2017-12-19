
library(sp)
library(raster)
library(rgdal)
library(dplyr)
library(ggplot2)
library(grid)



setwd("/Users/joseph.smith/Box Sync/projects/roundup_project")


# modify rasterOptions() for quicker raster calculations
rasterOptions(chunksize=5e+08, maxmemory=2e+09)


# set file path for reading various shapefiles from my Google Drive folder
dsn <- "/Users/joseph.smith/Google Drive/shapefiles"

# establish a common CRS for the map
rcrs <- CRS("+proj=utm +zone=12 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")



# read layers for map using rgdal
rivers <- readOGR(dsn=dsn, layer="Major_Streams1993")
# or alternatively, using raster::shapefile
rivers <- shapefile(paste(dsn,"Major_Streams1993",sep="/"))

rivers # has an unknown CRS

# tell R what the CRS of these coordinates is
proj4string(rivers) <- "+proj=lcc +lat_1=45 +lat_2=49 +lat_0=44.25 +lon_0=-109.5 +x_0=600000 +y_0=0 +ellps=GRS80 +units=m +no_defs"

# ... and transform it
rivers <- spTransform(rivers, rcrs)

# maybe you want some roads
roads <- spTransform( readOGR(dsn=dsn, layer="ne_10m_roads_north_america"), rcrs)

# maybe you want some management boundaries
pacs <- spTransform( readOGR(dsn=dsn, layer="MontanaPACS"), rcrs )

# towns? why not
towns <- readOGR(dsn=dsn, layer="Towns2013")

# treatment areas would be nice
sgi <- readOGR(dsn=paste(getwd(),"shapefiles",sep="/"), layer="SGI_grazing_2016")

proj4string(sgi) <- "+proj=utm +zone=12 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
	
# try plotting towns and pacs
plot(towns)
plot(pacs, add=T)

# pacs don't show up because they're in a different CRS. 'plot' doesn't do any on-the-fly
# transformations of your spatial data, so you'll have to do it yourself.
plot(spTransform(pacs, CRS(proj4string(towns))), add=T)


# fix transformation of towns
towns <- spTransform(towns, rcrs)

# read leks shapefile
leks <- readOGR(dsn=paste(getwd(),"shapefiles",sep="/"), layer="roundup_leks_2011_2016")

# plot using base R
plot(leks)
lines(pacs)
lines(rivers, col="blue")


# read in raw lek counts
lektab <- read.csv("study_area_lek_counts_thru_2016.csv")

# extract just the highest count of males for each year at each lek
maxmale_table <- summarize(group_by(droplevels(lektab[lektab$LEK_NAME %in% leks$LEK_NAME,]), LEK_NAME, YEAR), maxmale=max(MALES))

# take the median value over the past 10 years
median_maxmale <- summarize(group_by(maxmale_table[maxmale_table$YEAR > 2006,], LEK_NAME), med=median(maxmale, na.rm=T))

# append these median high male counts to the lek shapefile
leks$median <- median_maxmale$med[match(leks$LEK_NAME, median_maxmale$LEK_NAME)]

table(is.na(leks$median))

# get rid of leks that have an 'NA' value for median
leks <- leks[!is.na(leks$median),]


# plot those median high male counts using sp::bubble
bubble(leks[!is.na(leks$median),], zcol="median")


# make a nicer map using the tmap package
library(tmap)
library(tmaptools)

# tm_shape is where you specify the data (must be a spatial class,
# e.g., SpatialPointsDataFrame or raster)
map <- tm_shape(rivers[rivers$CLASS == 1,], bbox=bb(leks)) +
	# then follow this with a mapping command (lines, polygons, fill, borders, text, etc.)
	tm_lines(col='dodgerblue', lwd=1.5) +
# add the roads layer, data first...
tm_shape(roads) +
	# then mapping.
	tm_lines(col='black', lwd=1) +
# and so on
tm_shape(pacs) +
	# and so forth.
	tm_fill(col='gray70', alpha=0.5) +
tm_shape(leks[leks$active == 1,]) +
	tm_symbols(	size='median',
				shape=16,
				col='tomato',
				scale=0.75, sizes.legend=c(10,20,50,100),
				title.size="Lek size (males)") +
tm_shape(towns[towns$Name %in% c("Roundup","Ryegate","Lavina"),]) +
	tm_bubbles(size=0.2, col="white", border.col="black") +
	tm_text('Name', size=1, fontface=3, auto.placement=F,
			just=c('left','top'), xmod=0.5, ymod=-0.5) +
tm_shape(sgi) +
	tm_borders(col="black", lwd=0.5) +
# slap a scale bar on there. There are also commands for adding north arrows, additional
# legend items, titles, text, etc.
tm_scale_bar(size=1, position=c("left","top")) +
# tm_layout is where you specify legend and global display parameters.
tm_layout(legend.position=c("right","bottom"),
			legend.frame=F,
			legend.text.size=1,
			legend.title.size=1.25)

# you can write your map to a jpeg, png, pdf, or whatever using save_tmap
save_tmap(map, filename="output/testmap.jpg", width=7, height=5, units="in", dpi=300)












elev <- raster("~/Box Sync/projects/Nest Selection/data/rasters/elevation")

elev <- aggregate(elev, fact=3, fun=mean)

slope <- terrain(elev, opt="slope")

aspect <- terrain(elev, "aspect")

hillshade <- hillShade(slope, aspect, angle=46, direction=0)

hillbreaks <- c(0.4,0.625,0.65,0.675,0.7,0.725,0.75,0.775,1)

proj4string(hillshade) <- proj4string(roads)



# make our map again, but add the hillshade layer first
tm_shape(hillshade, bbox=bb(hillshade, ext=0.9)) +
	tm_raster(	col="values", palette="Greys",
				n=8, breaks=hillbreaks, alpha=0.30, legend.show=F) +
tm_shape(rivers[rivers$CLASS == 1,]) +
	tm_lines(col='dodgerblue', lwd=1.5) +
tm_shape(roads) +
	tm_lines(col='black', lwd=1) +
tm_shape(pacs) +
	tm_fill(col='gray70', alpha=0.5) +
tm_shape(leks[leks$active == 1,]) +
	tm_symbols(	size='median',
				shape=16,
				col='tomato',
				scale=0.75, sizes.legend=c(10,20,50,100),
				title.size="Lek size (males)") +
tm_shape(towns[towns$Name %in% c("Roundup","Ryegate","Lavina"),]) +
	tm_bubbles(size=0.2, col="white", border.col="black") +
	tm_text('Name', size=1, fontface=3, auto.placement=F,
			just=c('left','top'), xmod=0.5, ymod=-0.5) +
tm_shape(sgi) +
	tm_borders(col="black", lwd=0.5) +
tm_scale_bar(size=1, position=c("left","top")) +
tm_layout(legend.position=c("right","bottom"),
			legend.frame=F,
			legend.text.size=1,
			legend.title.size=1.25)




# Say we wanted to depict bird abundance in a continuous, smoothed fashion.
# We can easily go back and forth between raster and vector representations
# in R, as the raster and sp packages are very compatible with one another.

# make a blank raster covering the study area
library(rgeos) # for gBuffer()
b <- raster(ext=extent(gBuffer(leks, width=1000)), res=c(250,250), crs=rcrs)

# give all cells in b a value of zero
b[] <- 0

# identify cells in b that contain a lek
lekcells <- cellFromXY(b, leks)

# assign median high male counts to these cells
b[lekcells] <- leks$median

# now we have a raster representation of our vector (point) data
# next, we use the focal() function to get the sum of all the counts within
# a user-specified neighborhood
f <- focal(b, w=focalWeight(b, d=5000, type="circle"), fun=sum, na.rm=T, pad=T, padValue=NA)

# the raster package does something funny with focal calculations--it weights
# each cell in the focal window such that the sum of weights = 1. This is annoying
# if you want each cell to represent the data on the scale of the original raster
f <- f/modal(focalWeight(b, d=5000, type="circle"))

# a Gaussian kernel might smooth this out a little better.

# first, lets plot a circlular and Gaussian kernel so you can see how
# the weighting differs between the two approaches
dev.new(); par(mfrow=c(1,2))
plot(raster(focalWeight(b, d=5000, type="circle")))
plot(raster(focalWeight(b, d=3000, type="Gauss")))


f <- focal(b, w=focalWeight(b, d=3000, type="Gauss"), fun=sum, na.rm=T, pad=T, padValue=NA)

# divide by peak weight in Gaussian kernel 
f <- f/max(focalWeight(b, d=3000, type="Gauss"))

plot(f)
points(leks)
contour(f, add=T, nlevels=4)


# neat.


# make our map again, but add the smoothed abundance raster first
tm_shape(f, bbox=bb(f, ext=1)) +
	tm_raster(	col="layer", palette="Oranges",
				n=8, alpha=0.75, legend.show=F) +
tm_shape(rivers[rivers$CLASS == 1,]) +
	tm_lines(col='dodgerblue', lwd=1.5) +
tm_shape(roads) +
	tm_lines(col='black', lwd=1) +
tm_shape(pacs) +
	tm_fill(col='gray70', alpha=0.3) +
# tm_shape(leks[leks$active == 1,]) +
	# tm_symbols(	size='median',
				# shape=16,
				# col='tomato',
				# scale=0.75, sizes.legend=c(10,20,50,100),
				# title.size="Lek size (males)") +
tm_shape(towns[towns$Name %in% c("Roundup","Ryegate","Lavina"),]) +
	tm_bubbles(size=0.2, col="white", border.col="black") +
	tm_text('Name', size=1, fontface=3, auto.placement=F,
			just=c('left','top'), xmod=0.5, ymod=-0.5) +
tm_shape(sgi) +
	tm_borders(col="black", lwd=0.5) +
tm_scale_bar(size=1, position=c("left","top")) +
tm_layout(legend.position=c("right","bottom"),
			legend.frame=F,
			legend.text.size=1,
			legend.title.size=1.25)







# read layers for locator map (inset)
states <- readOGR(dsn=dsn, layer="ne_50m_admin_1_states_provinces_lakes")

land <- readOGR(dsn=dsn, layer="ne_50m_land")

zones <- readOGR(dsn=dsn, layer="SG_MgmtZones_WGS84")
	zones$zone <- c("II","IV","III","VII","I","V","VI")

range <- spTransform( readOGR(dsn=dsn, layer="sagerange"), CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
	range <- range[which(range$STATUS == "c"),]
	

