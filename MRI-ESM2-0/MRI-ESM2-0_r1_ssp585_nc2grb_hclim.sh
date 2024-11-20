#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00

#######################################################################
####                                                               ####
####      MIROC6 output (nc) to HCLIM input files (grb)            ####
####                            CMIP6                              #### 
####                                                               ####  
#######################################################################

# --- CDO ---
 #module load cdo/1.9.6-i170-netcdf-4.4.1.1-hdf5-1.8.18-grib_api-1.17.0  ### os6
  module load CDO/1.9.5-nsc1-intel-2018a-eb                              ### os7 CDO/1.9.8-nsc1-intel-2018a-eb doesn't work (no bounds for depth layers)

#-----------------------------
# ---     EXPERIMENT       ---
#-----------------------------
 grb_name='MRI-ESM2-0_r1i1p1f1_ssp585'
 
 gcm_name='MRI-ESM2-0'
 exp_id='ssp585'
 gcm_mem='r1i1p1f1'

#-----------------------------
# ---    OUTPUT GRID       ---
#-----------------------------
 grid_out=r320x160
 

#-----------------------------
# --- FIRST and LAST YEARS ---
#-----------------------------
 fy=2062   # first year
 ly=2072   # last year

# -----------------------------
# ---INPUT and OUTPUT PATHS ---
#------------------------------
 path_ref_in='/nobackup/rossby24/proj/rossby/boundary/CMIP6/MRI-ESM2-0/r1i1p1f1/ssp585/nc/'

 #path_out='/nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/MRI-ESM2-0/2037-2040/' 
 #path_out='/nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/MRI-ESM2-0/2041-2050/' 
 #path_out=' /nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/MRI-ESM2-0/2051-2061/' 
 path_out='/nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/MRI-ESM2-0/2062-2072/' 

 #path_out='/nobackup/rossby24/proj/rossby/boundary/CMIP6/MRI-ESM2-0/r1i1p1f1/historical/grb/'
 
 path_in_atmos=$path_ref_in'atmos/' 
 path_in_ocean=$path_ref_in'ocean/'

# -----------------
# --- META INFO ---
# -----------------
 cdo='cdo -s'
 mm_s=(01 02 03 04 05 06 07 08 09 10 11 12) # months
 days=(31 28 31 30 31 30 31 31 30 31 30 31) # number of days in months
 
 file_zaxis=./zaxis/MRI-ESM2-0_zaxis_grb_reverse
 

# ------------------------
# --- REMAPPING METHOD ---
# ------------------------
 #remap='-remapcon'
 #remap='-remapbil'
 #remap='-remapbic'
 remap='-remapdis'

 echo
 echo ... processing ... $grb_name ... $fy'-'$ly



# --------------------
# ---   YEAR LOOP  ---
# --------------------
 beg_time="$(date +%s)"
 for ((yy=fy;yy<=ly;yy++)); do   # year loop
  echo ... now processing ... $yy
  echo

#########################################
####    ALL AVAILABLE tos FILES     ###
#########################################

 mask_file_tos=$path_in_ocean'tos_Oday_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn_'????????'-'????????'.nc'
 flist_tos=`ls $mask_file_tos`
 num_file_tos=0

 echo   AVAILABLE Ocean tos FILES:

 for f in $flist_tos; do
   echo ... tos ..  $f
   num_file_tos=$((num_file_tos+1))
   file_tos[$num_file_tos]=$f                            # tos input files
   date_tmp=${f:(-20)}
   fy_file_tos[$num_file_tos]=${date_tmp:0:4}
   ly_file_tos[$num_file_tos]=${date_tmp:9:4}
  done
  echo
  echo
 
  
#########################################
####    ALL AVAILABLE ocean FILES     ###
#########################################

 mask_file_sic=$path_in_ocean'siconc_SIday_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn_'????????'-'????????'.nc'
 flist_sic=`ls $mask_file_sic`
 num_file_sic=0

 echo   AVAILABLE Ocean siconc FILES:

 for f in $flist_sic; do
   echo ... sic ..  $f
   num_file_sic=$((num_file_sic+1))
   file_sic[$num_file_sic]=$f                            # tos input files
   date_tmp=${f:(-20)}
   fy_file_sic[$num_file_sic]=${date_tmp:0:4}
   ly_file_sic[$num_file_sic]=${date_tmp:9:4}
  done
  echo
  echo
  

