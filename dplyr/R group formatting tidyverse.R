#R Group
#10/12/2017
#Kayla Ruth and Stephanie Berry 

### Formatting data basics for analysis ####
#load your libraries 

library(tidyr)
library(plyr)
library(dplyr)

#Read in your data file 
songbirds <- read.csv("R_group_formatting.csv", as.is = T) %>%
	select(Plot, year, BBL, prim_obsv, sec_obsv, indiv)

#  Get to know data
#let's look at how many years of data we have 
unique(songbirds$year)
unique(songbirds$Plot)
unique(songbirds$BBL)

#Remove unnecessary columns for this analysis
songbirds <- dplyr::select(songbirds,"Plot","year","BBL", "prim_obsv","sec_obsv","indiv")

#let's look at how many years of data we have 
unique(songbirds$year)
unique(songbirds$Plot)
unique(songbirds$BBL)

#Initial way to code for species (spid)
songbirds$spid <- 0 #empty column 
songbirds$spid <- ifelse(songbirds$BBL=="VESP", 1,
                         ifelse(songbirds$BBL=="HOLA",2, 
                                ifelse(songbirds$BBL=="WEME",3, 
                                       ifelse(songbirds$BBL=="MCLO",4, 
                                              ifelse(songbirds$BBL=="CCLO", 5, 
                                                     ifelse(songbirds$BBL=="BRSP", 6,
                                                            NA))))))
#Josh's recommended way to code for spid -- more efficient when you have a 
#large number of species to code for
#code BBL to species ID (spid) number 
lookup <- data.frame(
  species_ch = distinct(songbirds, BBL),
  stringsAsFactors = F
) %>%
  mutate(
    species_num = 1:n()
  )

songbirds2 <- songbirds %>%
  mutate(
    spid = lookup$species_num[match(BBL, lookup$BBL)]
  )


#get rid of BBL column
songbirds$BBL <-NULL

# code year 
# 1 = 2013, 2=2014
songbirds$year <-ifelse(songbirds$year == 2013, 1, songbirds$year)
songbirds$year <-ifelse(songbirds$year == 2014, 2, songbirds$year)

#Josh's recommended way to code for spid -- more efficient when you have many years of data
sngbrds <- songbirds %>%
	mutate(
		spid = lookup$species_num[match(BBL, lookup$BBL)],
		year = year - min(year, na.rm = T) + 1
	) %>%
	group_by(year, BBL, spid, Plot, prim_obsv, sec_obsv) %>%
	summarise(
		n = sum(indiv, na.rm = T)
	) %>%
	ungroup() %>%
	mutate(
		
		obs_num = as.numeric(!is.na(prim_obsv)) + as.numeric(!is.na(sec_obsv)),
		obs_by = (as.numeric(!is.na(prim_obsv)) < as.numeric(!is.na(sec_obsv))) + 1
	)
		

#condense duplicate observations with same year, spid, plot number, and observer info
songbirds2 <-ddply(songbirds, .(year, spid, Plot, prim_obsv, sec_obsv), numcolwise(sum))


#new column for which observer made detection (also included in Josh's recommended
#code above where years are recoded)
songbirds2$detected.by <- 0
songbirds2$detected.by[is.na(songbirds2$prim_obsv)] <- 2
songbirds2$detected.by[!is.na(songbirds2$prim_obsv) & songbirds2$prim_obsv != 0] <- 1


#get rid of unneeded observer columns
songbirds3 <- dplyr::select(songbirds2,"Plot","year","indiv","spid", "detected.by")


#######################################################################



