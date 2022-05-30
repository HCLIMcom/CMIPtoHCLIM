#library(fields)
#library(mapdata)
load("~/geoborders.Rda")

# The structure of the Tegen files is as follows:
# nlat 61
# lat values in order from high to low (90 to -90)
# nlon 120
# lon values from low to high (0 to 360)
# data values (one per line)

# Some documentation is available here:
# https://hirlam.org/trac/wiki/Aerosol :
# "Climatological vertically integrated AOD550 fields of SEA (sea salt), LAND (organic carbon), SOOT (black carbon?), DESERT (dust) aerosols are read from ASCII aero.tegen_GL files and written to monthly climate files by https://svn.hirlam.org/tags/harmonie-40h1.1.rc.1/src/aladin/c9xx/eincli9.F90 . There is no separate SULPHATE in the present aero.tegen files although such is obtainable in http://gacp.giss.nasa.gov/data_sets/transport/ ."

#datasource <- "tegen" # "tegen" or "noresm"
#datasource <- "noresm.ymonmean.Tegengrid"
datasource <- "camsaod"

setwd("~/Dropbox/Jobb och hemma/HCLIM/aerosols/aero_camsaod/")
if (datasource=="camsaod") {filename <- "aero.camsaod.m01_GL"; nheaderlines=4; nlat=61; nlon=120 }
if (datasource=="noresm") {filename <- "NorESM2-MM.m01.txt"; nheaderlines=96; nlat=192; nlon=288 }
#if (datasource=="noresm") {filename <- "test.m07.txt"; nheaderlines=96; nlat=192; nlon=288 }

if (datasource=="noresm.ymonmean.Tegengrid") {filename <- "old/NorESM2-MM.1980-2009.ymonmean.Tegengrid.m07.txt"; nheaderlines=24; nlat=45; nlon=72 }

# read m01
if (datasource=="camsaod") {
  # get nlon and nlat
  tmp <- as.matrix(read.table(file = filename, fill=T))
  if (tmp[1,1] == "nlat") { nlat <- as.numeric(tmp[1,2]); lat <- as.numeric(tmp[2,1:nlat]) } else { stop("Could not read nlat from camsaod file.") }
  if (tmp[3,1] == "nlon") { nlon <- as.numeric(tmp[3,2]); lon <- as.numeric(tmp[4,1:nlon]) } else { stop("Could not read nlon from camsaod file.") }
  rm(tmp)
  tegen.data <- unlist(read.table(file = filename, fill=F, skip=4)) #,dim = c(4*nlat,nlon))
  tegen.data <- matrix(tegen.data,ncol=nlon,byrow = T)
} else {
  tegen.header <- as.matrix(read.table(file = filename, fill=T))[1:nheaderlines,]
  tegen.data <- as.matrix(read.table(file = filename, skip = nheaderlines))
  lat <- c(t(tegen.header))[1:nlat]
  lon <- c(t(tegen.header))[nlat + (1:nlon)]
}
dlat <- diff(lat[1:2])
dlon <- diff(lon[1:2])

# reverse lat order
if (dlat < 0) {
  tegen.data <- tegen.data[dim(tegen.data)[1]:1,]
  lat <- rev(lat)
}

col <- colorRampPalette(colors = rev(c("#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#f5f5f5","#c7eae5","#80cdc1","#35978f","#01665e","#003c30")))(11)

dev.new()
par(mfrow=c(2,2),mar=c(2,2,2,2))

plotdata <- t(tegen.data[(3*nlat+1):(4*nlat),])
image.plot(lon,lat,plotdata,main="Sea salt",xlab="",ylab="",col=col, zlim=c(0,max(plotdata)))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
plotdata <- t(tegen.data[(2*nlat+1):(3*nlat),])
image.plot(lon,lat,plotdata,main="Land (organic carbon)?",xlab="",ylab="",col=col, zlim=c(0,max(plotdata)))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
plotdata <- t(tegen.data[(nlat+1):(2*nlat),])
image.plot(lon,lat,plotdata,main="Soot (black carbon)?",xlab="",ylab="",col=col, zlim=c(0,max(plotdata)))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
plotdata <- t(tegen.data[1:nlat,])
image.plot(lon,lat,plotdata,main="Desert dust",xlab="",ylab="",col=col, zlim=c(0,max(plotdata)))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")


plotlon <- lon
if (any(plotlon<0)) {
  plotlon[plotlon<0] <- plotlon[plotlon<0] + 360
}
if (any(dlat<0)) { plotlat <- rev(lat) } else { plotlat <- lat }

#if (diff(tegen[9,5],tegen[10,1]) > dlat) { stop("Unexpected") }

n_elem <- length(lon) * length(lat)
dev.new()
par(mfrow=c(2,2),mar=c(2,2,2,2))
plotdata <- matrix(c(t(tegen.data))[1:n_elem],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image(plotlon,plotlat,plotdata, main="SEA (sea salt)", xlab="Lon", ylab="Lat")
lines(geoborders)
lines(geoborders$x+360,geoborders$y)
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="blue")

plotdata <- matrix(c(t(tegen.data))[(n_elem + 1):(2*n_elem)],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image(plotlon,plotlat,plotdata, main="LAND (organic carbon)", xlab="Lon", ylab="Lat")
lines(geoborders)
lines(geoborders$x+360,geoborders$y)
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="blue")

plotdata <- matrix(c(t(tegen.data))[(2*n_elem + 1):(3*n_elem)],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image(plotlon,plotlat,plotdata, main="SOOT (black carbon)", xlab="Lon", ylab="Lat")
lines(geoborders)
lines(geoborders$x+360,geoborders$y)
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="blue")

plotdata <- matrix(c(t(tegen.data))[(3*n_elem + 1):(4*n_elem)],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image(plotlon,plotlat,plotdata, main="DESERT (dust)", xlab="Lon", ylab="Lat")
lines(geoborders)
lines(geoborders$x+360,geoborders$y)
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="blue")
#lines(geoborders)

#map('world',proj='azequidistant',xlim=range(lon),ylim=range(lat),add=TRUE,col="black")
#map("worldHires", fill=FALSE, xlim=range(lon), ylim=range(lat),add=TRUE)

