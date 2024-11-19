#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00

#######################################################################
####                                                               ####
####      CNRM-ESM2-1 output (nc) to HCLIM input files (grb)       ####
####                            CMIP6                              #### 
####                                                               ####  
#######################################################################

# --- CDO ---
 module load cdo/1.9.6-i170-netcdf-4.4.1.1-hdf5-1.8.18-grib_api-1.17.0


#-----------------------------
# ---     EXPERIMENT       ---
#-----------------------------
 grb_name='CNRM-ESM2-1_r1i1p1f2_hist'
 
 gcm_name='CNRM-ESM2-1'
 exp_id='historical'
 gcm_mem='r1i1p1f2'

#-----------------------------
# ---    OUTPUT GRID       ---
#-----------------------------
 grid_out=r256x128

#-----------------------------
# --- FIRST and LAST YEARS ---
#-----------------------------
 fy=1950   # first year
 ly=1957   # last year

# -----------------------------
# ---INPUT and OUTPUT PATHS ---
#------------------------------
 path_ref_in='/home/rossby/boundary/CMIP6/CNRM-ESM2-1/r1i1p1f1/historical/nc/'
 #path_out='/nobackup/rossby24/users/sm_grini/Data/TEMP/CNRM-ESM2-1_LBC/grb/'

 path_out='/nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/CNRM-ESM2-1/grb/1950-1957/'
 #path_out='/nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/CNRM-ESM2-1/grb/2001-2014/'


# -----------------
# --- META INFO ---
# -----------------
 cdo='cdo -s'
 file_zaxis=./zaxis/CNRM-ESM2-1_zaxis_grb_reverse
 mm_s=(01 02 03 04 05 06 07 08 09 10 11 12) 

# ------------------------
# --- REMAPPING METHOD ---
# ------------------------
 #remap='-remapcon'
 #remap='-remapbil'
 #remap='-remapbic'
 remap='-remapdis'

 echo
 echo ... processing ... $grb_name ... $fy'-'$ly



##########################################
####     ALL AVAILABLE 6hrLev FILES    ###
####    ta and hus: 2 files per year   ###
##########################################
 path_in_atmos=$path_ref_in'atmos/'
 mask_file_ta=$path_in_atmos'ta_6hrLev_'$gcm_name'_'$exp_id'_'$gcm_mem'_gr_'????????????'-'????????????'.nc'
 flist_ta=`ls $mask_file_ta`
 num_file_ta=0

 echo
 echo   "AVAILABLE 6hrLev FILES (ta and hus):"

 for f in $flist_ta; do
   echo ... ta ...  $f
   num_file_ta=$((num_file_ta+1))
   file_ta[$num_file_ta]=$f                   # ta input files
   file_hus[$num_file_ta]=${f/ta_/hus_}       # hus input files
   date_tmp=${f:(-28)}
   fy_file_ta[$num_file_ta]=${date_tmp:0:4}
   ly_file_ta[$num_file_ta]=${date_tmp:13:4}
 done
 echo
 echo

#########################################
####     ALL AVAILABLE 6hrLev FILES   ###
####     ua and va: 3 files per year  ###
#########################################
 path_in_atmos=$path_ref_in'atmos/'
 mask_file_ua=$path_in_atmos'ua_6hrLev_'$gcm_name'_'$exp_id'_'$gcm_mem'_gr_'????????????'-'????????????'.nc'
 flist_ua=`ls $mask_file_ua`
 num_file_ua=0

 echo
 echo   "AVAILABLE 6hrLev FILES (ua and va):"

 for f in $flist_ua; do
   echo ... ua ...  $f
   num_file_ua=$((num_file_ua+1))
   file_ua[$num_file_ua]=$f                   # ta input files
   file_va[$num_file_ua]=${f/ua_/va_}         # va input files  
   date_tmp=${f:(-28)}
   fy_file_ua[$num_file_ua]=${date_tmp:0:4}
   ly_file_ua[$num_file_ua]=${date_tmp:13:4}
 done
 echo
 echo

