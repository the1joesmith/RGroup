#R Group
#10/12/2017
#Kayla Ruth and Stephanie Berry 

### Formatting data basics for analysis ####
#load your libraries 

library(tidyr)
library(plyr)
library(dplyr)

#Read in your data file 
songbirds <- read.csv("R_group_formatting.csv")

#Remove unnecessary columns for this analysis
songbirds <- dplyr::select(songbirds,"Plot","year","prim_obsv","sec_obsv","indiv")

#let's look at how many years of data we have 
unique(songbirds$year)
unique(songbirds$Plot)
unique(songbirds$BBL)

#code BBL to species ID (spid) number 
songbirds$spid <- 0 #empty column 
songbirds$spid <- ifelse(songbirds$BBL=="VESP", 1,
                         ifelse(songbirds$BBL=="HOLA",2, 
                                ifelse(songbirds$BBL=="WEME",3, 
                                       ifelse(songbirds$BBL=="MCLO",4, 
                                              ifelse(songbirds$BBL=="CCLO", 5, 
                                                     ifelse(songbirds$BBL=="BRSP", 6,
                                                            NA))))))
#get rid of BBL column
songbirds$BBL <-NULL

# code year 
# 1 = 2013, 2=2014
songbirds$year <-ifelse(songbirds$year == 2013, 1, songbirds$year)
songbirds$year <-ifelse(songbirds$year == 2014, 2, songbirds$year)

#condense duplicate observations with same year, spid, plot number, and observer info
songbirds2 <-ddply(songbirds, .(year, spid, Plot, prim_obsv, sec_obsv), numcolwise(sum))


#new column for which observer made detection
songbirds2$detected.by <- 0
songbirds2$detected.by[is.na(songbirds2$prim_obsv)] <- 2
songbirds2$detected.by[!is.na(songbirds2$prim_obsv) & songbirds2$prim_obsv != 0] <- 1


#get rid of unneeded observer columns
songbirds3 <- dplyr::select(songbirds2,"Plot","year","indiv","spid", "detected.by")

