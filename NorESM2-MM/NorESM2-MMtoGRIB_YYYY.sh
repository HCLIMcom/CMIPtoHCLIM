
# NorESM2-MMtoGRIB.sh
# Converts NetCDF data from NorESM2-MM to model to grib format to be used as forcing for HARMONIE-Climate (HCLIM).
# Since the data is CMORized CMIP6 data, in principle this script should also be easy to adapt to other CMIP6 models.
# Oskar Landgren, oskar.landgren@met.no
# Adjustments by Andreas Dobler, andreas.dobler@met.no
#
# The idea here is to produce grib files of the same format as the ERA-Interim forcing
# used by Harmonie, so that no changes have to be made in the Harmonie system.
#
# Usage: Script takes year to be converted as first parameter input, e.g., ./NorESM2-MM_YYYY.sh 1985
#
# IMPORTANT:
# There are two NorESM-specific errors that I had to deal with. If you are planning to adapt this script to another CMIP6 model please remove them:
# 1. The 6-hourly data (ta, ua, va and hus) from NorESM2-MM has incorrect timestamp, as documented here:
#    https://github.com/NorESMhub/noresm2cmor/issues/109
#    (Short summary: It should be 00/06/12/18h but is 21/03/09/15h.)
#    I have therefore added a "shifttime+3hours" to the cdo commands for these files. If you are adapting this script to another model which does not have this issue, please remove these. 
# 2. siconc has missing values in longitude and latitude variables. Documented at https://github.com/NorESMhub/noresm2cmor/issues/39
#    I have dealt with this by manually appending them from another variable, e.g. tos. (ncks -A -v longitude tos.nc siconc.nc)
#
# Other current limitations of the script:
# - ERA-Interim data is used for the soil and snow fields, so a longer spinup may be required if land areas are of interest.
#   These fields are calculated from ERA-Interim monthly climatology for the years 1990-2005
#   E.g. Mean of all September data 1990-2005 is stored on the 1st of September at 00h, and mean Oct on Oct 1st at 00h. (Perhaps more correctly it should have been on the 15th.)
#
# - The NorESM2-MM model does not have data for Feb 29, while HARMONIE expects it to be there. Currently solved by duplicating data from Feb 28 to 29 during leap years.
#
# - Interpolation to 6-hourly data needed for some variables (siconc and tos).

####################
#Script starts here#
####################
pname=NorESM2-MMtoGRIB_YYYY.sh # for printing status messages to console

yyyy=$1

###PATHS
########
## Working directory (ADJUST if needed!)
wdir=/lustre/storeA/users/oskaral/GCM_LBCs/NorESM2-MM
## Input data directory (ADJUST if needed!)
ddir=$wdir/historical_LBC
## Output directory. Will be created
outdir=$wdir/out/$yyyy

#load modules needed
module load grib_api cdo/1.7.2

cd $wdir

### Define the z-axis, to be stored in zaxis.reverse2.txt
### You can get the values for vct with
### cdo zaxisdes -invertlev ua_6hrLev_NorESM2-MM_historical_r1i1p1f1f1_gn_199001010300-199912312100.nc (from ESGF)
cat <<EOF > zaxis.reverse.txt
zaxistype = hybrid
size      = 48
levels    = 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1
vctsize   = 98
vct       = 1.00000 2.69722 5.17136 8.89455 14.24790 22.07157 33.61283 50.48096 74.79993 109.40055 158.00459 225.44109 317.89560 443.19351 611.11560 833.74390 1125.83411 1505.20764 1993.15833 2614.86255 3399.78418 4382.06250 5600.87012 7100.73096 8931.78223 11149.96973 13817.16797 17001.20898 20775.81836 23967.33789 25527.64648 25671.22461 24609.29688 22640.51172 20147.13477 17477.63477 14859.86426 12414.92578 10201.44238 8241.50293 6534.43213 5066.17871 3815.60693 2758.60254 1870.64636 1128.33936 510.47983 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.01253 0.04887 0.10724 0.18455 0.27461 0.36914 0.46103 0.54623 0.62305 0.69099 0.75016 0.80110 0.84453 0.88127 0.91217 0.93803 0.95958 0.97747 0.99223 1.00000
EOF