#########################################
####   OROGRAHY and LAND-SEA MASK     ###
#########################################
 path_in_fx=$path_ref_in'fx/'
 file_orog_in=$path_in_fx'orog_fx_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn.nc'
 echo ... Orography ... $file_orog_in
 file_sftlf_in=$path_in_fx'sftlf_fx_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn.nc'
 echo ... Land Sea Mask ... $file_sftlf_in
 echo


#########################################
####   INITIAL CONDITION CLIMATOLOGY  ###
#########################################
 path_in_clim='/nobackup/rossby24/users/sm_grini/Data/HCLIM/lbc/era5_clim/'
 file_clim_in=$path_in_clim'clim-ic_mon-clim_ECMWF-ERA5_rean_r1i1p1_fg_198501-201412.grb'
 echo ... IC climatology ... $file_clim_in
 echo
 

#########################################
####      EXTRACT 1 year of OCEAN     ###
#########################################
   for ((nn=1;nn<=num_file_tos;nn++)); do
    if [ $yy -ge ${fy_file_tos[$nn]} -a $yy -le ${ly_file_tos[$nn]} ]; then

    echo ... found
    echo ... ${file_tos[$nn]}
    echo ... ${file_sic[$nn]}

   # --- dates to extract one year ($yy)  ----
    f_date_tos=$((yy-1))'-12-31T00:00:00'
    l_date_tos=$((yy+1))'-01-01T23:00:00'
    echo
    echo ... Ocean first date to extract'    '$f_date_ta 
    echo ... Ocean last date to extract'     '$l_date_ta
    echo
   # --- dates to interpolate daily to 6hr ----
    i_date=$((yy-1))'-12-31'
    #f_date_6hr=$yy'-01-01T06:00:00'
    #l_date_6hr=$((yy+1))'-01-01T00:00:00'
    f_date_6hr=$yy'-01-01T00:00:00'
    l_date_6hr=$yy'-12-31T18:00:00'    
    echo ... first date to interpolate'      '$i_date
    echo ... first interpolated 6hr step'    '$f_date_6hr
    echo ... last interpolated 6hr step'     '$l_date_6hr
    echo

   # ------------ 
   # --- tos ----
   # ------------
    bt="$(date +%s)"
    file_tos_tmp0=$path_out'tmp0_tos_'$grb_name'_'$yy'.nc'
    file_tos_yr=$path_out'tos_'$grb_name'_'$yy'.nc'
    [ -f $file_tos_tmp0 ] && rm $file_tos_tmp0
    [ -f $file_tos_yr ] && rm $file_tos_yr

    if [ $yy -eq ${fy_file_tos[$nn]} ]; then
     echo ... FIRST YEAR tos ...
     $cdo -f nc -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn-1))]} $file_tos_tmp0
    fi
  
    $cdo -f nc cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn))]} $file_tos_tmp0

    if [ $yy -eq ${ly_file_tos[$nn]} ]; then
     echo ... LAST YEAR tos ...
     $cdo -f nc -cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn+1))]} $file_tos_tmp0
    fi
    
    ncap2 -h -O -s 'where(tos != tos) tos=tos.get_miss();' $file_tos_tmp0 $file_tos_tmp0
    
   # --- remap to atmospheric grid and interpolate daily to 6-hr  ---
    $cdo -L -addc,273.15 -seldate,$f_date_6hr,$l_date_6hr -inttime,$i_date,12:00:00,6hour -remapdis,$grid_out -remapdis,$grid_out $file_tos_tmp0 $file_tos_yr
    [ -f $file_tos_tmp0 ] && rm $file_tos_tmp0
    
    
  # ---------------
  # --- siconc ----
  # ---------------
    file_sic_tmp0=$path_out'tmp0_sic_'$grb_name'_'$yy'.nc'
    file_sic_yr=$path_out'sic_'$grb_name'_'$yy'.nc'
    [ -f $file_sic_tmp0 ] && rm $file_sic_tmp0
    [ -f $file_sic_yr ] && rm $file_sic_yr

    if [ $yy -eq ${fy_file_tos[$nn]} ]; then
     echo ... FIRST YEAR sic ...
     $cdo -L -seldate,$f_date_tos,$l_date_tos ${file_sic[$((nn-1))]} $file_sic_tmp0
    fi
  
    $cdo -L cat -seldate,$f_date_tos,$l_date_tos ${file_sic[$((nn))]} $file_sic_tmp0

    if [ $yy -eq ${ly_file_tos[$nn]} ]; then
     echo ... LAST YEAR sic ...
     $cdo -L -cat -seldate,$f_date_tos,$l_date_tos ${file_sic[$((nn+1))]} $file_sic_tmp0
    fi

    ncap2 -h -O -s 'where(siconc != siconc) siconc=siconc.get_miss();' $file_sic_tmp0 $file_sic_tmp0

   # --- remap to atmospheric grid and interpolate daily to 6-hr  ---
    $cdo -L -divc,100 -seldate,$f_date_6hr,$l_date_6hr -inttime,$i_date,12:00:00,6hour -remapdis,$grid_out -remapdis,$grid_out $file_sic_tmp0 $file_sic_yr
    [ -f $file_sic_tmp0 ] && rm $file_sic_tmp0

   et="$(date +%s)"
   echo
   echo ... 'Extracting one year of Ocean   DONE, time : ... ' "$(expr $et - $bt)" sec 
   fi
  done  # get 1 year of Ocean


