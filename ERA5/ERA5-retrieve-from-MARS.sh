#!/bin/bash       
#
#SBATCH --qos=nf
#SBATCH --job-name=marsreqRES
#SBATCH --output=marsreqRES.%j.out
#SBATCH --error=marsreqRES.%j.out
#SBATCH --mail-type=FAIL
##SBATCH --mail-user=youremail@host.com
#SBATCH --time=24:00:00

# Sample script for downloading ERA5 to be used by HCLIM and HARMONIE.
# Modified 2024-12-14 by Oskar Landgren and Hilde Haakenstad, MET Norway.

# Instructions:
# This script can be run on ECMWF Atos to download ERA5 files on GRIB format that can be directly read by HCLIM.
# By default it downloads the files to /ec/res4/scratch/$USER/MARS/ERA5 which is set in the SBATCH command above.
# Make changes below to set the domain and time period you would like to download and then submit the script by running
# sbatch ERA5-retrieve-from-MARS.sh
# Downloading is performed for one date at a time, and downloading for multiple years can take time.
# This script is currently set up to download data for only one year, and it can be wise to modify and submit multiple
# instances of the script for different years to download them in parallel.

# To verify that your GRIB file looks reasonable, you can use CDO to convert to NetCDF. However, because they contain
# a mix of entries in GRIB1 and GRIB2, normal CDO cannot handle it. On ECMWF there is a version of CDO that has been
# compiled with support for eccodes, which can handle this. To use this, add the "--eccodes" flag to your CDO command:
# e.g. cdo --eccodes -f nc copy ma2023010100.grb out.nc
# and then use e.g. ncview and ncdump as usual. 


export PATH=$PATH:.
set -xv

mkdir -p /ec/res4/scratch/$USER/MARS/ERA5
cd /ec/res4/scratch/$USER/MARS/ERA5

y=2023
MONTH='01 02 03 04 05 06 07 08 09 10 11 12'

# Define edges of the domain in degrees (N/W/S/E). Default roughly covers the Nordics.
area=72.0/0.0/50.0/35.0
# If you want to use a rotated domain, specify the position of the South Pole (lat/lon) here:
rotation=-90.0/0.0
# for example, rotation=0.0/0.0 means that the South Pole is at the equator, and longitudes and latitudes given in "area"
# above are then given relative to the North Pole. Default value of -90.0/0.0 means no rotation.

# Define the grid resolution (lon/lat in degrees). Below example is 0.3 and 0.3 degrees:
grid=0.30/0.30


for m in ${MONTH}; do
    #get the number of days for this particular month/year
    days_per_month=$(cal ${m} ${y} | awk 'NF {DAYS = $NF}; END {print DAYS}')

    
    for my_date in $(seq -w 1 ${days_per_month}); do
      my_date=${y}${m}${my_date}

      # To download 3-hourly files uncomment the second line below. Default is 6-hourly.
      TIMES='00:00:00 06:00:00 12:00:00 18:00:00'
      #TIMES='00:00:00 03:00:00 06:00:00 09:00:00 12:00:00 15:00:00 18:00:00 21:00:00'
      
      for my_time in ${TIMES}; do

        case $my_time in
           00:00:00)  cterm='00' ;;
           03:00:00)  cterm='03' ;;
           06:00:00)  cterm='06' ;;
           09:00:00)  cterm='09' ;;
           12:00:00)  cterm='12' ;;
           15:00:00)  cterm='15' ;;
           18:00:00)  cterm='18' ;;
           21:00:00)  cterm='21' ;;
        esac

        echo 'Retrieve ERA5 ', $my_date $my_time

#
# The MARS requests are constructed below, as two separate requests which are run after each other,
# but storing the output in the same target file (name given by date and time).
# The first request is for the surface and subsurface fields,
# while the second downloads the 137 vertical levels.
cat >myrequest.era5.$my_date.$cterm <<EOF

RETRIEVE,
  CLASS = EA,
  DATE = $my_date,
  TIME = $my_time,
  TYPE = AN,
  EXPVER = 1,
  ACCURACY = 16,
  AREA = $area,
  GRID = $grid,
  LEVTYPE = SFC,
  PARAM = 139/141/170/172/183/198/235/236/31/32/33/34/39/40/41/42/43,
  ROTATION = $rotation,
  STEP = 000,
  STREAM = OPER,
  TARGET = ma${my_date}${cterm}.grb

RETRIEVE,
  CLASS = EA,
  DATE = $my_date,
  TIME = $my_time,
  TYPE = AN,
  EXPVER = 1,
  ACCURACY = 16,
  AREA = $area,
  GRID = $grid,
  LEVELIST = 1/to/137,
  LEVTYPE = ML,
  NUMBER = -1,
  LEVTYPE = ML,
  PARAM = Q/T/U/V/LNSP/Z,
  ROTATION = $rotation,
  STEP = 000,
  STREAM = OPER,
  TARGET = ma${my_date}${cterm}.grb

EOF


# MARS request

mars myrequest.era5.$my_date.$cterm


done           # times
done           # dd

rm -f myreque*

done           # mm

exit





