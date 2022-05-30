# Routine to produce aerosol files that can be read by HARMONIE.
# This mimics the ASCII format used when setting CAERO="camsaod" in ecf/config_exp.h
# You can produce different files for each year and month (not limited to just monthly climatology files).
# To read then in HCLIM you need to edit scr/Climate:
#   - NDATX, NDATY to correspond to your aerosol data
#   - the path where to find the files
# and the same in scr/Aerosolupd as well.
#
# The MERRA2 NetCDF files needed as input to this routine can be downloaded from
# https://disc.gsfc.nasa.gov/datasets/M2TMNXAER_5.12.4/summary?keywords=MERRA2
# and if necessary interpolated to a desired grid:
# cdo remapcon,grid.camsaod.txt MERRA2.tavgM_2d_aer_Nx.198001-202204.nc MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc

# Variables available from MERRA2:
# 
# BCSCATAU  Black Carbon Scattering AOT [550 nm]
# DUSCATAU  Dust Scattering AOT [550 nm]
# OCSCATAU  Organic Carbon Scattering AOT [550 nm] __ENSEMBLE__
# SSSCATAU  Sea Salt Scattering AOT [550 nm]
# SUSCATAU  SO4 Scattering AOT [550 nm] __ENSEMBLE__
# BCEXTTAU  Black Carbon Extinction AOT [550 nm]
# DUEXTTAU  Dust Extinction AOT [550 nm]
# OCEXTTAU  Organic Carbon Extinction AOT [550 nm] __ENSEMBLE__
# SSEXTTAU  Sea Salt  Extinction AOT [550 nm]
# SUEXTTAU  SO4 Extinction AOT [550 nm] __ENSEMBLE__
# 
# First attempt: use
# SSEXTTAU for the first class "SEA"
# OCEXTTAU+SUSCATAU for the second class "LAND"
# BCEXTTAU for the third class "SOOT"
# DUEXTTAU for the fourth class "DESERT"
# 
# The following are then not used:
# BCSCATAU  Black Carbon Scattering AOT [550 nm]
# DUSCATAU  Dust Scattering AOT [550 nm]
# OCSCATAU  Organic Carbon Scattering AOT [550 nm] __ENSEMBLE__
# SSSCATAU  Sea Salt Scattering AOT [550 nm]
# SUEXTTAU  SO4 Extinction AOT [550 nm] __ENSEMBLE__

library(ncdf4)
library(fields)
library(stringr)
library(gdata)