#########################################
####   ALL AVAILABLE ocean FILES SST  ###
#########################################
 path_in_ocean=$path_ref_in'ocean/'
 mask_file_tos=$path_in_ocean'tos_Oday_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn_'????????'-'????????'.nc'
 flist_tos=`ls $mask_file_tos`
 num_file_tos=0

 echo   "AVAILABLE Ocean FILES (tos):"

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

#############################################
####    ALL AVAILABLE ocean FILES siconc  ###
#############################################
 path_in_ocean=$path_ref_in'ocean/'
 mask_file_sic=$path_in_ocean'siconc_SIday_'$gcm_name'_'$exp_id'_'$gcm_mem'_gn_'????????'-'????????'.nc'
 flist_sic=`ls $mask_file_sic`
 num_file_sic=0

 echo   "AVAILABLE Ocean FILES siconc:"

 for f in $flist_sic; do
   echo ... sic ..  $f
   num_file_sic=$((num_file_sic+1))
   file_sic[$num_file_sic]=$f                            # sic input files
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
 file_orog_in=$path_in_fx'orog_fx_'$gcm_name'_ssp370_'$gcm_mem'_gr.nc'
 echo ... Orography ... $file_orog_in
 file_sftlf_in=$path_in_fx'sftlf_fx_'$gcm_name'_ssp370_'$gcm_mem'_gr.nc'
 echo ... Land Sea Mask ... $file_sftlf_in
 echo

#########################################
####   INITIAL CONDITION CLIMATOLOGY  ###
#########################################
 path_in_clim='/nobackup/rossby24/users/sm_grini/Data/HCLIM/lbc/era5_clim/'
 file_clim_in=$path_in_clim'clim-ic_mon-clim_ECMWF-ERA5_rean_r1i1p1_fg_198501-201412.grb'
 echo ... IC climatology ... $file_clim_in
 echo


# --------------------
# ---   YEAR LOOP  ---
# --------------------
 beg_time="$(date +%s)"
 for ((yy=fy;yy<=ly;yy++)); do   # year loop
  echo ... now processing ... $yy
  echo

