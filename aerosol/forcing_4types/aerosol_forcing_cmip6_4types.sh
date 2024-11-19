#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00 

#######################################################################
####                                                               ####
####               Transient Aerosol Forcing for HCLIM             ####
####                        CMIP6 4 types                          #### 
####                   netcdf tocams ascii format                  #### 
####              od550bc, od550dust, od550oa, od550ss             ####
####                                                               ####    
#######################################################################


# -----------------------
# ------ SIMULATIONS ----
# -----------------------
 #run_in=(CNRM-ESM2-1_historical_r1i1p1f2_gr)
 run_in=(CNRM-ESM2-1_ssp585_r1i1p1f2_gr)
 #run_in=(NorESM2-MM_historical_r1i1p1f1_gn)
 

# -------------------------
# --- REMAPPING METHOD  ---
# -------------------------
 #remap='-remapcon'   
  remap='-remapbic'   
 #remap='-remapdis'  

# ----------------------------  
# --- FIRST and LAST YEARS ---
# ----------------------------
 fy_in=(2090)   # first year
 ly_in=(2100)   # last year

 
# -------------------------------------------  
# ---- NUMBER OF YEARS in OUTPUT FILES -----
# -------------------------------------------  
 sy_in=(1)

# -----------------
# --- META INFO ---
# -----------------
 path_grid='/nobackup/rossby27/users/sm_grini/rossby20/Data/FX/grid_new/'
 table_in=AERmon
 table_out=AERmon
 freq=mon
 cdo='cdo -s'

# ----------------------
# --- OUTPUT DOMAIN  ---
# ----------------------
 #domain_out='GLB-2deg'


# --- GRIDS ---
 #case $domain_out in
 #  GLB-2deg) 
 #       file_grid=$path_grid'GLB-2_lon180_lat89_reg_coor.grid'
 #       echo ... GLOBAL 2deg regular grid ... $file_grid ;;
 #         *)  
 #       echo ... 'Output domain is not defined TERMINATED'
 #       exit;;
 #esac