# ----------------------
# ---   MONTH LOOP  ---
# ----------------------
 for m in 0 1 2 3 4 5 6 7 8 9 10 11 ; do   # month loop
  #for m in 11; do   # month loop
  mm=${mm_s[$((m))]}
  echo ... $yy ... $mm
  echo
  
  # ---- number of days February -------- 
   if [[ $m -eq 1 && $(($yy%4)) -eq 0 ]]; then
    num_day=29
   else
    num_day=${days[m]}
   fi
  
  file_ta=$path_in_atmos'ta_6hrLev_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn_'$yy$mm'010000-'$yy$mm${num_day}'1800.nc' 
  
  file_ua=${file_ta/ta_/ua_}         # ua input files
  file_va=${file_ta/ta_/va_}         # ua input files
  file_hus=${file_ta/ta_/hus_}         # ua input files

  echo ... $file_ta
  echo ... $file_ua
  echo ... $file_va
   
 
 # --- ta ----
   bt="$(date +%s)"
   file_ta_yr=$path_out'ta_'$grb_name'_'$yy$mm'.nc'
   [ -f $file_ta_yr ] && rm $file_ta_yr
   $cdo -L -invertlev $file_ta $file_ta_yr

 # --- ps ---
   file_ps_yr=$path_out'ps_'$grb_name'_'$yy$mm'.nc'
   [ -f $file_ps_yr ] && rm $file_ps_yr
   ncks -O -v ps $file_ta_yr $file_ps_yr

 # --- clean up ta ---
   ncks -O -C -x -v ps $file_ta_yr $file_ta_yr
      
 # --- ua ----
   file_ua_yr=$path_out'ua_'$grb_name'_'$yy$mm'.nc'
   [ -f $file_ua_yr ] && rm $file_ua_yr
   $cdo -L -invertlev $file_ua $file_ua_yr
   ncks -O -C -x -v ps $file_ua_yr $file_ua_yr

 # --- va ----
   file_va_yr=$path_out'va_'$grb_name'_'$yy$mm'.nc'
   [ -f $file_va_yr ] && rm $file_va_yr
   $cdo -L -invertlev $file_va $file_va_yr
   ncks -O -C -x -v ps $file_va_yr $file_va_yr

 # --- hus ----
   file_hus_yr=$path_out'hus_'$grb_name'_'$yy$mm'.nc'
   [ -f $file_hus_yr ] && rm $file_hus_yr
   $cdo -L -invertlev $file_hus $file_hus_yr
   ncks -O -C -x -v ps $file_hus_yr $file_hus_yr

   et="$(date +%s)"
   echo
   echo ... 'Extracting one month of 6hrLev DONE, time : ... ' "$(expr $et - $bt)" sec