# ----------------------------------------------
# --- Extratct 1 year of 6hrLev (ta and hus) ---
# ----------------------------------------------
  for ((nn=1;nn<=num_file_ta;nn+=2)); do

   if [ $yy -eq ${fy_file_ta[$nn]} -a $yy -eq ${ly_file_ta[$nn]} ]; then

    echo ... found --- ta ---
    echo ... ${file_ta[$nn]}
    echo ... ${file_ta[$nn+1]}
    echo
    echo ... found --- hus ---
    echo ... ${file_hus[$nn]}
    echo ... ${file_hus[$nn+1]}

  # --- get one year ($yy)  ----
   f_date_ta=$yy'-01-01T05:00:00'
   l_date_ta=$((yy+1))'-01-01T01:00:00'
   echo
   echo ... 6hrLev first date to read'  '$f_date_ta 
   echo ... 6hrLev last date to read'   '$l_date_ta

  # --- ta ----
   bt="$(date +%s)"
   file_ta_yr=$path_out'ta_'$grb_name'_'$yy'.nc'
   file_ta_yr_tmp1=$path_out'tmp1_ta_'$grb_name'_'$yy'.nc'
   file_ta_yr_tmp2=$path_out'tmp2_ta_'$grb_name'_'$yy'.nc'
   [ -f $file_ta_yr ] && rm $file_ta_yr
   [ -f $file_ta_yr_tmp1 ] && rm $file_ta_yr_tmp1
   [ -f $file_ta_yr_tmp2 ] && rm $file_ta_yr_tmp2

   nccopy -k 1 ${file_ta[$((nn))]} $file_ta_yr_tmp1
   nccopy -k 1 ${file_ta[$((nn+1))]} $file_ta_yr_tmp2
   ncrcat $file_ta_yr_tmp1 $file_ta_yr_tmp2 $file_ta_yr
   ncpdq -O -a -lev,bnds $file_ta_yr $file_ta_yr

  # --- ps ---
   file_ps_yr=$path_out'ps_'$grb_name'_'$yy'.nc'
   [ -f $file_ps_yr ] && rm $file_ps_yr
   ncks -O -v ps $file_ta_yr $file_ps_yr

  # --- clean up ta ---
   ncks -O -x -v ps $file_ta_yr $file_ta_yr

  # --- hus ----
   file_hus_yr=$path_out'hus_'$grb_name'_'$yy'.nc'
   file_hus_yr_tmp1=$path_out'tmp1_hus_'$grb_name'_'$yy'.nc'
   file_hus_yr_tmp2=$path_out'tmp2_hus_'$grb_name'_'$yy'.nc'
   [ -f $file_hus_yr ] && rm $file_hus_yr
   [ -f $file_hus_yr_tmp1 ] && rm $file_hus_yr_tmp1
   [ -f $file_hus_yr_tmp2 ] && rm $file_hus_yr_tmp2

   nccopy -k 1 ${file_hus[$((nn))]} $file_hus_yr_tmp1
   nccopy -k 1 ${file_hus[$((nn+1))]} $file_hus_yr_tmp2
   ncrcat $file_hus_yr_tmp1 $file_hus_yr_tmp2 $file_hus_yr
   ncpdq -O -a -lev,bnds $file_hus_yr $file_hus_yr
   ncks -O -x -v ps $file_hus_yr $file_hus_yr
   ncap2 -O -s "where(hus < 0) hus=0;" $file_hus_yr $file_hus_yr  ##########
  
  et="$(date +%s)"
  echo
  echo ... 'Extracting one year of 6hrLev (ta and hus) DONE, time : ... ' "$(expr $et - $bt)" sec

  fi
 done  # get 1 year of 6hrLev (ta and hus)


# ----------------------------------------------
# --- Extratct 1 year of 6hrLev (ua and va) ---
# ----------------------------------------------
 for ((nn=1;nn<=num_file_ua;nn+=3)); do
  if [ $yy -eq ${fy_file_ua[$nn]} -a $yy -eq ${ly_file_ua[$nn]} ]; then
    
    echo
    echo ... found --- ua ---
    echo ... ${file_ua[$nn]}
    echo ... ${file_ua[$nn+1]}
    echo ... ${file_ua[$nn+2]}
    echo
    echo ... found --- va ---
    echo ... ${file_va[$nn]}
    echo ... ${file_va[$nn+1]}
    echo ... ${file_va[$nn+2]}
    
  # --- ua ----
   file_ua_yr=$path_out'ua_'$grb_name'_'$yy'.nc'
   file_ua_yr_tmp1=$path_out'tmp1_ua_'$grb_name'_'$yy'.nc'
   file_ua_yr_tmp2=$path_out'tmp2_ua_'$grb_name'_'$yy'.nc'
   file_ua_yr_tmp3=$path_out'tmp3_ua_'$grb_name'_'$yy'.nc'
   [ -f $file_ua_yr ] && rm $file_ua_yr
   [ -f $file_ua_yr_tmp1 ] && rm $file_ua_yr_tmp1
   [ -f $file_ua_yr_tmp2 ] && rm $file_ua_yr_tmp2
   [ -f $file_ua_yr_tmp3 ] && rm $file_ua_yr_tmp3

   nccopy -k 1 ${file_ua[$((nn))]} $file_ua_yr_tmp1
   nccopy -k 1 ${file_ua[$((nn+1))]} $file_ua_yr_tmp2
   nccopy -k 1 ${file_ua[$((nn+2))]} $file_ua_yr_tmp3
   ncrcat $file_ua_yr_tmp1 $file_ua_yr_tmp2 $file_ua_yr_tmp3 $file_ua_yr
   ncpdq -O -a -lev,bnds $file_ua_yr $file_ua_yr
   ncks -O -x -v ps $file_ua_yr $file_ua_yr

