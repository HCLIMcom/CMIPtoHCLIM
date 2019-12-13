# GFDL-CM3toGRIB.sh
# Converts NetCDF data from the GFDL-CM3 to model to grib format to be used as forcing for HARMONIE-Climate (HCLIM)
# Oskar Landgren, oskar.landgren@met.no
# Adjustments by Andreas Dobler, andreas.dobler@met.no
#
# The idea here is to produce grib files of the same format as the ERA-Interim forcing
# used by Harmonie, so that no changes have to be made in the Harmonie system.
#
# Seperate script for year 2006 using historical and rcp files, since 1.1.2006 00:00 is in *_6hrLev_GFDL-CM3_historical_r1i1p1_2005010100-2005123123.nc
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
pname=GFDL-CM3toGRIB_2006.sh # for printing status messages to console

yyyy=2006

###PATHS
########
## Working directory (ADJUST if needed!)
wdir=/lustre/storeA/users/andreasd/GCM_LBCs/GFDL-CM3
## Input data directory (ADJUST if needed!)
ddir=$wdir/rcp85_LBC
ddirh=$wdir/historical_LBC
## Output directory. Will be created
outdir=$wdir/out/$yyyy

#load modules needed
module load grib_api cdo/1.9.5

cd $wdir

### Define the z-axis, to be stored in zaxis.reverse2.txt
### You can get the values for vct with
### cdo zaxisdes -invertlev ua_6hrLev_GFDL-CM3_historical_r1i1p1_1970010100-1970123123.nc (from ESGF)
cat <<EOF > zaxis.reverse.txt
zaxistype = hybrid
size      = 48
levels    = 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1
vctsize   = 98
vct       = 1.00000 2.69722 5.17136 8.89455 14.24790 22.07157 33.61283 50.48096 74.79993 109.40055 158.00459 225.44109 317.89560 443.19351 611.11560 833.74390 1125.83411 1505.20764 1993.15833 2614.86255 3399.78418 4382.06250 5600.87012 7100.73096 8931.78223 11149.96973 13817.16797 17001.20898 20775.81836 23967.33789 25527.64648 25671.22461 24609.29688 22640.51172 20147.13477 17477.63477 14859.86426 12414.92578 10201.44238 8241.50293 6534.43213 5066.17871 3815.60693 2758.60254 1870.64636 1128.33936 510.47983 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.00000 0.01253 0.04887 0.10724 0.18455 0.27461 0.36914 0.46103 0.54623 0.62305 0.69099 0.75016 0.80110 0.84453 0.88127 0.91217 0.93803 0.95958 0.97747 0.99223 1.00000
EOF

#previous year (Needed as 01.01. 00:00H is in the previous input file delivered by ESGF)
let yyyym1=${yyyy}-1 

# Set paths to files:
ta=$ddir/ta_6hrLev_GFDL-CM3_rcp85_r1i1p1_${yyyy}010100-${yyyy}123123.nc
ua=$ddir/ua_6hrLev_GFDL-CM3_rcp85_r1i1p1_${yyyy}010100-${yyyy}123123.nc
va=$ddir/va_6hrLev_GFDL-CM3_rcp85_r1i1p1_${yyyy}010100-${yyyy}123123.nc
hus=$ddir/hus_6hrLev_GFDL-CM3_rcp85_r1i1p1_${yyyy}010100-${yyyy}123123.nc
ps=$ddir/ps_6hrLev_GFDL-CM3_rcp85_r1i1p1_${yyyy}010100-${yyyy}123123.nc

tap=$ddirh/ta_6hrLev_GFDL-CM3_historical_r1i1p1_${yyyym1}010100-${yyyym1}123123.nc
uap=$ddirh/ua_6hrLev_GFDL-CM3_historical_r1i1p1_${yyyym1}010100-${yyyym1}123123.nc
vap=$ddirh/va_6hrLev_GFDL-CM3_historical_r1i1p1_${yyyym1}010100-${yyyym1}123123.nc
husp=$ddirh/hus_6hrLev_GFDL-CM3_historical_r1i1p1_${yyyym1}010100-${yyyym1}123123.nc
psp=$ddirh/ps_6hrLev_GFDL-CM3_historical_r1i1p1_${yyyym1}010100-${yyyym1}123123.nc

sic=$ddir/sic_6hr_GFDL-CM3_rcp85_r1i1p1_${yyyy}.nc #interpolated from daily values. This includes 01.01. 00:00h
tos=$ddir/tos_6hr_GFDL-CM3_rcp85_r1i1p1_${yyyy}.nc #interpolated from daily values. This includes 01.01. 00:00h
ts=$ddir/ts_6hr_GFDL-CM3_rcp85_r1i1p1_${yyyy}.nc #interpolated from monthly values. This includes 01.01. 00:00h

