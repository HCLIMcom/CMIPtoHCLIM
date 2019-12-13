## Working directory
wdir=/lustre/storeA/users/andreasd/GCM_LBCs/GFDL-CM3
cd $wdir

## Source data directories
sdirh=$wdir/ESGF_input/historical
sdirr=$wdir/ESGF_input/rcp85

## Destination data directories
ddirh=$wdir/historical_LBC
ddirr=$wdir/rcp85_LBC

mkdir -p $ddirh $ddirr

##########################################
### HISTORICAL 1971-2005 & RCP8.5 2006 ###
##########################################

# merge files from 1970-2010; needs the year 2006 (from RCP8.5) for the interpolation to 2005-12-31 18:00
ncrcat $sdirh/sic* $sdirr/sic*20060101* sic_day_GFDL-CM3_historical_r1i1p1_1970-2010.nc
ncrcat $sdirh/tos* $sdirr/tos*20060101* tos_day_GFDL-CM3_historical_r1i1p1_1970-2010.nc
ncrcat $sdirh/ts_* $sdirr/ts_*200601*   ts_Amon_GFDL-CM3_historical_r1i1p1_1970-2010.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,1971/2006 -inttime,1971-01-01,00:00,6h sic_day_GFDL-CM3_historical_r1i1p1_1970-2010.nc sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc
cdo -f nc4 -z zip -O -selyear,1971/2006 -inttime,1971-01-01,00:00,6h tos_day_GFDL-CM3_historical_r1i1p1_1970-2010.nc tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc
cdo -f nc4 -z zip -O -selyear,1971/2006 -inttime,1971-01-01,00:00,6h ts_Amon_GFDL-CM3_historical_r1i1p1_1970-2010.nc ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc

# interpolate to land grid. Needs $sdirh/orog_fx_GFDL-CM3_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirh/orog_fx_GFDL-CM3_historical_r0i0p0.nc sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc
cdo -z zip -O remapbil,$sdirh/orog_fx_GFDL-CM3_historical_r0i0p0.nc tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc
cdo -z zip -O remapbil,$sdirh/orog_fx_GFDL-CM3_historical_r0i0p0.nc ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc  ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc

# split into years
cdo -z zip -O splityear -selyear,1971/2005 sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc $ddirh/sic_6hr_GFDL-CM3_historical_r1i1p1_
cdo -z zip -O splityear -selyear,1971/2005 tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc $ddirh/tos_6hr_GFDL-CM3_historical_r1i1p1_
cdo -z zip -O splityear -selyear,1971/2005 ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc  $ddirh/ts_6hr_GFDL-CM3_historical_r1i1p1_

cdo -z zip -O selyear,2006 sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc $ddirr/sic_6hr_GFDL-CM3_rcp85_r1i1p1_2006.nc
cdo -z zip -O selyear,2006 tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc $ddirr/tos_6hr_GFDL-CM3_rcp85_r1i1p1_2006.nc
cdo -z zip -O selyear,2006 ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc  $ddirr/ts_6hr_GFDL-CM3_rcp85_r1i1p1_2006.nc

# tidy up
rm sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc sic_day_GFDL-CM3_historical_r1i1p1_1970-2010.nc sic_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc 
rm tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc tos_day_GFDL-CM3_historical_r1i1p1_1970-2010.nc tos_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc
rm ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006.nc  ts_Amon_GFDL-CM3_historical_r1i1p1_1970-2010.nc ts_6hr_GFDL-CM3_historical_r1i1p1_1971-2006_tmp.nc

########################
### RCP8.5 2007-2031 ###
########################

# merge files for 2006-2040
ncrcat $sdirr/sic*20[0123]?0101-*nc sic_day_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc
ncrcat $sdirr/tos*20[0123]?0101-*nc tos_day_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc
ncrcat $sdirr/ts_*20[0123]?01-*nc   ts_Amon_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,2007/2031 -inttime,2007-01-01,00:00,6h sic_day_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc
cdo -f nc4 -z zip -O -selyear,2007/2031 -inttime,2007-01-01,00:00,6h tos_day_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc
cdo -f nc4 -z zip -O -selyear,2007/2031 -inttime,2007-01-01,00:00,6h ts_Amon_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc

# interpolate to land grid. Needs $sdirr/orog_fx_GFDL-CM3_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc  ts_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc

# split into years
cdo -z zip -O splityear sic_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc $ddirr/sic_6hr_GFDL-CM3_rcp85_r1i1p1_
cdo -z zip -O splityear tos_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc $ddirr/tos_6hr_GFDL-CM3_rcp85_r1i1p1_
cdo -z zip -O splityear ts_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc  $ddirr/ts_6hr_GFDL-CM3_rcp85_r1i1p1_

# tidy up
rm sic_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc sic_day_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc 
rm tos_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc tos_day_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc
rm ts_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031.nc  ts_Amon_GFDL-CM3_rcp85_r1i1p1_2006-2040.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2007-2031_tmp.nc

########################
### RCP8.5 2032-2066 ###
########################

# merge files for 2031-2070
ncrcat $sdirr/sic*20[3456]?0101-*nc sic_day_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc
ncrcat $sdirr/tos*20[3456]?0101-*nc tos_day_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc
ncrcat $sdirr/ts_*20[3456]?01-*nc   ts_Amon_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,2032/2066 -inttime,2032-01-01,00:00,6h sic_day_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc
cdo -f nc4 -z zip -O -selyear,2032/2066 -inttime,2032-01-01,00:00,6h tos_day_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc
cdo -f nc4 -z zip -O -selyear,2032/2066 -inttime,2032-01-01,00:00,6h ts_Amon_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc

# interpolate to land grid. Needs $sdirr/orog_fx_GFDL-CM3_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc  ts_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc

# split into years
cdo -z zip -O splityear sic_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc $ddirr/sic_6hr_GFDL-CM3_rcp85_r1i1p1_
cdo -z zip -O splityear tos_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc $ddirr/tos_6hr_GFDL-CM3_rcp85_r1i1p1_
cdo -z zip -O splityear ts_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc  $ddirr/ts_6hr_GFDL-CM3_rcp85_r1i1p1_

# tidy up
rm sic_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc sic_day_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc 
rm tos_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc tos_day_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc
rm ts_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066.nc  ts_Amon_GFDL-CM3_rcp85_r1i1p1_2031-2070.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2032-2066_tmp.nc

##############################
### RCP8.5 2067-2101010100 ###
##############################

# duplicate 31. December 2100 daily sea-ice and sea-surface temperature for a (constant) extrapolation to 2101-01-01 00:00
cdo -shifttime,1day -selday,31 -selmon,12 -selyear,2100 $sdirr/sic_day_GFDL-CM3_rcp85_r1i1p1_20960101-21001231.nc sic_day_GFDL-CM3_rcp85_r1i1p1_21010101.nc
cdo -shifttime,1day -selday,31 -selmon,12 -selyear,2100 $sdirr/tos_day_GFDL-CM3_rcp85_r1i1p1_20960101-21001231.nc tos_day_GFDL-CM3_rcp85_r1i1p1_21010101.nc
# duplicate December 2100 monthly skin temperature for a (constant) extrapolation to 2101-01-01 00:00
cdo -shifttime,1month -selmon,12 -selyear,2100 $sdirr/ts_Amon_GFDL-CM3_rcp85_r1i1p1_209601-210012.nc ts_Amon_GFDL-CM3_rcp85_r1i1p1_210101.nc

# merge files for 2066-210101
cdo mergetime $sdirr/sic_*20660101-20701231.nc $sdirr/sic*20[789]?0101-*nc sic_day_GFDL-CM3_rcp85_r1i1p1_21010101.nc sic_day_GFDL-CM3_rcp85_r1i1p1_2066-21010101.nc
cdo mergetime $sdirr/tos_*20660101-20701231.nc $sdirr/tos*20[789]?0101-*nc tos_day_GFDL-CM3_rcp85_r1i1p1_21010101.nc tos_day_GFDL-CM3_rcp85_r1i1p1_2066-21010101.nc
cdo mergetime $sdirr/ts_*206601-207012.nc $sdirr/ts_*20[789]?01-*nc ts_Amon_GFDL-CM3_rcp85_r1i1p1_210101.nc  ts_Amon_GFDL-CM3_rcp85_r1i1p1_2066-210101.nc

# interpolate to 6hourly values
cdo -f nc4 -z zip -O -selyear,2067/2101 -inttime,2067-01-01,00:00,6h sic_day_GFDL-CM3_rcp85_r1i1p1_2066-21010101.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112_tmp.nc
cdo -f nc4 -z zip -O -selyear,2067/2101 -inttime,2067-01-01,00:00,6h tos_day_GFDL-CM3_rcp85_r1i1p1_2066-21010101.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112_tmp.nc
cdo -f nc4 -z zip -O -selyear,2067/2101 -inttime,2067-01-01,00:00,6h ts_Amon_GFDL-CM3_rcp85_r1i1p1_2066-210101.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612_tmp.nc

# interpolate to land grid. Needs $sdirr/orog_fx_GFDL-CM3_historical_r0i0p0.nc (from ESGF)
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112_tmp.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112_tmp.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc
cdo -z zip -O remapbil,$sdirr/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612_tmp.nc  ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612.nc

# split into years
cdo -z zip -O splityear -selyear,2067/2100 sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc $ddirr/sic_6hr_GFDL-CM3_rcp85_r1i1p1_
cdo -z zip -O splityear -selyear,2067/2100 tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc $ddirr/tos_6hr_GFDL-CM3_rcp85_r1i1p1_
cdo -z zip -O splityear -selyear,2067/2100 ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612.nc  $ddirr/ts_6hr_GFDL-CM3_rcp85_r1i1p1_

cdo -z zip -O -seldate,2101-01-01T00:00:00 sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc $ddirr/sic_6hr_GFDL-CM3_rcp85_r1i1p1_2101.nc
cdo -z zip -O -seldate,2101-01-01T00:00:00 tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc $ddirr/tos_6hr_GFDL-CM3_rcp85_r1i1p1_2101.nc
cdo -z zip -O -seldate,2101-01-01T00:00:00 ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612.nc  $ddirr/ts_6hr_GFDL-CM3_rcp85_r1i1p1_2101.nc

# tidy up
rm sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc sic_day_GFDL-CM3_rcp85_r1i1p1_2066-21010101.nc sic_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112_tmp.nc sic_day_GFDL-CM3_rcp85_r1i1p1_21010101.nc
rm tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112.nc tos_day_GFDL-CM3_rcp85_r1i1p1_2066-21010101.nc tos_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101010112_tmp.nc tos_day_GFDL-CM3_rcp85_r1i1p1_21010101.nc
rm ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612.nc  ts_Amon_GFDL-CM3_rcp85_r1i1p1_2066-210101.nc ts_6hr_GFDL-CM3_rcp85_r1i1p1_2067-2101011612_tmp.nc ts_Amon_GFDL-CM3_rcp85_r1i1p1_210101.nc