# --- va ----
   file_va_yr=$path_out'va_'$grb_name'_'$yy'.nc'
   file_va_yr_tmp1=$path_out'tmp1_va_'$grb_name'_'$yy'.nc'
   file_va_yr_tmp2=$path_out'tmp2_va_'$grb_name'_'$yy'.nc'
   file_va_yr_tmp3=$path_out'tmp3_va_'$grb_name'_'$yy'.nc'
   [ -f $file_va_yr ] && rm $file_va_yr
   [ -f $file_va_yr_tmp1 ] && rm $file_va_yr_tmp1
   [ -f $file_va_yr_tmp2 ] && rm $file_va_yr_tmp2
   [ -f $file_va_yr_tmp3 ] && rm $file_va_yr_tmp3

   nccopy -k 1 ${file_va[$((nn))]} $file_va_yr_tmp1
   nccopy -k 1 ${file_va[$((nn+1))]} $file_va_yr_tmp2
   nccopy -k 1 ${file_va[$((nn+2))]} $file_va_yr_tmp3
   ncrcat $file_va_yr_tmp1 $file_va_yr_tmp2 $file_va_yr_tmp3 $file_va_yr
   ncpdq -O -a -lev,bnds $file_va_yr $file_va_yr
   ncks -O -x -v ps $file_va_yr $file_va_yr
 
   et="$(date +%s)"
   echo
   echo ... 'Extracting one year of 6hrLev (ua and va) DONE, time : ... ' "$(expr $et - $bt)" sec
  fi
 done  # get 1 year of 6hrLev (ta and hus)


# ---------------------------------
# --- Extratct 1 year of Ocean  ---
# ---------------------------------
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

    f_date_sic=$f_date_tos
    l_date_sic=$l_date_tos
  
   # --- dates to interpolate daily to 6hr ----
    i_date=$((yy-1))'-12-31'
    f_date_6hr=$yy'-01-01T06:00:00'
    l_date_6hr=$((yy+1))'-01-01T00:00:00'  
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
     $cdo -L -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn-1))]} $file_tos_tmp0
    fi
  
    $cdo -L cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn))]} $file_tos_tmp0

    if [ $yy -eq ${ly_file_tos[$nn]} ]; then
     echo ... LAST YEAR tos ...
     $cdo -L -cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn+1))]} $file_tos_tmp0
    fi

   # --- remap to atmospheric grid and interpolate daily to 6-hr  ---
    $cdo -L -addc,273.15 -seldate,$f_date_6hr,$l_date_6hr -inttime,$i_date,12:00:00,6hour -remapdis,$grid_out $file_tos_tmp0 $file_tos_yr
    [ -f $file_tos_tmp0 ] && rm $file_tos_tmp0

   fi
  done  # get 1 year of Ocean (tos)


 for ((nn=1;nn<=num_file_sic;nn++)); do
    if [ $yy -ge ${fy_file_sic[$nn]} -a $yy -le ${ly_file_sic[$nn]} ]; then

  # ---------------
  # --- siconc ----
  # ---------------
    file_sic_tmp0=$path_out'tmp0_sic_'$grb_name'_'$yy'.nc'
    file_sic_yr=$path_out'sic_'$grb_name'_'$yy'.nc'
    [ -f $file_sic_tmp0 ] && rm $file_sic_tmp0
    [ -f $file_sic_yr ] && rm $file_sic_yr

    if [ $yy -eq ${fy_file_sic[$nn]} ]; then
     echo ... FIRST YEAR sic ...
     $cdo -L -seldate,$f_date_sic,$l_date_sic ${file_sic[$((nn-1))]} $file_sic_tmp0
    fi
  
    $cdo -L cat -seldate,$f_date_sic,$l_date_sic ${file_sic[$((nn))]} $file_sic_tmp0

    if [ $yy -eq ${ly_file_sic[$nn]} ]; then
     echo ... LAST YEAR sic ...
     $cdo -L -cat -seldate,$f_date_sic,$l_date_sic ${file_sic[$((nn+1))]} $file_sic_tmp0
    fi

   # --- remap to atmospheric grid and interpolate daily to 6-hr  ---
    $cdo -L -divc,100 -seldate,$f_date_6hr,$l_date_6hr -inttime,$i_date,12:00:00,6hour -remapdis,$grid_out $file_sic_tmp0 $file_sic_yr
    [ -f $file_sic_tmp0 ] && rm $file_sic_tmp0

   fi
  done  # get 1 year of Ocean (sic) 

   et="$(date +%s)"
   echo
   echo ... 'Extracting one year of Ocean DONE, time : ... ' "$(expr $et - $bt)" sec 


