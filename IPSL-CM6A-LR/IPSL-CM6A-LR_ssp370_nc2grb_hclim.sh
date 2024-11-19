#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00
#SBATCH -A cordex

#######################################################################
####                                                               ####
####       IPSL-CM6A-LR output (nc) to HCLIM input files (grb)     ####
####                            CMIP6                              #### 
####                                                               ####  
####      Converted from NorESM scripts from Grisha by Ole         ####
#######################################################################

# --- CDO and eccodes ---

 module load CDO/1.9.7.1-nsc1-intel-2018a-eb
 module load eccodes/2.8.2-nsc1-gcc-2018a-eb
 
 echo ... CDO Version ...
 #cdo -V
 echo
 
#-----------------------------
# ---     EXPERIMENT       ---
#-----------------------------
 grb_name='IPSL-CM6A-LR_ssp370_r1i1p1f1'
 
 gcm_name='IPSL-CM6A-LR'
 exp_id='ssp370'
 gcm_mem='r1i1p1f1'


#-----------------------------
# ---    OUTPUT GRID       ---
#-----------------------------
 grid_out=r144x144
 

#-----------------------------
# --- FIRST and LAST YEARS ---
#-----------------------------
 fy=2100   # first year
 ly=2100   # last year


# -----------------------------
# ---INPUT and OUTPUT PATHS ---
#------------------------------
  #path_ref_in='/home/rossby/boundary/CMIP6/NorESM2-MM/r1i1p1f1/historical/nc/'
  #path_out='/home/rossby/boundary/CMIP6/NorESM2-MM/r1i1p1f1/historical/grb/'
 
  path_ref_in='/home/rossby/data_lib/esgf/CMIP6/ScenarioMIP/IPSL/'
  
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2015/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2016-2020/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2021-2025/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2026-2030/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2031-2040/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2041-2050/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2051-2060/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2061-2070/"
  #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2071-2080/"
  
   #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2081-2090/"
   #path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2091-2100/"
    path_out="/nobackup/rossby27/users/sm_grini/TEMP/20230409_ipsl_lbc/ssp370/2100/"
  
  path_scripts='/home/sm_grini/Scripts/CMIP6/lbc/hclim/IPSL-CM6A-LR/'
 
 path_in_atmos=$path_ref_in$gcm_name'/'$exp_id'/'$gcm_mem'/6hrLev/' 
 path_in_ocean=$path_scripts'/ocean/'$exp_id'/'
 path_in_fx=$path_scripts'/fx/'
 
  
 echo ... PATH ATMOS ... $path_in_atmos
 echo ... PATH OCEAN ... $path_in_ocean
 echo ... PATH FX '   ...' $path_in_fx

 
 #OBC
 tmp1=$path_out/fil1.nc
 tmp2=$path_out/fil2.nc
 tmp3=$path_out/fil3.nc


# -----------------
# --- META INFO ---
# -----------------
 cdo='cdo -s'
 file_zaxis=$path_scripts'/zaxis/IPSL-CM6A-LR_zaxis_grb_reverse_GN'
 echo ... ZAXIS '     ...' $file_zaxis
 echo
 
# ------------------------
# --- REMAPPING METHOD ---
# ------------------------
 #remap='-remapcon'
 #remap='-remapbil'
 #remap='-remapbic'
 remap='-remapdis'

 echo
 echo ... processing ... $grb_name ... $fy'-'$ly

#####################################
####  ALL AVAILABLE 6hrLev FILES  ###
#####################################
 mask_file_ta=$path_in_atmos'ta/gr/latest/ta_6hrLev_'$gcm_name'_'$exp_id'_'$gcm_mem'_gr_'????????????'-'????????????'.nc'
 flist_ta=`ls $mask_file_ta`
 num_file_ta=0

 echo
 echo   AVAILABLE 6hrLev FILES:

 for f in $flist_ta; do
   echo ... ta ...  $f
   num_file_ta=$((num_file_ta+1))
   file_ta[$num_file_ta]=$f                   # ta input files
   
   file_ua_tmp=${f/"ta_6hrLev"/"ua_6hrLev"}
   file_ua[$num_file_ta]=${file_ua_tmp/"ta/gr"/"ua/gr"}
   
   file_va_tmp=${f/"ta_6hrLev"/"va_6hrLev"}
   file_va[$num_file_ta]=${file_va_tmp/"ta/gr"/"va/gr"}
   
   file_hus_tmp=${f/"ta_6hrLev"/"hus_6hrLev"}
   file_hus[$num_file_ta]=${file_hus_tmp/"ta/gr"/"hus/gr"}
    
   date_tmp=${f:(-28)}
   fy_file_ta[$num_file_ta]=${date_tmp:0:4}
   ly_file_ta[$num_file_ta]=${date_tmp:13:4}
 done
 echo
 echo

 echo ... ${file_ta[1]}
 echo ... ${file_ua[1]}
 echo ... ${file_va[1]}
 echo ... ${file_hus[1]}
 echo
 
 
