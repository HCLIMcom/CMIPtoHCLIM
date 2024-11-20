#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00

# --- CDO ---
 #module load cdo/1.9.6-i170-netcdf-4.4.1.1-hdf5-1.8.18-grib_api-1.17.0

 module load cdo/1.6.9-i1501-netcdf-4.3.2-hdf5-1.8.14-grib_api-1.14.0

#cdo/1.6.9-i1501-netcdf-4.3.2-hdf5-1.8.14
#cdo/1.6.9-i1501-netcdf-4.3.2-hdf5-1.8.14-grib_api-1.14.0
#cdo/1.7.0-i1501-netcdf-4.3.2-hdf5-1.8.14-grib_api-1.14.0
#cdo/1.8.0-i1501-netcdf-4.3.2-hdf5-1.8.14-grib_api-1.17.0
#cdo/1.8.2-i1501-netcdf-4.3.2-hdf5-1.8.14-grib_api-1.17.0(default)

#cdo/1.9.6-i170-netcdf-4.4.1.1-hdf5-1.8.18-eccodes-proj-udunits2
#cdo/1.9.7.1-g62-netcdf-4.4.1.1-hdf5-1.8.18-eccodes-proj-udunits2-Magics
#cdo/1.9.7.1-i170-netcdf-4.4.1.1-hdf5-1.8.18-eccodes-proj-udunits2




path_in='/home/rossby/boundary/CMIP6/CNRM-ESM2-1/r1i1p1f1/historical/nc/atmos/'
path_out='/nobackup/rossby24/users/sm_grini/Data/TEMP/all/'


f1_in=$path_in'ta_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_201001010600-201007010000.nc'
f2_in=$path_in'ta_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_201007010600-201101010000.nc'

f1_out=$path_out'f1.nc'
f2_out=$path_out'f2.nc'
f3_out=$path_out'f3.nc'


echo ... $f1_in
echo ... $f1_out


 bt="$(date +%s)"

  #nccopy -k 1 $f1_in $f1_out
  #cdo -L -f nc -copy $f1_in $f1_out
  #cdo -f nc -copy $f1_in $f1_out
  #ncks --fl_fmt=classic -h $f1_in $f1_out

  nccopy -k 1 $f1_in $f1_out
  nccopy -k 1 $f2_in $f2_out
  ncrcat $f1_out $f2_out $f3_out
 

 et="$(date +%s)"
 echo
 echo ... 'Processing DONE, time : ... ' "$(expr $et - $bt)" sec