# zaxis for NorESM-MM manually created, starting from "cdo zaxisdes -invertlev" from the global file, but selecting only the axis from ta (files contain two axes, one for surface).
# (Also removing metadata 'formula = "p = a*p0 + b*ps"', which seems to be taken into account automatically, but causes error if included.)
cat <<EOF > zaxis.reverse.txt
zaxistype = hybrid
size      = 32
name      = lev
longname  = "hybrid sigma pressure coordinate"
units     = "1"
levels    = 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1
vctsize   = 66
vct       =   225.523952394724 503.169186413288 1015.79474285245 1855.53170740604 2973.46755951211 
            3927.30012536049 4711.44989132881 5624.04990196228 6680.04974722862 8070.14182209969 
            9494.10423636436 11169.321089983 13140.1270627975 15458.6806893349 18186.3352656364 
            17459.799349308 16605.0657629967 15599.5160341263 14416.541159153 13024.8308181763 
            11387.5567913055 9461.38575673103 7534.44507718086 5765.89405536652 4273.46378564835 
            3164.26791250706 2522.12174236774 1919.67375576496 1361.80268600583 853.108894079924 
            397.881818935275 2240 0.0 
            0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0393548272550106 0.0856537595391273 0.140122056007385 
            0.204201176762581 0.279586911201477 0.368274360895157 0.47261056303978 
            0.576988518238068 0.672786951065063 0.753628432750702 0.813710987567902 
            0.848494648933411 0.881127893924713 0.911346435546875 0.938901245594025 
            0.963559806346893 0.985112190246582 1.0
EOF

# Set paths to files:
ta=$ddir/ta_6hrLev_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
ua=$ddir/ua_6hrLev_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
va=$ddir/va_6hrLev_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
hus=$ddir/hus_6hrLev_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc
ps=$ddir/ps_6hrLev_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc

siconc=$ddir/siconc_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc #interpolated from daily values. This includes 01.01. 00:00h
tos=$ddir/tos_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc #interpolated from daily values. This includes 01.01. 00:00h
ts=$ddir/ts_6hr_NorESM2-MM_historical_r1i1p1f1_1990-2009.nc #interpolated from monthly values. This includes 01.01. 00:00h

LANDFRAC=$ddir/sftlf_fx_NorESM2-MM_historical_r1i1p1f1_gn.nc 
ZAXIS=$wdir/zaxis.reverse.txt
orog=$ddir/orog_fx_NorESM2-MM_historical_r1i1p1f1_gn.nc # used as surface geopotential by multiplying by 9.80665 below

# ERAInterim soil and snow variables (for initialisation):
EISURFACECLIM=$ddir/ERAI-surfacefields-global-climatology-1990-2005.v2.NorESM2-MMgrib.grb

# Check if the files are there
echo $pname: Using files:
ls -lhH $ta $ua $va $hus $ps $siconc $tos $ts $LANDFRAC $ZAXIS $orog $EISURFACECLIM

echo $pname: "Year =" $yyyy.
let yyyym1=${yyyy}-1 
#let yyyyp1=${yyyy}+1

mkdir -p $outdir
cd $outdir

#Do preparation (prpare=1)
prpare=1

  if [ $prpare -eq 1 ]; then
  rm -f tmp.grb tmp.nc ta.grb ua.grb va.grb hus.grb ps.grb lnsp.grb siconc.grb tos.grb ts.grb lsm.grb

  echo $pname: "Preparing ta."
  # IMPORTANT!!! READ NOTE ON TOP ABOUT 3-HOUR SHIFT.
  cdo -s -O -setzaxis,$ZAXIS -selyear,$yyyy -shifttime,+3hour -selyear,$yyyym1/$yyyy $ta tmp.nc
  #cdo -s -O -setzaxis,$ZAXIS -selmon,2 -selyear,$yyyy $ta tmp.nc
  cdo -s -O -f grb -t ecmwf -setcode,130 -setzaxis,$ZAXIS -setltype,109 -selvar,ta tmp.nc tmp.grb
  grib_set -s shortName=t tmp.grb ta.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing ua."
  cdo -s -O -setzaxis,$ZAXIS -selyear,$yyyy -shifttime,+3hour -selyear,$yyyym1/$yyyy $ua tmp.nc
  #cdo -s -O -f grb -t ecmwf -setparam,u -setname,u -setcode,131 -delvar,ps tmp.nc tmp.grb # This gives error:
