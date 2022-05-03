# Available from NorESM2-MM:
# od550aer    AOD from the ambient aerosols (i.e., includes aerosol water).  Does not include AOD from stratospheric aerosols if these are prescribed but includes other possible background aerosol types.
# od550aerh2o atmosphere_optical_thickness_due_to_water_in_ambient_aerosol_particles
# od550bc     atmosphere_optical_thickness_due_to_black_carbon_ambient_aerosol
# od550csaer  AOD from the ambient aerosols in clear skies if od550aer is for all-sky (i.e., includes aerosol water).  Does not include AOD from stratospheric aerosols if these are prescribed but includes other possible background aerosol types. 
# od550dust   atmosphere_optical_thickness_due_to_dust_ambient_aerosol_particles
# od550lt1aer od550 due to particles with wet diameter less than 1 um  (ambient here means wetted). When models do not include explicit size information, it can be assumed that all anthropogenic aerosols and natural secondary aerosols have diameter less than 1 um.
# od550oa   atmosphere_optical_thickness_due_to_particulate_organic_matter_ambient_aerosol_particles
# od550so4  atmosphere_optical_thickness_due_to_sulfate_ambient_aerosol_particles
# od550ss   atmosphere_optical_thickness_due_to_sea_salt_ambient_aerosol_particles

# First attempt: use
# od550ss for the first class "SEA"
# od550oa for the second class "LAND"
# od550bc for the third class "SOOT"
# od550dust for the fourth class "DESERT"

# The following are then not used:
# od550aer
# od550aerh20
# od550csaer
# od550lt1aer (Should we consider adding this to the SOOT class?)
# od550so4


# Download data from Nird:
# cd ~/HCLIM/aerosols/aero_tegen/NorESM2-MM
# scp "nird:/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-MM/historical/r1i1p1f1/AERmon/od550*/gn/latest/od550*198001-198912.nc" .

library(ncdf4)
library(fields)

# Read od550ss
set_revlat=F
nc <- nc_open("NorESM2-MM/od550ss_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-198912.nc")
lat <- nc$dim$lat$vals
lon <- nc$dim$lon$vals
nc_close(nc)

if (length(dim(lat)) > 1) { stop(" The lat variable has more than one dimension. Only regular grids supported so far.") }
dlat <- diff(lat)
if (any(dlat>0) & any(dlat<0) ) { stop("Error while reading lat. Values are both increasing and decreasing.")}
if (all(dlat > 0)) { lat <- rev(lat); set_revlat=T } # go from north to south
nlat <- length(lat)

if (length(dim(lon)) > 1) { stop(" The lon variable has more than one dimension. Only regular grids supported so far.") }
dlon <- diff(lon)
if (any(dlon>0) & any(dlon<0) ) { stop("Error while reading lon. Values are both increasing and decreasing.")}
nlon <- length(lon)

# generate the first rows in Tegen file (lat and lon values)
if ((nlat + nlon) %% 5 != 0) { stop("nlon + nlat not divisible by 5 (the number of columns). Implement a workaround.") }
header <- matrix(c(lat,lon),ncol=5,byrow = T)
write.table(matrix(header,ncol=5),file="header.txt", sep = " ",row.names = F, col.names = F)

# TODO: generalise by using names(nc$var) to identify the variable name
# make function that takes 4 files as argument

nc <- nc_open("NorESM2-MM/od550ss_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-198912.nc")
data <- ncvar_get(nc,"od550ss"); nc_close(nc)
if (set_revlat) { data <- data[,nlat:1,] }
data1 <- c(data[,,1])

nc <- nc_open("NorESM2-MM/od550oa_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-198912.nc")
data <- ncvar_get(nc,"od550oa"); nc_close(nc)
if (set_revlat) { data <- data[,nlat:1,] }
data2 <- c(data[,,1])

nc <- nc_open("NorESM2-MM/od550bc_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-198912.nc")
data <- ncvar_get(nc,"od550bc"); nc_close(nc)
if (set_revlat) { data <- data[,nlat:1,] }
data3 <- c(data[,,1])

nc <- nc_open("NorESM2-MM/od550dust_AERmon_NorESM2-MM_historical_r1i1p1f1_gn_198001-198912.nc")
data <- ncvar_get(nc,"od550dust"); nc_close(nc)
if (set_revlat) { data <- data[,nlat:1,] }
data4 <- c(data[,,1])

write.table(file="tmp.NorESM2-MM.m01.txt",x = matrix(c(data1,data2,data3,data4),ncol=12,byrow = T), row.names=F, col.names=F)

system(command = "cat header.txt tmp.NorESM2-MM.m01.txt > NorESM2-MM.m01.txt; rm tmp.NorESM2-MM.m01.txt")