#########################################
####    ALL AVAILABLE tos FILES       ###
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
####    ALL AVAILABLE siconc FILES    ###
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
 file_orog_in=$path_in_fx'orog_fx_'$gcm_name'_'$exp_id'_'$gcm_mem'_gr.nc'
 echo ... Orography ... $file_orog_in
 file_sftlf_in=$path_in_fx'sftlf_fx_'$gcm_name'_'$exp_id'_'$gcm_mem'_gr.nc'
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


  # ---------------------------------
  # --- Extratct 1 year of 6hrLev ---
  # ---------------------------------
   for ((nn=1;nn<=num_file_ta;nn++)); do
    
    echo  ${fy_file_ta[$nn]}
    echo  ${ly_file_ta[$nn]}

    if [ $yy -ge ${fy_file_ta[$nn]} -a $yy -lt ${ly_file_ta[$nn]} ]; then

    echo ... found
    echo ... ${file_ta[$nn]}
    echo ... ${file_ua[$nn]}
    echo ... ${file_va[$nn]}
    echo ... ${file_hus[$nn]}


  # --- get one year ($yy)  ----
    #f_date_ta=$yy'-01-01T00:00:00'
    #l_date_ta=$yy'-12-31T24:00:00'
    [ $(($((yy+1)) % 5)) -eq 0 ] && l_date_ta=$((yy+1))'-01-01T01:00:00'
           
    f_date_ta=$yy'-12-31T00:00:00'
    l_date_ta=$((yy+1))'-01-01T01:00:00'
    
    #f_date_ta=$yy'-01-01T00:00:00'
    #l_date_ta=$yy'-01-31T24:00:00'
    
    #f_date_ta=$yy'-01-01T00:00:00'
    #l_date_ta=$yy'-01-01T01:00:00'
    
    echo
    echo ... 6hrLev first date to read'  '$f_date_ta 
    echo ... 6hrLev last date to read'   '$l_date_ta

        
  # --- ta ----
   bt="$(date +%s)"
   file_ta_yr=$path_out'ta_'$grb_name'_'$yy'.nc'
   [ -f $file_ta_yr ] && rm $file_ta_yr
   $cdo -L -invertlev -seldate,$f_date_ta,$l_date_ta ${file_ta[$((nn))]} $file_ta_yr

  # --- ps ---
   file_ps_yr=$path_out'ps_'$grb_name'_'$yy'.nc'
   [ -f $file_ps_yr ] && rm $file_ps_yr
   ncks -O -v ps $file_ta_yr $file_ps_yr

  # --- clean up ta ---
   ncks -O -v ta  $file_ta_yr $file_ta_yr
   
           
  # --- ua ----
   file_ua_yr=$path_out'ua_'$grb_name'_'$yy'.nc'
   [ -f $file_ua_yr ] && rm $file_ua_yr
   $cdo -L -invertlev -seldate,$f_date_ta,$l_date_ta ${file_ua[$((nn))]} $file_ua_yr
   ncks -O -v ua $file_ua_yr $file_ua_yr

  
  # --- va ----
   file_va_yr=$path_out'va_'$grb_name'_'$yy'.nc'
   [ -f $file_va_yr ] && rm $file_va_yr
   $cdo -L -invertlev -seldate,$f_date_ta,$l_date_ta ${file_va[$((nn))]} $file_va_yr
   ncks -O -v va $file_va_yr $file_va_yr

   
  # --- hus ----
   file_hus_yr=$path_out'hus_'$grb_name'_'$yy'.nc'
   [ -f $file_hus_yr ] && rm $file_hus_yr
   $cdo -L -invertlev -seldate,$f_date_ta,$l_date_ta ${file_hus[$((nn))]} $file_hus_yr
   ncks -O -v hus $file_hus_yr $file_hus_yr
   
   et="$(date +%s)"
   echo
   echo ... 'Extracting one year of 6hrLev DONE, time : ... ' "$(expr $et - $bt)" sec
    fi