echo
echo '---------------------------------------'
echo '--- Start processing 6hr time steps ---'
echo '---------------------------------------'
echo 


# --- number of time step (ta file) ---
  num_ta=`$cdo ntime $file_ta_yr`
  echo ... Year $yy ... time steps ... $num_ta

 for ((ss=1;ss<=$((num_ta));ss++)); do   # time step loop
   #for ((ss=1;ss<=1;ss++)); do   # time step loop
     #for ((ss=1;ss<=125;ss++)); do   # time step loop

 # --- temporary file names ---
  file_out=$path_out$grb_name'_lbc_'$yy'_'$ss'.grb'
  file_tmp0=$path_out'tmp0_'$grb_name'_lbc_'$yy'_'$ss'.nc'
  file_tmp1=$path_out'tmp1_'$grb_name'_lbc_'$yy'_'$ss'.nc'
  file_tmp2=$path_out'tmp2_'$grb_name'_lbc_'$yy'_'$ss'.grb'

  bt="$(date +%s)"
  ########### PROCESSING TIME STEPS ####################

   # --- one time step for ta ---
    file_ta_tmp=$path_out'tmp_ta_'$yy$mm'_'$ss'.grb'  
    [ -f $file_ta_tmp ] && rm $file_ta_tmp
    $cdo -L -f grb -setparam,130.128 -setzaxis,$file_zaxis -seltimestep,$ss $file_ta_yr $file_ta_tmp

   # --- date and time of one time step for ta ---
    aaa_date=$($cdo showdate $file_ta_tmp)
    aaa_date=${aaa_date// /} 
    aaa_time=$($cdo showtime $file_ta_tmp) 
    aaa_time=${aaa_time// /}
    aaa_time_in=$aaa_date'T'$aaa_time
    aaa_time_ref=$aaa_date','$aaa_time
    aaa_mon_in=${aaa_date:5:2}
    aaa_mon_in=${aaa_mon_in/0/}
    echo
    echo ... TIME STEP ... $ss
    echo ... Date-Time ... $aaa_time_in 
    echo ... Ref. Time ... $aaa_time_ref 
    echo ... Month '    ...' $aaa_mon_in
 

  # --- one time step for ua ---
    file_ua_tmp=$path_out'tmp_ua_'$yy$mm'_'$ss'.grb' 
    [ -f $file_ua_tmp ] && rm $file_ua_tmp
    $cdo -L -f grb -setparam,131.128 -setzaxis,$file_zaxis -seldate,$aaa_time_in $file_ua_yr $file_ua_tmp
    
   # --- one time step for va ---
    file_va_tmp=$path_out'tmp_va_'$yy$mm'_'$ss'.grb' 
    [ -f $file_va_tmp ] && rm $file_va_tmp
    $cdo -L -f grb -setparam,132.128 -setzaxis,$file_zaxis -seldate,$aaa_time_in $file_va_yr $file_va_tmp 

   # --- one time step for hus ---
    file_hus_tmp=$path_out'tmp_hus_'$yy$mm'_'$ss'.grb' 
    [ -f $file_hus_tmp ] && rm $file_hus_tmp
    $cdo -L -f grb -setparam,133.128 -setzaxis,$file_zaxis -seldate,$aaa_time_in $file_hus_yr $file_hus_tmp 

   # --- one time step for ps ---
    file_ps_tmp=$path_out'tmp_ps_'$yy$mm'_'$ss'.grb' 
    [ -f $file_ps_tmp ] && rm $file_ps_tmp
    $cdo -L -f grb -setparam,134.128 -seldate,$aaa_time_in $file_ps_yr $file_ps_tmp

   # --- one time step for lnps ---
    file_lnps_tmp=$path_out'tmp_lnps_'$yy$mm'_'$ss'.grb' 
    [ -f $file_lnps_tmp ] && rm $file_lnps_tmp
    $cdo -L -f grb -setparam,152.128 -ln -seldate,$aaa_time_in $file_ps_yr $file_lnps_tmp

   # --- one time step for tos ---
    file_tos_tmp=$path_out'tmp_tos_'$yy$mm'_'$ss'.grb' 
    [ -f $file_tos_tmp ] && rm $file_tos_tmp
    $cdo -L -f grb -setparam,34.128 -seldate,$aaa_time_in $file_tos_yr $file_tos_tmp

   # --- one time step for sic ---
    file_sic_tmp=$path_out'tmp_sic_'$yy$mm'_'$ss'.grb' 
    [ -f $file_sic_tmp ] && rm $file_sic_tmp
    $cdo -L -f grb -setparam,31.128 -seldate,$aaa_time_in $file_sic_yr $file_sic_tmp

   # ---    orography   ---
    file_orog_tmp=$path_out'tmp_orog_'$yy$mm'_'$ss'.grb' 
    [ -f $file_orog_tmp ] && rm $file_orog_tmp
    $cdo -L -f grb -mulc,9.80665 -setparam,129.128 -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date $file_orog_in $file_orog_tmp

   # ---  land sea mask   ---
    file_sftlf_tmp=$path_out'tmp_sftlf_'$yy$mm'_'$ss'.grb' 
    [ -f $file_sftlf_tmp ] && rm $file_sftlf_tmp
    $cdo -L -f grb -divc,100 -setparam,172.128 -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date $file_sftlf_in $file_sftlf_tmp

  # --- IC climatology ERA5  ---
    file_clim_tmp=$path_out'tmp_clim_'$yy$mm'_'$ss'.grb' 
    [ -f $file_clim_tmp ] && rm $file_clim_tmp
    $cdo -remapdis,$grid_out -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date -selmon,$aaa_mon_in $file_clim_in $file_clim_tmp


# ########### MERGING ALL VARIABLES to ONE FILE ####################
 file_out_tmp=$path_out'tmp_out_'$aaa_time_in'.grb'
 file_out_tmp1=$path_out'tmp1_out_'$aaa_time_in'.grb'  
 [ -f $file_out_tmp ] && rm $file_out_tmp
 [ -f $file_out_tmp1 ] && rm $file_out_tmp1
 
 $cdo -remapbil,$grid_out -merge $file_ta_tmp $file_ua_tmp $file_va_tmp $file_hus_tmp $file_ps_tmp $file_orog_tmp $file_sftlf_tmp $file_out_tmp1
 $cdo -merge -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date $file_clim_tmp $file_tos_tmp $file_sic_tmp $file_out_tmp1 $file_out_tmp

# --- output file name from time in grib files ---
 f_date=`$cdo showdate -seltimestep,1 $file_out_tmp`; f_date=${f_date// /}; f_date=${f_date//-/}
 f_time=`$cdo showtime -seltimestep,1 $file_out_tmp`; f_time=${f_time:1:2}
 echo ... DATE in OUTPUT FILE ... $f_date$f_time
 file_out=$path_out$grb_name'_'$f_date$f_time'00+000H00M'
 grib_set -s timeRangeIndicator=0,centre=98,table2Version=128 $file_out_tmp $file_out
 [ -f $file_out_tmp ] && rm $file_out_tmp
 [ -f $file_out_tmp1 ] && rm $file_out_tmp1
 
# --- delete temporaly files (one time step) ---
 rm ${path_out}tmp_*

  et="$(date +%s)"
  echo ... 'PROCESSING TIME for STEP '$ss ' ... ' "$(expr $et - $bt)" sec 
  done # time step
  

# --- delete temporaly files (one month) ---  
  rm ${path_out}*${yy}${mm}'.nc'

 done # month

# --- delete temporaly files (one year) ---  
 rm ${path_out}*${yy}'.nc'

 done # year



end_time="$(date +%s)"
echo
echo ... ELAPSED TOTAL TIME ALL :  "$(expr $end_time - $beg_time)" sec
echo ... END


