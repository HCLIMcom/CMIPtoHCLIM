#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00 

#######################################################################
####                                                               ####
####               Transient Aerosol Forcing for HCLIM             ####
####                    Decompose od550aer to 5 types              #### 
####           od550bc, od550dust, od550oa+od550ss, od550so4       ####
####                 netcdf to cams ascii format                   #### 
####                                                               ####    
#######################################################################


# -----------------------
# ------ SIMULATIONS ----
# -----------------------
 #run_in=(CNRM-ESM2-1_historical_r1i1p1f2_gr90N)
 #run_in=(MIROC6_historical_r1i1p1f1_gn)

 #run_in=(CNRM-ESM2-1_ssp585_r1i1p1f2_gr)
 #run_in=(NorESM2-MM_historical_r1i1p1f1_gn)
 
 #run_in=(EC-Earth3-Veg_historical_r1i1p1f1_gr90N)
 #run_in=(EC-Earth3-Veg_ssp126_r1i1p1f1_gr90N)
 #run_in=(EC-Earth3-Veg_ssp370_r1i1p1f1_gr90N)
 #run_in=(EC-Earth3-Veg_ssp585_r1i1p1f1_gr90N)
 
 #run_in=(MPI-ESM1-2-HR_historical_r1i1p1f1_gr90N)
 #run_in=(MPI-ESM1-2-HR_ssp126_r1i1p1f1_gr90N)
 run_in=(MPI-ESM1-2-HR_ssp370_r1i1p1f1_gr90N)
  

# -------------------------
# --- REMAPPING METHOD  ---
# -------------------------
 remap='-remapbil'  ### default ###     
 
 ###remap='-remapbic'
 ###remap='-remapdis'  
 ###remap='-remapcon'   

# ----------------------------  
# --- FIRST and LAST YEARS ---
# ----------------------------
 #fy_in=(1950)   # first year
 #ly_in=(2014)   # last year

 fy_in=(2015)   # first year
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
 cdo='cdo -s --no_warnings'

#-----------------------------
# ---    OUTPUT GRID       ---
#-----------------------------
 grid_out=r360x181  


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

 if [ ${gcm_exp} = 'historical' ]; then gcm_exp_out='hist'; else gcm_exp_out=${gcm_exp}; fi


#------------------------------
# --- INPUT and OUTPUT PATH ---
#------------------------------
 path_ref_in="/nobackup/rossby24/users/sm_grini/Data/CMIP6/aerosol/ens_7gcm/decomp/"
 path_ref_out="/nobackup/rossby27/proj/rossby/boundary/CMIP6/"
 
 path_ref_out="/nobackup/rossby24/users/sm_grini/Data/CMIP6/aerosol/ens_7gcm/decomp_hclim/"
  
 path_in=$path_ref_in$gcm_name"/"$gcm_mem"/"$gcm_exp"/"
 #path_out=$path_ref_out$gcm_name"/"$gcm_mem"/"$gcm_exp"/aero/"
 path_out=$path_ref_out$gcm_name"/"$gcm_mem"/"$gcm_exp"/"
 [ ! -d "$path_out" ] && mkdir -p $path_out
 
 #/nobackup/rossby27/proj/rossby/boundary/CMIP6/EC-Earth3-Veg/r1i1p1f1/historical/aero
 

# --- post-processing info ---
 echo
 echo ... SIMULATION    '  ...' ${run_in[$run]} '|' $gcm_name '|' $gcm_exp '|' $gcm_mem '|' $gcm_grid
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
echo ...  AVAILABLE INPUT FILES:
num_file_in=0
for f in $flist; do
  fy_file[$num_file_in]=${f:(f_pos):4}
  ly_file[$num_file_in]=${f:(l_pos):4}
  file_in_all[$num_file_in]=$f
  echo ...  ${file_in_all[$num_file_in]}
  #echo ... ${fy_file[$num_file_in]}
  #echo ... ${ly_file[$num_file_in]}
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
  
# ---first and last year in output file ---
 fy_out=$((fy+(ff-1)*sy)) # first year in output file
 ly_out=$((fy_out+sy-1))  #  last year in output file
 
 file_out=$path_out'aero_'$gcm_name'_'$gcm_mem'_'$gcm_exp_out'_'$fy_out$mm'.txt'
 file_tmp0=$path_out'tmp0_aero_'$gcm_name'_'$gcm_mem'_'$gcm_exp_out'_'$fy_out$mm'.nc'

 [ -f $file_out ] && rm $file_out
 [ -f $file_tmp0 ] && rm $file_tmp0
 
 echo ... SIMULATION ' ... ' ${run_in[$run]}':' $gcm_name '|' $gcm_exp '|' $gcm_mem '|' $fy_out'-'$ly_out '|'
 echo ... OUTPUT FILE ... $file_out
 echo ... OUTPUT TMP0 ... $file_tmp0
 echo ... OUTPUT YEAR ... $fy_out
 echo ... GRID OUT '   ...' $grid_out
 echo
 

 for ((nn=0;nn<=$((num_file_in-1));nn++)); do

 if [ ${fy_file[$nn]} -ge $fy_out -a ${fy_file[$nn]} -le $ly_out ] || \
    [ ${ly_file[$nn]} -ge $fy_out -a ${ly_file[$nn]} -le $ly_out ] || \
    [ $fy_out -ge ${fy_file[$nn]} -a $fy_out -le ${ly_file[$nn]} ]; then

# --- od550ss ---
     file_ss=${file_in_all[$nn] }
     echo ... now processing ... $file_ss
     $cdo -L -invertlat -selyear,$fy_out -selmon,$mm $file_ss $file_tmp0
     
     lats=`ncks -s "%8.3f\n" -C -h -H -v lat $file_tmp0`
     lats_arr=($lats)
     lats_arr_int=${lats_arr[*]%.*}
     num_lat=${#lats_arr[@]}
 
     lons=`ncks -s "%8.3f\n" -C -h -H -v lon $file_tmp0`
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
     
     
   
# --- od550oa + od550so4 ---      
     file_oa=${file_ss/'od550ss_'/'od550oa_'}
     file_so4=${file_ss/'od550ss_'/'od550so4_'}
     echo ... now processing ... $file_oa
     echo ... now processing ... $file_so4
     $cdo -L -invertlat -selyear,$fy_out -selmon,$mm -add $file_oa $file_so4 $file_tmp0
          
     ncks -s "%12.10f\n" -C -h -H -v od550oa $file_tmp0 >> $file_out
     sed -i '/^[[:space:]]*$/d' $file_out
     [ -f $file_tmp0 ] && rm $file_tmp0

     
# --- od550bc ---    
     file_bc=${file_ss/'od550ss_'/'od550bc_'}
     echo ... now processing ... $file_bc
     $cdo -L -invertlat -selyear,$fy_out -selmon,$mm ${file_bc} $file_tmp0
          
     ncks -s "%12.10f\n" -C -h -H -v od550bc $file_tmp0 >> $file_out
     sed -i '/^[[:space:]]*$/d' $file_out
     [ -f $file_tmp0 ] && rm $file_tmp0
          
     
# --- od550dust ---      
     file_dust=${file_ss/'od550ss_'/'od550dust_'}
     echo ... now processing ... $file_dust
     $cdo -L -invertlat -selyear,$fy_out -selmon,$mm ${file_dust} $file_tmp0
     
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