nctoCAMSAOD = function(od550ss, od550oa, od550bc, od550dust, month=1, outfile.prefix="outCAMSAOD") {

  #od550ss="MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc"
  #od550oa="MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc"
  #od550bc="MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc"
  #od550dust="MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc"
  #TODO: sanity check arguments
  if (!is.numeric(month)) { stop(paste0("Value of argument month ('",month,"') is not numeric.")) }
  if (month > 12) {
    month.str <- str_pad(string = (month-1)%%12 + 1, width = 2, pad = "0", side = "left")
  } else {
    month.str <- str_pad(string = month, width = 2, pad = "0", side = "left")
  }
  # Read lat and lon from od550ss
  nc <- nc_open(od550ss)
  lat <- round(nc$dim$lat$vals, digits = 4) 
  lon <- round(nc$dim$lon$vals, digits = 4) 
  nc_close(nc)
  
  if (length(dim(lat)) > 1) { stop(" The lat variable has more than one dimension. Only regular grids supported so far.") }
  dlat <- diff(lat)
  set_revlat=F
  if (any(dlat>0) & any(dlat<0) ) { stop("Error while reading lat. Values are both increasing and decreasing.")}
  if (all(dlat > 0)) { lat <- rev(lat); set_revlat=T } # go from north to south
  nlat <- length(lat)
  
  if (length(dim(lon)) > 1) { stop(" The lon variable has more than one dimension. Only regular grids supported so far.") }
  dlon <- diff(lon)
  if (any(dlon>0) & any(dlon<0) ) { stop("Error while reading lon. Values are both increasing and decreasing.")}
  nlon <- length(lon)
  
  # generate the first rows in the CAMS AOD file (header containing information about lat and lon values)
  write(x = paste0("nlat ",nlat),file = "header.txt")
  write(x = paste0(lat,sep="",collapse = " "),file="header.txt",append=T)
  write(x = paste0("nlon ",nlon),file = "header.txt",append=T)
  write(x = paste0(lon,sep="",collapse = " "),file="header.txt",append=T)
  
  #write.fwf(x=header,file="header.txt",sep = "",na = "",width = rep(15,ncol), colnames=F, rownames=F, nsmall=4)
  #ncol <- 5
  #NAfill <- rep(NA,ncol-((nlat+nlon)%%ncol))
  #if (length(NAfill) == ncol) { NAfill <- c() } # making sure NAfill is not set if the modulus of (nlat+nlon) is 0 
  #header <- matrix(c(lat,lon,NAfill),ncol=ncol,byrow = T)
  #header <- round(header, digits = 4)
  #header <- cbind( matrix(rep(NA,nrow(header)),nrow = nrow(header)), header)
  #write.table(matrix(header,ncol=5),file="header.txt", sep = " ",row.names = F, col.names = F, na="")
  #write.fwf(x=header,file="header.txt",sep = "",na = "",width = rep(15,ncol), colnames=F, rownames=F, nsmall=4)

  nc <- nc_open(od550ss)
  data <- ncvar_get(nc,"SSEXTTAU",start = c(1,1,month), count = c(-1,-1,1)); nc_close(nc)
  if (set_revlat) { data <- data[,nlat:1] }
  #data1 <- c(data[,,month])
  data1 <- data
  
  nc <- nc_open(od550oa)
  data <- ncvar_get(nc,"OCEXTTAU",start = c(1,1,month), count = c(-1,-1,1)) + ncvar_get(nc,"SUSCATAU",start = c(1,1,month), count = c(-1,-1,1)); nc_close(nc)
  if (set_revlat) { data <- data[,nlat:1] }
  #data2 <- c(data[,,month])
  data2 <- data
  
  nc <- nc_open(od550bc)
  data <- ncvar_get(nc,"BCEXTTAU",start = c(1,1,month), count = c(-1,-1,1)); nc_close(nc)
  if (set_revlat) { data <- data[,nlat:1] }
  #data3 <- c(data[,,month])
  data3 <- data
  
  nc <- nc_open(od550dust)
  data <- ncvar_get(nc,"DUEXTTAU",start = c(1,1,month), count = c(-1,-1,1)); nc_close(nc)
  if (set_revlat) { data <- data[,nlat:1] }
  #data4 <- c(data[,,month])
  data4 <- data
  
  #write.fwf(x = data.frame(format(c(data1,data2,data3,data4),width = 16,scientific = F)),
  #          file="tmp.CAMSAOD.txt", sep = "", na = "",width = 16, colnames=F, rownames=F, justify="left")
  write.table(x = format(c(data1,data2,data3,data4),width = 12,scientific = F),
            file="tmp.CAMSAOD.txt", na = "",quote = F,row.names = F,col.names=F)
  system(command = paste0("cat header.txt tmp.CAMSAOD.txt > ",outfile.prefix,month.str,".txt; rm tmp.CAMSAOD.txt") )
  return(0)
}


# different each year
if (TRUE) {
  #for (mm in 1:120) { # 120
  for (mm in 1:508) {
    yyyy=1980+floor((mm-1)/12)
    print(yyyy)

    #nctoCAMSAOD(od550ss = "MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc",
    #          od550oa = "MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc",
    #          od550bc = "MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc",
    #          od550dust = "MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.camsaodgrid.nc",
    #          month = mm, outfile.prefix = paste0("MERRA2-ASCII/aero.MERRA2.",yyyy))
    MERRA2file = "MERRA2-NetCDF/MERRA2.tavgM_2d_aer_Nx.198001-202204.nc"
    nctoCAMSAOD(od550ss = MERRA2file,
              od550oa = MERRA2file,
              od550bc = MERRA2file,
              od550dust = MERRA2file,
              month = mm, outfile.prefix = paste0("MERRA2-ASCII/aero.MERRA2.",yyyy))
  }
}

if (FALSE) {
for (mm in 1:360) {
  yyyy=1980+floor((mm-1)/12)
  nctoCAMSAOD(od550ss = "NorESM2-MM-Tegengrid/od550ss_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-200912.nc",
            od550oa = "NorESM2-MM-Tegengrid/od550oa_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-200912.nc",
            od550bc = "NorESM2-MM-Tegengrid/od550bc_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-200912.nc",
            od550dust = "NorESM2-MM-Tegengrid/od550dust_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-200912.nc",
            month = mm, outfile.prefix = paste0("NorESM2-MM.Tegengrid.",yyyy))
}
}