#Warning (cgribexDefGrid) : The CGRIBEX library can not store fields on the used grid!
#Error (cgribexDefGrid) : Unsupported grid type: generic
#HDF5-DIAG: Error detected in HDF5 (1.8.17) thread 139718836472256:
#  #000: H5T.c line 1716 in H5Tclose(): not a datatype
#    major: Invalid arguments to routine
#    minor: Inappropriate type
#Error (cdf_close) : NetCDF: HDF error
# Solution: Use selvar.
  cdo -s -O -f grb -t ecmwf -setparam,u -setname,u -setcode,131 -setzaxis,$ZAXIS -setltype,109 -selvar,ua tmp.nc tmp.grb
  grib_set -s shortName=u tmp.grb ua.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing va."
  cdo -s -O -setzaxis,$ZAXIS -selyear,$yyyy -shifttime,+3hour -selyear,$yyyym1/$yyyy $va tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,v -setname,v -setcode,132 -setzaxis,$ZAXIS -setltype,109 -selvar,va tmp.nc tmp.grb
  grib_set -s shortName=v tmp.grb va.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing hus."
  cdo -s -O -setzaxis,$ZAXIS -selyear,$yyyy -shifttime,+3hour -selyear,$yyyym1/$yyyy $hus tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,q -setname,q -setcode,133 -setzaxis,$ZAXIS -setltype,109 -selvar,hus tmp.nc tmp.grb
  grib_set -s shortName=q tmp.grb hus.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing ps and lnsp."
  cdo -s -O -selyear,$yyyy -shifttime,+3hour -selyear,$yyyym1/$yyyy $ps tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,sp -setname,sp -setcode,134 -setlevel,0 -selvar,ps tmp.nc tmp.ps.grb
  grib_set -s shortName=sp tmp.ps.grb ps.grb
  cdo -s -O -f grb -t ecmwf -ln tmp.nc tmp.lnsp.grb
  grib_set -s shortName=lnsp tmp.lnsp.grb lnsp.grb
  rm -f tmp.nc tmp.ps.grb tmp.lnsp.grb

  echo $pname: "Preparing ts."
  cdo -s -O -f grb -t ecmwf -setparam,skt -setname,skt -setcode,235 -setlevel,0 -selyear,$yyyy -shifttime,+3hour -selyear,$yyyym1/$yyyy $ts tmp.grb
  grib_set -s shortName=skt tmp.grb ts.grb
  rm tmp.grb

  echo $pname: "Preparing sftlf (land fraction)."
  cdo -s -O -f grb -t ecmwf -setcode,172 -divc,100 -setlevel,0 -selvar,sftlf $LANDFRAC tmp.grb
  grib_set -s shortName=lsm tmp.grb lsm.grb
  rm tmp.grb

  echo $pname: "Preparing tos."
  cdo -s -O -f grb -t ecmwf -setcode,34 -setlevel,0 -addc,273.15 -selyear,$yyyy -selvar,tos $tos tmp.grb
  grib_set -s shortName=sst tmp.grb tos.grb
  rm tmp.grb

  echo $pname: "Preparing siconc."
  cdo -s -O -f grb -t ecmwf -setcode,31 -setlevel,0 -divc,100 -selyear,$yyyy -selvar,siconc $siconc tmp.grb
  grib_set -s shortName=ci tmp.grb siconc.grb
  rm tmp.grb

fi #Preparation

# Define selected months.
selmons=1,2,3,4,5,6,7,8,9,10,11,12
selmonseq="01 02 03 04 05 06 07 08 09 10 11 12"

# Since we are starting on Sep 1, for the first year you can select 9-12 manually:
#selmons=9,10,11,12
#selmonseq="09 10 11 12"


echo $pname: "Merging data into one file."
cdo -s -O merge -selmon,$selmons ta.grb -selmon,$selmons ua.grb -selmon,$selmons va.grb -selmon,$selmons hus.grb -selmon,$selmons ps.grb -selmon,$selmons lnsp.grb -selmon,$selmons ts.grb -selmon,$selmons siconc.grb -selmon,$selmons tos.grb fc.grb

