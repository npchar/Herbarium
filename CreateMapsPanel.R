#!/usr/bin/env Rscript

library("optparse")
library(ggmap)
library(magick)

option_list = list(
  make_option(c("-s", "--sample"), type="character", default=NULL,
              help="Name of the sample, used as basename for the resulting maps files"),
  make_option(c("-a", "--latitude"), type="double", default=NULL,
              help="Latitude as Decimal Degree"),
  make_option(c("-o", "--longitude"), type="double", default=NULL,
              help="Longitude as Decimal Degree"),
  make_option(c("-v", "--vertical"), action="store_true", default=FALSE,
        help="Create a map pannel vertically [default is horizontal]")
              );

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$sampleName) & is.null(opt$longitude) & is.null(opt$latitude)){
  print_help(opt_parser)
  stop("Three arguments must be supplied (sample name, longitude and latitude).n", call.=FALSE)
}

LonLat = c(as.numeric(as.character(opt$longitude)), as.numeric(as.character(opt$latitude)))


##===================================================
## FUNCTION:
##===================================================

# Creating box centered around the sample lat and long
MakeBBox = function(lo, la, zoom){
	left= min(lo)-zoom #LowerLeftLon 
	bottom = min(la)-zoom #LowerLedtLat
	right = max(lo)+zoom #UpperRightLon 
	top = max(la)+zoom #UpperRightLat
	BBox = as.double(c(left, bottom, right, top))
	return(BBox)
}




# Perfect Size Zoom for the smallest map
if(opt$vertical == TRUE){
	m1 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 0.002), zoom=17, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) + theme(axis.text.y=element_text(size=12, angle=90), axis.text.x=element_text(size=12), axis.title=element_text(size=12,face="bold"), panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
} else {
	m1 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 0.002), zoom=17, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) + theme(axis.text=element_text(size=12), axis.title=element_text(size=12,face="bold"), axis.title.y = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
}
ggsave(paste(opt$sample,"_1",".png", sep=""), height = 6, dpi = 300)

# Perfect Size Zoom for an intermediate map (city)
if(opt$vertical == TRUE){
	m2 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 0.02), zoom=14, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) +theme(axis.text.y=element_text(size=12, angle=90), axis.text.x=element_text(size=12), axis.title=element_text(size=12,face="bold"), axis.title.x = element_blank(),panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
} else {
	m2 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 0.02), zoom=14, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) +theme(axis.text=element_text(size=12), axis.title=element_text(size=12,face="bold"), axis.title.y = element_blank(),panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
}
ggsave(paste(opt$sample,"_2",".png", sep=""), height = 6, dpi = 300)

# Perfect Size Zoom for an intermediate map (regional)
if(opt$vertical == TRUE){
m3 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 1), zoom=8, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) + theme(axis.text.y=element_text(size=12, angle=90), axis.text.x=element_text(size=12),axis.title=element_text(size=12,face="bold"), axis.title.x = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))

} else {
m3 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 1), zoom=8, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) + theme(axis.text=element_text(size=12), axis.title=element_text(size=12,face="bold"), axis.title.y = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
}
ggsave(paste(opt$sample,"_3",".png", sep=""), height = 6, dpi = 300)

# Perfect Size Zoom for Highest level
if(opt$vertical == TRUE){
	m4 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 10), zoom=5, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) + theme(axis.text.y=element_text(size=12, angle=90), axis.text.x=element_text(size=12), axis.title=element_text(size=12,face="bold"), axis.title.x = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
} else {
	m4 = get_stamenmap(MakeBBox(LonLat[1], LonLat[2], 10), zoom=5, maptype="toner") %>% ggmap() + geom_point(x=LonLat[1], y=LonLat[2], color='red',size=3) + theme(axis.text=element_text(size=12), axis.title=element_text(size=12,face="bold"), panel.border = element_rect(colour = "black", fill=NA, size=3), plot.margin = unit(c(0,0,0,0), "lines"))
}
ggsave(paste(opt$sample,"_4",".png", sep=""), height = 6, dpi = 300)

#Load images, resize and create a panel

map1 = image_read(paste(opt$sample,"_1",".png", sep=""))
map2 = image_read(paste(opt$sample,"_2",".png", sep=""))
map3 = image_read(paste(opt$sample,"_3",".png", sep=""))
map4 = image_read(paste(opt$sample,"_4",".png", sep=""))
if(opt$vertical == TRUE){
	map1_c = image_crop(map1, "1400x1800+350")
	map2_c = image_crop(map2, "1400x1800+350")
	map3_c = image_crop(map3, "1400x1800+350")
	map4_c = image_crop(map4, "1400x1800+350")
	image_write(image_append(c(map4_c, map3_c, map2_c, map1_c), stack=TRUE), paste(opt$sample,"_panel",".png", sep=""))
} else {
	map1_c = image_crop(map1, "1400x1800+350")
	map2_c = image_crop(map2, "1400x1800+350")
	map3_c = image_crop(map3, "1400x1800+350")
	map4_c = image_crop(map4, "1400x1800+350")
	image_write(image_append(c(map4_c, map3_c, map2_c, map1_c)), paste(opt$sample,"_panel",".png", sep=""))
}