echo
echo '---------------------------------------'
echo '--- Start processing 6hr time steps ---'
echo '---------------------------------------'
echo 

 for m in 1 2 3 4 5 6 7 8 9 10 11 12 ; do   # month loop
 #for m in 2 ; do   # month loop
 mm=${mm_s[$((m-1))]}

 file_ta_mon=$path_out'ta_mon_'$grb_name'_'$yy$mm'.nc'
 [ -f $file_ta_mon ] && rm $file_ta_mon
 cdo -L -selmon,$m $file_ta_yr $file_ta_mon

 file_ua_mon=$path_out'ua_mon_'$grb_name'_'$yy$mm'.nc'
 [ -f $file_ua_mon ] && rm $file_ua_mon
 $cdo -L -selmon,$m $file_ua_yr $file_ua_mon

 file_va_mon=$path_out'va_mon_'$grb_name'_'$yy$mm'.nc'
 [ -f $file_va_mon ] && rm $file_va_mon
 $cdo -L -selmon,$m $file_va_yr $file_va_mon

 file_hus_mon=$path_out'hus_mon_'$grb_name'_'$yy$mm'.nc'
 [ -f $file_hus_mon ] && rm $file_hus_mon
 $cdo -L -selmon,$m $file_hus_yr $file_hus_mon