echo $pname: "Preparing Z0 by multiplying orog with 9.80665"
cdo -O -s -f grb -t ecmwf -setcode,129 -setlevel,0 -setltype,1 -mulc,9.80665 -selvar,orog $orog tmp.grb
grib_set -s shortName=z tmp.grb z0.grb
rm tmp.grb

curfile=fc.grb

echo $pname: "Splitting into months, days and hours."
cdo -s splitmon $curfile fc$yyyy

for mm in $selmonseq; do
cdo -s splitday fc$yyyy$mm.grb fc$yyyy$mm
rm fc$yyyy$mm.grb

for dd in {01..31}; do echo ====== $yyyy-$mm-$dd ======;
 cdo -s splithour fc$yyyy$mm$dd.grb fc$yyyy$mm$dd\_
 rm fc$yyyy$mm$dd.grb
 for hh in 00 06 12 18; do
  # LSM
  cdo -s -O -settaxis,$yyyy-$mm-$dd,$hh:00:00,1day lsm.grb lsm-temp.grb
  # Z0
  cdo -s -O -f grb -t ecmwf -settime,$hh:00:00 -setdate,$yyyy-$mm-$dd z0.grb temp-z0.grb
  grib_set -s shortName=z temp-z0.grb temp-z0.grb

  #Merge together:
  #Use ERA-Interim climatological snow and soil fields from 1990-2005
  cdo -s -O -f grb settaxis,$yyyy-$mm-$dd,$hh:00:00,1day -selmon,$mm $EISURFACECLIM eraint-surface.grb
  cdo -O merge fc$yyyy$mm$dd\_$hh.grb lsm-temp.grb temp-z0.grb eraint-surface.grb tmp-merged.grb

  #set forecast step to zero
  grib_set -s timeRangeIndicator=0 tmp-merged.grb tmp-merged_tri0.grb
  grib_set -s step=0 tmp-merged_tri0.grb tmp-merged_tri0_s0.grb 

  #(re-)set date and time
  grib_set -s date=$yyyy$mm$dd tmp-merged_tri0_s0.grb tmp-merged_tri0_s0_date.grb 
  grib_set -s time=${hh}00 tmp-merged_tri0_s0_date.grb ma$yyyy$mm$dd$hh.grb

  #clean
  rm -f lsm-temp.grb temp-z0.grb fc$yyyy$mm$dd\_$hh.grb eraint-surface.grb tmp-merged*.grb
  done # hh loop

 # NorESM2-MM does not contain data for Feb 29 (leap years), so Feb 28 is copied
 # check for leapyear
 leapyear=0
 [ $(($yyyy % 4)) -eq 0 ] && ([ $(($yyyy % 100)) -ne 0 ] || [ $(($yyyy % 400)) -eq 0 ]) && leapyear=1

 if [ $leapyear -eq 1 -a $mm -eq "02" -a $dd -eq 29 ] ; then
  echo "Leap year! Copying Feb 28 data to Feb 29.";
  cdo -s -O -f grb -settaxis,$yyyy-02-29,00:00:00,1day ma$yyyy\022800.grb ma$yyyy\022900.grb
  cdo -s -O -f grb -settaxis,$yyyy-02-29,06:00:00,1day ma$yyyy\022806.grb ma$yyyy\022906.grb
  cdo -s -O -f grb -settaxis,$yyyy-02-29,12:00:00,1day ma$yyyy\022812.grb ma$yyyy\022912.grb
  cdo -s -O -f grb -settaxis,$yyyy-02-29,18:00:00,1day ma$yyyy\022818.grb ma$yyyy\022918.grb
 fi

 done # day loop
done # month loop

#Clean up (cleanup=1)
cleanup=1
if [ $cleanup -eq 1 ]; then
  rm -f fc.grb  hus.grb  lnsp.grb  lsm.grb  ps.grb  siconc.grb  ta.grb  tos.grb  ts.grb  ua.grb  va.grb  z0.grb
fi #cleanup

echo ========================
