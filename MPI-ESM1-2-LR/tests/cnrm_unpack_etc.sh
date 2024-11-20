#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00

# --- CDO ---
 module load cdo/1.9.6-i170-netcdf-4.4.1.1-hdf5-1.8.18-grib_api-1.17.0


path_in='/home/rossby/boundary/CMIP6/CNRM-ESM2-1/r1i1p1f1/historical/nc/atmos/'
path_out='/nobackup/rossby24/users/sm_grini/Data/TEMP/all/'


f1_in=$path_in'ta_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_201001010600-201007010000.nc'
f2_in=$path_in'ta_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_201007010600-201101010000.nc'


 beg_time="$(date +%s)"

 et="$(date +%s)"
 echo
 echo ... 'Processing DONE, time : ... ' "$(expr $et - $bt)" sec