# --- number of time step (ta file) ---
  num_ta=`$cdo ntime $file_ta_mon`
  echo ... Year $yy ... Month ... $mm ... time steps ... $num_ta

  for ((ss=1;ss<=$((num_ta));ss++)); do   # time step loop
   #for ((ss=1;ss<=1;ss++)); do   # time step loop
     
 # --- temporary file names ---
  file_out=$path_out$grb_name'_lbc_'$yy'_'$ss'.grb'
  file_tmp0=$path_out'tmp0_'$grb_name'_lbc_'$yy'_'$ss'.nc'
  file_tmp1=$path_out'tmp1_'$grb_name'_lbc_'$yy'_'$ss'.nc'
  file_tmp2=$path_out'tmp2_'$grb_name'_lbc_'$yy'_'$ss'.grb'

  bt="$(date +%s)"
  ########### PROCESSING TIME STEPS ####################

   # --- one time step for ta ---
    file_ta_tmp=$path_out'tmp_ta_'$yy$mm'_'$ss'.grb'
    file_ta_tmp1=$path_out'tmp1_ta_'$yy$mm'_'$ss'.grb'    
    [ -f $file_ta_tmp ] && rm $file_ta_tmp
    [ -f $file_ta_tmp1 ] && rm $file_ta_tmp1
    $cdo -L -seltimestep,$ss $file_ta_mon $file_ta_tmp1
    $cdo -L -f grb -setparam,130.128 -setzaxis,$file_zaxis $file_ta_tmp1 $file_ta_tmp
    [ -f $file_ta_tmp1 ] && rm $file_ta_tmp1
    
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
    file_ua_tmp1=$path_out'tmp1_ua_'$yy$mm'_'$ss'.grb'     
    [ -f $file_ua_tmp ] && rm $file_ua_tmp
    [ -f $file_ua_tmp1 ] && rm $file_ua_tmp1
    $cdo -L -seldate,$aaa_time_in $file_ua_mon $file_ua_tmp1
    $cdo -L -f grb -setparam,131.128 -setzaxis,$file_zaxis $file_ua_tmp1 $file_ua_tmp
    [ -f $file_ua_tmp1 ] && rm $file_ua_tmp1

  # --- one time step for va ---
    file_va_tmp=$path_out'tmp_va_'$yy$mm'_'$ss'.grb'
    file_va_tmp1=$path_out'tmp1_va_'$yy$mm'_'$ss'.grb'
    [ -f $file_va_tmp ] && rm $file_va_tmp
    [ -f $file_va_tmp1 ] && rm $file_va_tmp1
    $cdo -L -seldate,$aaa_time_in $file_va_mon $file_va_tmp1
    $cdo -L -f grb -setparam,132.128 -setzaxis,$file_zaxis $file_va_tmp1 $file_va_tmp
    [ -f $file_va_tmp1 ] && rm $file_va_tmp1

  # --- one time step for hus ---
    file_hus_tmp=$path_out'tmp_hus_'$yy$mm'_'$ss'.grb'
    file_hus_tmp1=$path_out'tmp1_hus_'$yy$mm'_'$ss'.grb'
    [ -f $file_hus_tmp ] && rm $file_hus_tmp
    [ -f $file_hus_tmp1 ] && rm $file_hus_tmp1
    $cdo -L -seldate,$aaa_time_in $file_hus_mon $file_hus_tmp1
    $cdo -L -f grb -setparam,133.128 -setzaxis,$file_zaxis $file_hus_tmp1 $file_hus_tmp
    [ -f $file_hus_tmp1 ] && rm $file_hus_tmp1

  # --- one time step for ps ---
    file_ps_tmp=$path_out'tmp_ps_'$yy$mm'_'$ss'.grb' 
    [ -f $file_ps_tmp ] && rm $file_ps_tmp
    $cdo -L -f grb -setparam,134.128 -seldate,$aaa_time_in $file_ps_yr $file_ps_tmp

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

   # --- IC climatology  ---
    file_clim_tmp=$path_out'tmp_clim_'$yy$mm'_'$ss'.grb' 
    [ -f $file_clim_tmp ] && rm $file_clim_tmp
    $cdo -remapdis,$grid_out -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date -selmon,$aaa_mon_in $file_clim_in $file_clim_tmp
    
    # ---- only a subset of varibales with climatology --- 
    #$cdo -remapdis,$grid_out -selcode,139,170,183,236,39,40,41,42,141 -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date -selmon,$aaa_mon_in $file_clim_in $file_clim_tmp


# ########### MERGING ALL VARIABLES to ONE FILE ####################
  file_out_tmp=$path_out'tmp_out_'$aaa_time_in'.grb'
  file_out_tmp1=$path_out'tmp1_out_'$aaa_time_in'.grb'  
  [ -f $file_out_tmp ] && rm $file_out_tmp
  [ -f $file_out_tmp1 ] && rm $file_out_tmp1
 
# --- merge variables on naitive grid ---
  $cdo -remapbil,$grid_out -merge $file_ta_tmp $file_ua_tmp $file_va_tmp $file_hus_tmp $file_ps_tmp $file_orog_tmp $file_sftlf_tmp $file_out_tmp1
 
# --- add variables on regular grid ---
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
  echo ... 'PROCESSING TIME for STEP '$ss ' ... ' "$(expr $et - $bt)" sec a
 done # time step

# --- delete temporaly files (one month) ---  
  rm ${path_out}*${yy}${mm}'.nc'
 done  # month loop

# --- delete temporaly files (one year) ---  
 rm ${path_out}*${yy}'.nc'
done # year

end_time="$(date +%s)"
echo
echo ... ELAPSED TOTAL TIME ALL :  "$(expr $end_time - $beg_time)" sec
echo ... END



 