LANDFRAC=$ddir/sftlf_fx_GFDL-CM3_rcp85_r0i0p0.nc 
ZAXIS=$wdir/zaxis.reverse.txt
orog=$ddir/orog_fx_GFDL-CM3_rcp85_r0i0p0.nc # used as surface geopotential by multiplying by 9.80665 below

# ERAInterim soil and snow variables (for initialisation):
EISURFACECLIM=$ddir/ERAI-surfacefields-global-climatology-1990-2005.GFDLgrid.grb

# Check if the files are there
echo $pname: Using files:
ls -lhH $ta $ua $va $hus $ps $tap $uap $vap $husp $psp $sic $tos $ts $LANDFRAC $ZAXIS $orog $EISURFACECLIM

echo $pname: "Year =" $yyyy.

mkdir -p $outdir
cd $outdir

#Do preparation (prpare=1)
prpare=1

  if [ $prpare -eq 1 ]; then
  rm -f tmp.grb tmp.nc ta.grb ua.grb va.grb hus.grb ps.grb lnsp.grb sic.grb tos.grb ts.grb lsm.grb

  echo $pname: "Preparing ta."
  cdo -s -O selyear,$yyyy -mergetime -selyear,$yyyy $tap $ta tmp.nc
  cdo -s -O -f grb -t ecmwf -setzaxis,$ZAXIS -setcode,130 -delvar,ps tmp.nc tmp.grb
  grib_set -s shortName=t tmp.grb ta.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing ua."
  cdo -s -O selyear,$yyyy -mergetime -selyear,$yyyy $uap $ua tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,u -setname,u -setzaxis,$ZAXIS -setcode,131 -delvar,ps tmp.nc tmp.grb
  grib_set -s shortName=u tmp.grb ua.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing va."
  cdo -s -O selyear,$yyyy -mergetime -selyear,$yyyy $vap $va tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,v -setname,v -setzaxis,$ZAXIS -setcode,132 -delvar,ps tmp.nc tmp.grb
  grib_set -s shortName=v tmp.grb va.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing hus."
  cdo -s -O selyear,$yyyy -mergetime -selyear,$yyyy $husp $hus tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,q -setname,q -setzaxis,$ZAXIS -setcode,133 -delvar,ps tmp.nc tmp.grb
  grib_set -s shortName=q tmp.grb hus.grb
  rm -f tmp.grb tmp.nc

  echo $pname: "Preparing ps and lnsp."
  cdo -s -O selyear,$yyyy -mergetime -selyear,$yyyy $psp $ps tmp.nc
  cdo -s -O -f grb -t ecmwf -setparam,sp -setname,sp -setcode,134 -selvar,ps tmp.nc tmp.ps.grb
  grib_set -s shortName=sp tmp.ps.grb ps.grb
  cdo -s -O -f grb -t ecmwf -ln tmp.nc tmp.lnsp.grb
  grib_set -s shortName=lnsp tmp.lnsp.grb lnsp.grb
  rm -f tmp.nc tmp.ps.grb tmp.lnsp.grb

  echo $pname: "Preparing ts."
  cdo -s -O -f grb -t ecmwf -setparam,skt -setname,skt -setcode,235 -delvar,average_DT -selyear,$yyyy $ts tmp.grb
  grib_set -s shortName=skt tmp.grb ts.grb
  rm tmp.grb

  echo $pname: "Preparing sftlf (land fraction)."
  cdo -s -O -f grb -t ecmwf -setcode,172 -divc,100 -selvar,sftlf $LANDFRAC tmp.grb
  grib_set -s shortName=lsm tmp.grb lsm.grb
  rm tmp.grb

  echo $pname: "Preparing tos."
  cdo -s -O -f grb -t ecmwf -setcode,34 -selyear,$yyyy -selvar,tos $tos tmp.grb
  grib_set -s shortName=sst tmp.grb tos.grb
  rm tmp.grb

  echo $pname: "Preparing sic."
  cdo -s -O -f grb -t ecmwf -setcode,31 -divc,100 -selyear,$yyyy -selvar,sic $sic tmp.grb
  grib_set -s shortName=ci tmp.grb sic.grb
  rm tmp.grb

fi #Preparation

# Define selected months.
selmons=1,2,3,4,5,6,7,8,9,10,11,12
selmonseq="01 02 03 04 05 06 07 08 09 10 11 12"

echo $pname: "Merging data into one file."
cdo -s -O merge -selmon,$selmons ta.grb -selmon,$selmons ua.grb -selmon,$selmons va.grb -selmon,$selmons hus.grb -selmon,$selmons ps.grb -selmon,$selmons lnsp.grb -selmon,$selmons ts.grb -selmon,$selmons sic.grb -selmon,$selmons tos.grb fc.grb

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

 # GFDL-CM3 does not contain data for Feb 29 (leap years), so Feb 28 is copied
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
  rm -f fc.grb  hus.grb  lnsp.grb  lsm.grb  ps.grb  sic.grb  ta.grb  tos.grb  ts.grb  ua.grb  va.grb  z0.grb
fi #cleanup

echo ========================