done  # get 1 year of 6hrLev


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
   echo ... Ocean first date to extract'    '$f_date_tos 
   echo ... Ocean last date to extract'     '$l_date_tos
   echo
   
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
   file_tos_tmp1=$path_out'tmp1_tos_'$grb_name'_'$yy'.nc'
   file_tos_yr=$path_out'tos_'$grb_name'_'$yy'.nc'
   [ -f $file_tos_tmp0 ] && rm $file_tos_tmp0
   [ -f $file_tos_tmp1 ] && rm $file_tos_tmp1
   [ -f $file_tos_yr ] && rm $file_tos_yr

    if [ $yy -eq ${fy_file_tos[$nn]} ]; then
     echo ... FIRST YEAR tos ...
     $cdo -L -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn-1))]} $file_tos_tmp0
    fi
  
    $cdo -L cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn))]} $file_tos_tmp0

    if [ $yy -eq ${ly_file_tos[$nn]} ]; then
     echo ... LAST YEAR tos ...
     echo ... ${file_tos[$((nn))]}
     #$cdo -L -cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn+1))]} $file_tos_tmp0
     $cdo -L -cat -seldate,$f_date_tos,$l_date_tos ${file_tos[$((nn))]} $file_tos_tmp0   # December 2100
    fi
    
    case $yy in
      2100) echo ... 2100 tos ...
            echo ... $((yy-1)) ... $yy ... ${file_tos[$((nn))]} ... $file_tos_tmp1
            $cdo selyear,$((yy-1)),$yy ${file_tos[$((nn))]} $file_tos_tmp1
            num_time=`$cdo ntime $file_tos_tmp1`
            echo ... $num_time
            $cdo -L cat -seltimestep,$num_time -shifttime,1day $file_tos_tmp1 $file_tos_tmp0;;
    esac 
    
  # --- remap to atmospheric grid and interpolate daily to 6-hr  ---
    tmp1=$path_out/fil1.nc
    tmp2=$path_out/fil2.nc
    [ -f $tmp1 ] && rm $tmp1
    [ -f $tmp2 ] && rm $tmp2
        
    $cdo -L -seldate,$f_date_tos,$l_date_tos $file_tos_tmp0 $tmp2
    $cdo -L -inttime,$i_date,12:00:00,6hour $tmp2 $tmp1
    $cdo -L -addc,273.15 $tmp1 $tmp2
    ncatted -a coordinates,area,o,c,"nav_lat nav_lon" $tmp2  # fix for ssp245
    $cdo -L -remapdis,$grid_out -remapdis,$grid_out $tmp2 $file_tos_yr
    ncks -O -x -v area $file_tos_yr $file_tos_yr
    
    [ -f $file_tos_tmp0 ] && rm $file_tos_tmp0
    [ -f $tmp1 ] && rm $tmp1
    [ -f $tmp2 ] && rm $tmp2
    
 
  # ---------------
  # --- siconc ----
  # ---------------
    file_sic_tmp0=$path_out'tmp0_sic_'$grb_name'_'$yy'.nc'
    file_sic_tmp1=$path_out'tmp1_sic_'$grb_name'_'$yy'.nc'
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
     #$cdo -L -cat -seldate,$f_date_tos,$l_date_tos ${file_sic[$((nn+1))]} $file_sic_tmp0
      $cdo -L -cat -seldate,$f_date_tos,$l_date_tos ${file_sic[$((nn))]} $file_sic_tmp0    # 2100 December
    fi
    
    case $yy in
      2100) echo ... 2100 tos ...
            echo ... $((yy-1)) ... $yy ... ${file_sic[$((nn))]} ... $file_sic_tmp1
            $cdo selyear,$((yy-1)),$yy ${file_sic[$((nn))]} $file_sic_tmp1  
            num_time=`$cdo ntime $file_sic_tmp1`
            echo ... $num_time
            $cdo -L cat -seltimestep,$num_time -shifttime,1day $file_sic_tmp1 $file_sic_tmp0;;
    esac 
    

   # --- remap to atmospheric grid and interpolate daily to 6-hr  ---
    [ -f $tmp1 ] && rm $tmp1
    [ -f $tmp2 ] && rm $tmp2

    $cdo -L -seldate,$f_date_tos,$l_date_tos $file_sic_tmp0 $tmp2
    $cdo -L -inttime,$i_date,12:00:00,6hour $tmp2 $tmp1
    $cdo -L -divc,100 $tmp1 $tmp2
    ncatted -a coordinates,area,o,c,"nav_lat nav_lon" $tmp2  # fix for ssp245
    $cdo -L -remapdis,$grid_out -remapdis,$grid_out $tmp2 $file_sic_yr
    ncks -O -x -v area $file_sic_yr $file_sic_yr
    
    #$cdo -L -remapdis,$file_grid -remap,$file_grid,$file_weight_a2o $tmp1 $file_sic_yr
    [ -f $file_sic_tmp0 ] && rm $file_sic_tmp0 $tmp1
    [ -f $tmp1 ] && rm $tmp1
    [ -f $tmp2 ] && rm $tmp2
   
   et="$(date +%s)"
   echo
   echo ... 'Extracting one year of Ocean   DONE, time : ... ' "$(expr $et - $bt)" sec 
   fi
  done  # get 1 year of Ocean

