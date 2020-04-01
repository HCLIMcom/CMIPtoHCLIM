## Working directory
wdir=/lustre/storeA/users/oskaral/GCM_LBCs/NorESM2-MM
cd $wdir

# if at lustre, cdo version 1.9.5 seems to crash frequently (possible OpenMP-related bug?)
module load cdo/1.7.2

## Source data directories
sdirh=$wdir/ESGF_input/historical
sdirr=$wdir/ESGF_input/ssp585

## Destination data directories
ddirh=$wdir/historical_LBC
ddirr=$wdir/ssp585_LBC

mkdir -p $ddirh $ddirr

############################
### HISTORICAL 1990-2009 ###
############################

# merge files from 1980-2009
ncrcat $sdirh/siconc* siconc_day_NorESM2-MM_historical_r1i1p1f1_1980-2009.nc
ncrcat $sdirh/tos* tos_day_NorESM2-MM_historical_r1i1p1f1_1980-2009.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,1990/2009 -inttime,1980-01-01,12:00,6h siconc_day_NorESM2-MM_historical_r1i1p1f1_1980-2009.nc siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc
cdo -f nc4 -z zip -O -selyear,1990/2009 -inttime,1980-01-01,12:00,6h tos_day_NorESM2-MM_historical_r1i1p1f1_1980-2009.nc tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc

# interpolate to land grid. Needs $sdirh/orog_fx_NorESM2-MM_historical_r1i1p1f1.nc (from ESGF)
#cdo -z zip -O remapbil,$sdirh/orog_fx_NorESM2-MM_historical_r1i1p1f1_gn.nc siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc $ddirh/siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
#cdo -z zip -O remapbil,$sdirh/orog_fx_NorESM2-MM_historical_r1i1p1f1_gn.nc tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc $ddirh/tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
cdo -z zip -O remapnn,$sdirh/orog_fx_NorESM2-MM_historical_r1i1p1f1_gn.nc siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc $ddirh/siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
cdo -z zip -O remapnn,$sdirh/orog_fx_NorESM2-MM_historical_r1i1p1f1_gn.nc tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc $ddirh/tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc

# tidy up
rm siconc_day_NorESM2-MM_historical_r1i1p1f1_1980-2009.nc siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc 
rm tos_day_NorESM2-MM_historical_r1i1p1f1_1980-2009.nc tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009_tmp.nc

# OL 2020-02-06: Done until here. SSP585 data not yet available at Nird.

########################
### SSP585 2010-2100 ###
########################

# merge files for 2006-2040
ncrcat $sdirr/sic*20[0123]?0101-*nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc
ncrcat $sdirr/tos*20[0123]?0101-*nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc
ncrcat $sdirr/ts_*20[0123]?01-*nc   ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,2007/2031 -inttime,2007-01-01,00:00,6h siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc
cdo -f nc4 -z zip -O -selyear,2007/2031 -inttime,2007-01-01,00:00,6h tos_day_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc
cdo -f nc4 -z zip -O -selyear,2007/2031 -inttime,2007-01-01,00:00,6h ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc

# interpolate to land grid. Needs $sdirr/orog_fx_NorESM2-MM_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc  ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc

# split into years
cdo -z zip -O splityear siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc $ddirr/siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_
cdo -z zip -O splityear tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc $ddirr/tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_
cdo -z zip -O splityear ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc  $ddirr/ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_

# tidy up
rm siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc 
rm tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc
rm ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031.nc  ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2006-2040.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2007-2031_tmp.nc

########################
### RCP8.5 2032-2066 ###
########################

# merge files for 2031-2070
ncrcat $sdirr/sic*20[3456]?0101-*nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc
ncrcat $sdirr/tos*20[3456]?0101-*nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc
ncrcat $sdirr/ts_*20[3456]?01-*nc   ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,2032/2066 -inttime,2032-01-01,00:00,6h siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc
cdo -f nc4 -z zip -O -selyear,2032/2066 -inttime,2032-01-01,00:00,6h tos_day_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc
cdo -f nc4 -z zip -O -selyear,2032/2066 -inttime,2032-01-01,00:00,6h ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc

# interpolate to land grid. Needs $sdirr/orog_fx_NorESM2-MM_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc  ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc

# split into years
cdo -z zip -O splityear siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc $ddirr/siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_
cdo -z zip -O splityear tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc $ddirr/tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_
cdo -z zip -O splityear ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc  $ddirr/ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_

# tidy up
rm siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc 
rm tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc
rm ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066.nc  ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2031-2070.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2032-2066_tmp.nc

##############################
### RCP8.5 2067-2101010100 ###
##############################

# duplicate 31. December 2100 daily sea-ice and sea-surface temperature for a (constant) extrapolation to 2101-01-01 00:00
cdo -shifttime,1day -selday,31 -selmon,12 -selyear,2100 $sdirr/siconc_day_NorESM2-MM_rcp85_r1i1p1f1_20960101-21001231.nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_21010101.nc
cdo -shifttime,1day -selday,31 -selmon,12 -selyear,2100 $sdirr/tos_day_NorESM2-MM_rcp85_r1i1p1f1_20960101-21001231.nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_21010101.nc
# duplicate December 2100 monthly skin temperature for a (constant) extrapolation to 2101-01-01 00:00
cdo -shifttime,1month -selmon,12 -selyear,2100 $sdirr/ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_209601-210012.nc ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_210101.nc

# merge files for 2066-210101
cdo mergetime $sdirr/siconc_*20660101-20701231.nc $sdirr/sic*20[789]?0101-*nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_21010101.nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2066-21010101.nc
cdo mergetime $sdirr/tos_*20660101-20701231.nc $sdirr/tos*20[789]?0101-*nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_21010101.nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_2066-21010101.nc
cdo mergetime $sdirr/ts_*206601-207012.nc $sdirr/ts_*20[789]?01-*nc ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_210101.nc  ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2066-210101.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,2067/2101 -inttime,2067-01-01,00:00,6h siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2066-21010101.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112_tmp.nc
cdo -f nc4 -z zip -O -selyear,2067/2101 -inttime,2067-01-01,00:00,6h tos_day_NorESM2-MM_rcp85_r1i1p1f1_2066-21010101.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112_tmp.nc
cdo -f nc4 -z zip -O -selyear,2067/2101 -inttime,2067-01-01,00:00,6h ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2066-210101.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612_tmp.nc

# interpolate to land grid. Needs $sdirr/orog_fx_NorESM2-MM_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112_tmp.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112_tmp.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_NorESM2-MM_rcp85_r0i0p0.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612_tmp.nc  ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612.nc

# split into years
cdo -z zip -O splityear -selyear,2067/2100 siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc $ddirr/siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_
cdo -z zip -O splityear -selyear,2067/2100 tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc $ddirr/tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_
cdo -z zip -O splityear -selyear,2067/2100 ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612.nc  $ddirr/ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_

cdo -z zip -O -seldate,2101-01-01T00:00:00 siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc $ddirr/siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2101.nc
cdo -z zip -O -seldate,2101-01-01T00:00:00 tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc $ddirr/tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2101.nc
cdo -z zip -O -seldate,2101-01-01T00:00:00 ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612.nc  $ddirr/ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2101.nc

# tidy up
rm siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_2066-21010101.nc siconc_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112_tmp.nc siconc_day_NorESM2-MM_rcp85_r1i1p1f1_21010101.nc
rm tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112.nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_2066-21010101.nc tos_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101010112_tmp.nc tos_day_NorESM2-MM_rcp85_r1i1p1f1_21010101.nc
rm ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612.nc  ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_2066-210101.nc ts_6hr_NorESM2-MM_rcp85_r1i1p1f1_2067-2101011612_tmp.nc ts_Amon_NorESM2-MM_rcp85_r1i1p1f1_210101.nc