# --- Number of runs etc.. ---
 num_run=${#run_in[@]}      # number of simulations
 num_fy=${#fy_in[@]}       
 num_ly=${#ly_in[@]}       
 num_sy=${#sy_in[@]}

# --- check if fy_in, ly_in and sy_in have the same dimension ---
 if [ $num_fy -ne $num_ly -o $num_fy -ne $num_sy ]; then
  echo ... fy_in, ly_in and sy_in have different dimensions .... TERMINATED
  exit
 fi


#-------------------------------
#------  MAIN BLOCK  -----------
#-------------------------------
 echo
 echo ... START nc2ascii CONVERSION ...
 echo
 beg_time="$(date +%s)"


# ---- SIMULATION LOOP ------  
for ((run=0;run<=num_run-1;run++)); do    # simulation loop

# --- read simulation info (simulation id) ---
 unset run_id
 run_id=${run_in[$run]}
 echo ... RUN ID ... $run_id
 
 run_id_drs=($(echo $run_id | tr "_" "\n"))
 gcm_name=${run_id_drs[0]}
 gcm_exp=${run_id_drs[1]}
 gcm_mem=${run_id_drs[2]}
 gcm_grid=${run_id_drs[3]}
   
 if [ ${#gcm_name} -eq 0 -o ${#gcm_exp} -eq 0 -o ${#gcm_mem} -eq 0 -o ${#gcm_grid} -eq 0 ]; then
  echo ... some DRS elemets are not defined TERMINATED
  exit
 fi

#-----------------------------
# ---    OUTPUT GRID       ---
#-----------------------------
#case $gcm_name in
#  CNRM-ESM2-1) grid_out=r256x128;;
#   *)  
#        echo ... 'GCM is not defined TERMINATED'
#        exit;;
#esac

grid_out=r360x181  

#------------------------------
# --- INPUT and OUTPUT PATH ---
#------------------------------
 path_ref="/nobackup/rossby24/users/sm_grini/Data/CMIP6/data/"
 path_in=$path_ref$gcm_name'/'$gcm_exp'/'$gcm_mem'/input/'$freq'/'
 #path_out="/nobackup/rossby26/users/sm_grini/TEMP/20220521_camsaod/"

 #path_out="/nobackup/rossby26/users/sm_grini/TEMP/20220531_cnrm_aerosol/historical/"
 path_out="/nobackup/rossby26/users/sm_grini/TEMP/20220531_cnrm_aerosol/ssp585/"


 #path_out=$path_ref$gcm_name'/'$experiment_id'/'$gcm_version_id'/remap/'$domain_out'/'$freq'/'
 #[ ! -d "$path_out" ] && mkdir -p $path_out

# --- post-processing info ---
 echo
 echo ... SIMULATION    ' ...' ${run_in[$run]} '|' $domain '|' $gcm_name '|' $gcm_exp '|' $gcm_mem '|' $gcm_grid
 echo ... INPUT PATH ' ...' $path_in
 echo ... OUTPUT PATH ...  $path_out
  

# --- YEAR POSITION in FILE NAMES ---
case $freq in
  mon) f_pos=-16
       l_pos=-9
       table_in=AERmon
       table_out=AERmon;;
  day) f_pos=-20
       l_pos=-11
       table_in=day
       table_out=day;;
esac

# ---- all files per simulation and variable ----
 mask_file_in=$path_in'od550ss'_$table_in'_'$gcm_name'_'$gcm_exp'_'$gcm_mem'_'$gcm_grid'*.nc'
 flist=`ls $mask_file_in`

# --- first and last year in file names ---
echo
echo   AVAILABLE INPUT FILES:
num_file_in=0
for f in $flist; do
  fy_file[$num_file_in]=${f:(f_pos):4}
  ly_file[$num_file_in]=${f:(l_pos):4}
  file_in_all[$num_file_in]=$f
  echo ...  ${file_in_all[$num_file_in]}
  echo ... ${fy_file[$num_file_in]}
  echo ... ${ly_file[$num_file_in]}
  num_file_in=$((num_file_in+1))
done
echo
echo


# --- YEAR LOOP ---
for ((pp=0;pp<num_fy;pp++)); do

 fy=${fy_in[$pp]} 
 ly=${ly_in[$pp]}
 sy=${sy_in[$pp]}

 year_p=$(($ly - $fy + 1))  # number of years
 
# --- number of output files ----
if [ $sy -eq 0 ]; then
  sy=$year_p
  file_p=1
else
  file_p=$((year_p/sy))       
  if [ $((year_p%sy)) -ne 0 ]; then
   file_p=$((file_p+1))
  fi
fi

# ----- OUTPUT FILE LOOP -----
for ((ff=1;ff<=file_p;ff++)); do 
 for mm in 01 02 03 04 05 06 07 08 09 10 11 12; do
  #for mm in 01; do

# ---first and last year in output file ---
 fy_out=$((fy+(ff-1)*sy)) # first year in output file
 ly_out=$((fy_out+sy-1))  #  last year in output file
 
 #file_out=$path_out${var_in[$var]}_$table_out'_'$gcm_name'-'$grid_out'_'$experiment_id'_'$gcm_version_id'_'$fy_out'-'$ly_out'.nc'
 #file_out=$path_out'aero.camsaod.m'$mm'_GL'
  file_out=$path_out'aero.'$gcm_name'.'$gcm_exp'.'$gcm_mem'.'$fy_out$mm'.txt'
  [ -f $file_out ] && rm $file_out

 #file_tmp0=$path_out'tmp0_aero.camsaod.m'$mm'_GL.nc'
  file_tmp0=$path_out'tmp0_aero.'$gcm_name'.'$gcm_exp'.'$gcm_mem'.'$fy_out$mm'.nc'
  [ -f $file_tmp0 ] && rm $file_tmp0
 
 echo ... SIMULATION' ... ' ${run_in[$run]}':' $gcm_name '|' $gcm_exp '|' $gcm_mem '|' $fy_out'-'$ly_out '|'
 echo ... OUTPUT FILE ... $file_out
 echo ... OUTPUT TMP0 ... $file_tmp0
 echo ... OUTPUT YEAR ... $fy_out
 #echo ... GRID OUT ... $grid_out
 echo

 
 count=0
 for ((nn=0;nn<=$((num_file_in-1));nn++)); do

 if [ ${fy_file[$nn]} -ge $fy_out -a ${fy_file[$nn]} -le $ly_out ] || \
    [ ${ly_file[$nn]} -ge $fy_out -a ${ly_file[$nn]} -le $ly_out ] || \
    [ $fy_out -ge ${fy_file[$nn]} -a $fy_out -le ${ly_file[$nn]} ]; then

# --- od550ss ---
     file_ss=${file_in_all[$nn] }
     echo ... now processing ... $file_ss
     $cdo -L -invertlat $remap,$grid_out -selyear,$fy_out -selmon,$mm $file_ss $file_tmp0
     
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm $remap,$file_grid $file_ss $file_tmp0
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm $file_ss $file_tmp0
          
     lats=`ncks -s "%f\n" -C -h -H -v lat $file_tmp0`
     lats_arr=($lats)
     lats_arr_int=${lats_arr[*]%.*}
     num_lat=${#lats_arr[@]}
 
     lons=`ncks -s "%f\n" -C -h -H -v lon $file_tmp0`
     lons_arr=($lons)
     lons_arr_int=${lons_arr[*]%.*}
     num_lon=${#lons_arr[@]}
     
     echo 'nlat '$num_lat > $file_out
     #echo ${lats_arr_int[*]} >> $file_out
     echo ${lats_arr[*]} >> $file_out
     
     echo 'nlon '$num_lon >> $file_out
     #echo ${lons_arr_int[*]} >> $file_out
     echo ${lons_arr[*]} >> $file_out
     
     ncks -s "%12.10f\n" -C -h -H -v od550ss $file_tmp0 >> $file_out
     sed -i '/^[[:space:]]*$/d' $file_out
     [ -f $file_tmp0 ] && rm $file_tmp0
          
     
# --- od550oa ---      
     file_oa=${file_ss/'od550ss_'/'od550oa_'}
     echo ... now processing ... $file_oa
     $cdo -L -invertlat $remap,$grid_out -selyear,$fy_out -selmon,$mm ${file_oa} $file_tmp0
     
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm $remap,$file_grid ${file_oa} $file_tmp0
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm ${file_oa} $file_tmp0
     
     ncks -s "%12.10f\n" -C -h -H -v od550oa $file_tmp0 >> $file_out
     sed -i '/^[[:space:]]*$/d' $file_out
     [ -f $file_tmp0 ] && rm $file_tmp0


# --- od550bc ---    
     file_bc=${file_ss/'od550ss_'/'od550bc_'}
     echo ... now processing ... $file_bc
     $cdo -L -invertlat $remap,$grid_out -selyear,$fy_out -selmon,$mm ${file_bc} $file_tmp0
     
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm $remap,$file_grid ${file_bc} $file_tmp0
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm ${file_bc} $file_tmp0
     
     ncks -s "%12.10f\n" -C -h -H -v od550bc $file_tmp0 >> $file_out
     sed -i '/^[[:space:]]*$/d' $file_out
     [ -f $file_tmp0 ] && rm $file_tmp0


# --- od550dust ---      
     file_dust=${file_ss/'od550ss_'/'od550dust_'}
     echo ... now processing ... $file_dust
     $cdo -L -invertlat $remap,$grid_out -selyear,$fy_out -selmon,$mm ${file_dust} $file_tmp0
          
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm $remap,$file_grid ${file_dust} $file_tmp0
     #$cdo -L -invertlat -selyear,$fy_out -selmon,$mm ${file_dust} $file_tmp0
     
     ncks -s "%12.10f\n" -C -h -H -v od550dust $file_tmp0 >> $file_out
     sed -i '/^[[:space:]]*$/d' $file_out
     [ -f $file_tmp0 ] && rm $file_tmp0
     echo
     echo 
      
  fi
 done
 

    done  # month loop
   done  # output file loop
  done  # file loop
 done  # simulation loop

end_time="$(date +%s)"
echo
echo ELAPSED TIME: "$(expr $end_time - $beg_time)" sec
echo
echo "END"