echo
echo '---------------------------------------'
echo '--- Start processing 6hr time steps ---'
echo '---------------------------------------'
echo 

# --- number of time step (ta file) ---
  num_ta=`$cdo ntime $file_ta_yr`
  echo ... Year $yy ... time steps ... $num_ta

 for ((ss=1;ss<=$((num_ta));ss++)); do   # time step loop
   #for ((ss=1;ss<=2;ss++)); do   # time step loop
     #for ((ss=1;ss<=124;ss++)); do   # time step loop
       #for ((ss=1;ss<=400;ss++)); do   # time step loop
        #for ((ss=230;ss<=260;ss++)); do   # time step loop
        # for ((ss=115;ss<=265;ss++)); do   # time step loop

 # --- temporary file names ---
  file_out=$path_out$grb_name'_lbc_'$yy'_'$ss'.grb'
  file_tmp0=$path_out'tmp0_'$grb_name'_lbc_'$yy'_'$ss'.nc'
  file_tmp1=$path_out'tmp1_'$grb_name'_lbc_'$yy'_'$ss'.nc'
  file_tmp2=$path_out'tmp2_'$grb_name'_lbc_'$yy'_'$ss'.grb'

  bt="$(date +%s)"
  ########### PROCESSING TIME STEPS ####################

   # --- one time step for ta ---
    file_ta_tmp=$path_out'tmp_ta_'$yy'_'$ss'.grb'  
    [ -f $file_ta_tmp ] && rm $file_ta_tmp
    $cdo -L -f grb -setparam,130.128 -setzaxis,$file_zaxis -seltimestep,$ss $file_ta_yr $file_ta_tmp

   # --- date and time of one time step for ta ---
    aaa_date=$($cdo showdate $file_ta_tmp)
    aaa_date=${aaa_date// /} 
    aaa_time=$($cdo showtime $file_ta_tmp) 
    aaa_time=${aaa_time// /}
    aaa_time_in=$aaa_date'T'$aaa_time
    aaa_time_noon=$aaa_date'T12:00:00'
    aaa_time_ref=$aaa_date','$aaa_time
    aaa_mon_in=${aaa_date:5:2}
    aaa_mon_in=${aaa_mon_in/0/}
    echo
    echo ... TIME STEP ... $ss
    echo ... Date-Time ... $aaa_time_in 
    echo ... Ref. Time ... $aaa_time_ref 
    echo ... Month '    ...' $aaa_mon_in
    
    
   # --- one time step for ua ---
    file_ua_tmp=$path_out'tmp_ua_'$yy'_'$ss'.grb' 
    [ -f $file_ua_tmp ] && rm $file_ua_tmp
    $cdo -L -f grb -setparam,131.128 -setzaxis,$file_zaxis -seldate,$aaa_time_in $file_ua_yr $file_ua_tmp

   # --- one time step for va ---
    file_va_tmp=$path_out'tmp_va_'$yy'_'$ss'.grb' 
    [ -f $file_va_tmp ] && rm $file_va_tmp
    $cdo -L -f grb -setparam,132.128 -setzaxis,$file_zaxis -seldate,$aaa_time_in $file_va_yr $file_va_tmp  

   # --- one time step for hus ---
    file_hus_tmp=$path_out'tmp_hus_'$yy'_'$ss'.grb' 
    [ -f $file_hus_tmp ] && rm $file_hus_tmp
    $cdo -L -f grb -setparam,133.128 -setzaxis,$file_zaxis -seldate,$aaa_time_in $file_hus_yr $file_hus_tmp  

   # --- one time step for ps ---
    file_ps_tmp=$path_out'tmp_ps_'$yy'_'$ss'.grb' 
    [ -f $file_ps_tmp ] && rm $file_ps_tmp
    $cdo -L -f grb -setparam,134.128 -seldate,$aaa_time_in $file_ps_yr $file_ps_tmp

   # --- one time step for lnps ---
    file_lnps_tmp=$path_out'tmp_lnps_'$yy'_'$ss'.grb' 
    [ -f $file_lnps_tmp ] && rm $file_lnps_tmp
    $cdo -L -f grb -setparam,152.128 -ln -seldate,$aaa_time_in $file_ps_yr $file_lnps_tmp

   # --- one time step for tos ---
    file_tos_tmp=$path_out'tmp_tos_'$yy'_'$ss'.grb' 
    [ -f $file_tos_tmp ] && rm $file_tos_tmp
    $cdo -L -f grb -setparam,34.128 -seldate,$aaa_time_in $file_tos_yr $file_tos_tmp
    
   # --- one time step for sic ---
    file_sic_tmp=$path_out'tmp_sic_'$yy'_'$ss'.grb' 
    [ -f $file_sic_tmp ] && rm $file_sic_tmp
    $cdo -L -f grb -setparam,31.128 -seldate,$aaa_time_in $file_sic_yr $file_sic_tmp
    
   # ---    orography   ---
    file_orog_tmp=$path_out'tmp_orog_'$yy'_'$ss'.grb' 
    [ -f $file_orog_tmp ] && rm $file_orog_tmp
    $cdo -L -f grb -mulc,9.80665 -setparam,129.128 -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date $file_orog_in $file_orog_tmp

   # ---  land sea mask   ---
    file_sftlf_tmp=$path_out'tmp_sftlf_'$yy'_'$ss'.grb' 
    [ -f $file_sftlf_tmp ] && rm $file_sftlf_tmp
    $cdo -L -f grb -divc,100 -setparam,172.128 -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date $file_sftlf_in $file_sftlf_tmp

   # --- IC climatology ERA5  ---
    file_clim_tmp=$path_out'tmp_clim_'$yy$mm'_'$ss'.grb' 
    [ -f $file_clim_tmp ] && rm $file_clim_tmp
    $cdo -L -f grb -remapdis,$grid_out -settunits,hour -setreftime,$aaa_time_ref -settime,$aaa_time -setdate,$aaa_date -selmon,$aaa_mon_in $file_clim_in $file_clim_tmp


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
  grib_set -s timeRangeIndicator=0,centre=98 $file_out_tmp $file_out

 [ -f $file_out_tmp ] && rm $file_out_tmp
 [ -f $file_out_tmp1 ] && rm $file_out_tmp1

 

# --- delete temporaly files (one time step) ---
  rm ${path_out}tmp_*

  et="$(date +%s)"
  echo ... 'PROCESSING TIME for STEP '$ss ' ... ' "$(expr $et - $bt)" sec 
  done # time step

# --- delete temporaly files (one month) ---  
  rm ${path_out}*${yy}'.nc'

 done # year


 end_time="$(date +%s)"
 echo
 echo ... ELAPSED TOTAL TIME ALL :  "$(expr $end_time - $beg_time)" sec
 echo ... END



 


