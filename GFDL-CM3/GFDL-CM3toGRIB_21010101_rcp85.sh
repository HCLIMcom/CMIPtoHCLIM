# GFDL-CM3toGRIB.sh
# Converts NetCDF data from the GFDL-CM3 to model to grib format to be used as forcing for HARMONIE-Climate (HCLIM)
# Oskar Landgren, oskar.landgren@met.no
# Adjustments by Andreas Dobler, andreas.dobler@met.no
#
# The idea here is to produce grib files of the same format as the ERA-Interim forcing
# used by Harmonie, so that no changes have to be made in the Harmonie system.
#
# Seperate script for year 2101, producing only 1.1.2101.
# Changed to simply copying 31.12.2100 and adjusting the time-step
#
# Limitations:
# - ERA-Interim data is used for the soil and snow fields, so a longer spinup may be required if land areas are of interest.
#   These fields are calculated from ERA-Interim monthly climatology for the years 1990-2005
#   E.g. Mean of all September data 1990-2005 is stored on the 1st of September at 00h, and mean Oct on Oct 1st at 00h. (Perhaps more correctly it should have been on the 15th.)
#
# - The GFDL-CM3 model does not have data for Feb 29, while HARMONIE expects it to be there. Currently solved by duplicating data from Feb 28 to 29 during leap years.
#
# - Interpolation to 6-hourly data needed for some variables (sic, tos and ts).

####################
#Script starts here#
####################
pname=GFDL-CM3toGRIB_2101.sh # for printing status messages to console

yyyy=2101

###PATHS
########
## Working directory (ADJUST if needed!)
wdir=/lustre/storeA/users/andreasd/GCM_LBCs/GFDL-CM3
## Input data directory (ADJUST if needed!)
ddir=$wdir/rcp85_LBC
## Output directory. Will be created
outdir=$wdir/out/$yyyy

#load modules needed
module load grib_api cdo/1.9.5

mkdir -p $outdir
cd $outdir


#previous year (Needed as 01.01. 00:00H is in the previous input file delivered by ESGF)
let yyyym1=${yyyy}-1 

echo "Copying 2100-12-31 to 2101-01-01.";
cdo -s -O -f grb -settaxis,$yyyy-01-01,00:00:00,1day ../${yyyym1}/ma${yyyym1}123100.grb ma${yyyy}010100.grb
cdo -s -O -f grb -settaxis,$yyyy-01-01,06:00:00,1day ../${yyyym1}/ma${yyyym1}123106.grb ma${yyyy}010106.grb
cdo -s -O -f grb -settaxis,$yyyy-01-01,12:00:00,1day ../${yyyym1}/ma${yyyym1}123112.grb ma${yyyy}010112.grb
cdo -s -O -f grb -settaxis,$yyyy-01-01,18:00:00,1day ../${yyyym1}/ma${yyyym1}123118.grb ma${yyyy}010118.grb 

echo ========================
