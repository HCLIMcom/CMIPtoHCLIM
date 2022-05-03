library(fields)
#library(mapdata)
load("~/geoborders.Rda")
setwd("~/Dropbox/Jobb och hemma/HCLIM/aerosols/aero_tegen/")

# The structure of the Tegen files is as follows:
# lat values, from high to low
# lon values
# data values

# Some documentation is available here:
# https://hirlam.org/trac/wiki/Aerosol :
# "Climatological vertically integrated AOD550 fields of SEA (sea salt), LAND (organic carbon), SOOT (black carbon?), DESERT (dust) aerosols are read from ASCII aero.tegen_GL files and written to monthly climate files by https://svn.hirlam.org/tags/harmonie-40h1.1.rc.1/src/aladin/c9xx/eincli9.F90 . There is no separate SULPHATE in the present aero.tegen files although such is obtainable in http://gacp.giss.nasa.gov/data_sets/transport/ ."

datasource <- "tegen" # "tegen" or "noresm"
#datasource <- "noresm.ymonmean.Tegengrid"

if (datasource=="tegen") {filename <- "old/aero.tegen.m01_GL"; nheaderlines=24; nlat=45; nlon=72 }
if (datasource=="noresm") {filename <- "NorESM2-MM.m01.txt"; nheaderlines=96; nlat=192; nlon=288 }
if (datasource=="noresm") {filename <- "test.m01.txt"; nheaderlines=96; nlat=192; nlon=288 }

if (datasource=="noresm.ymonmean.Tegengrid") {filename <- "old/NorESM2-MM.1980-2009.ymonmean.Tegengrid.m01.txt"; nheaderlines=24; nlat=45; nlon=72 }

# read m01
tegen.header <- as.matrix(read.table(file = filename, fill=T))[1:nheaderlines,]
tegen.data <- as.matrix(read.table(file = filename, skip = nheaderlines))

dlat <- as.numeric(diff(tegen.header[1,1:2]))
lat <- c(t(tegen.header))[1:nlat]
dlon <- diff(c(t(tegen.header))[(nlat+1):(nlat+2)])
lon <- c(t(tegen.header))[nlat + (1:nlon)]

plotlon <- lon
if (any(plotlon<0)) {
  plotlon[plotlon<0] <- plotlon[plotlon<0] + 360
}
if (any(dlat<0)) { plotlat <- rev(lat) } else { plotlat <- lat }

#if (diff(tegen[9,5],tegen[10,1]) > dlat) { stop("Unexpected") }

n_elem <- length(lon) * length(lat)
col <- colorRampPalette(colors = rev(c("#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#f5f5f5","#c7eae5","#80cdc1","#35978f","#01665e","#003c30")))(11)
dev.new()
par(mfrow=c(2,2),mar=c(2,2,2,2))
plotdata <- matrix(c(t(tegen.data))[1:n_elem],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image.plot(plotlon,plotlat,plotdata, main="SEA (sea salt)", xlab="Lon", ylab="Lat", col=col)
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")

plotdata <- matrix(c(t(tegen.data))[(n_elem + 1):(2*n_elem)],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image.plot(plotlon,plotlat,plotdata, main="LAND (organic carbon)", xlab="Lon", ylab="Lat", col=col)
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")

plotdata <- matrix(c(t(tegen.data))[(2*n_elem + 1):(3*n_elem)],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image.plot(plotlon,plotlat,plotdata, main="SOOT (black carbon)", xlab="Lon", ylab="Lat", col=col)
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")

plotdata <- matrix(c(t(tegen.data))[(3*n_elem + 1):(4*n_elem)],ncol=length(lat))
plotdata <- plotdata[,ncol(plotdata):1]
image.plot(plotlon,plotlat,plotdata, main="DESERT (dust)", xlab="Lon", ylab="Lat", col=col)
lines(geoborders,col="#cccccc")
lines(geoborders$x+360,geoborders$y, col="#cccccc")
#map("worldHires", fill=FALSE, add=TRUE,wrap=range(plotlon))
text(x = 180, y = -70, labels=paste(signif(fivenum(plotdata)[2:4],digits = 2),collapse=" "),col="#cccccc")
#lines(geoborders)

#map('world',proj='azequidistant',xlim=range(lon),ylim=range(lat),add=TRUE,col="black")
#map("worldHires", fill=FALSE, xlim=range(lon), ylim=range(lat),add=TRUE)

