#!/bin/bash
#SBATCH -N 1
#SBATCH -t 100:00:00 

#######################################################################
####                                                               ####
####         Transient Aerosol Forcing for HCLIM (CMIP6)           ####
####               Ratios between 5 aerosol types                  #### 
####         od550bc, od550dust, od550oa, od550ss, od550so4        #### 
####                            and                                #### 
####                          od550aer                             ####
####                        CMIP6 format                           #### 
####                                                               ####    
#######################################################################


#--------------------------
#-----  VARIABLES   -------
#--------------------------
 #var_in=(od550bcrt)
 var_in=(od550bcrt od550dustrt od550oart od550so4rt od550ssrt)


# -----------------------
# ------ SIMULATIONS ----
# -----------------------
 #run_in=(ENSMEAN_historical_r1i1p1f1_gr90N)
 #run_in=(ENSMEAN_ssp126_r1i1p1f1_gr90N)
 #run_in=(ENSMEAN_ssp370_r1i1p1f1_gr90N)
  run_in=(ENSMEAN_ssp585_r1i1p1f1_gr90N)
 
# -----------------------
# -----  FREQUENCY   ----
# -----------------------
  freq=mon


# -----------------------
# ------   TABLE     ----
# ----------------------- 
table_in=AERmon
table_out=AERmon 


#-----------------------------
# ---    OUTPUT GRID       ---
#-----------------------------
 grid_out=r360x181  
 

# -------------------------
# --- REMAPPING METHOD  ---
# -------------------------
 remap='-remapbil' 
 
  

#----------------------------  
#--- FIRST and LAST YEARS ---
#----------------------------
 #fy_in=(1951 2001)   # first year
 #ly_in=(2000 2005)   # last year

 #fy_in=(2006 2011)   # first year
 #ly_in=(2010 2100)   # last year

 #fy_in=(1950)   # first year
 #ly_in=(2014)   # last year

 fy_in=(2015)   # first year
 ly_in=(2100)   # last year

 #fy_in=(2000)   # first year
 #ly_in=(2000)   # last year

#-------------------------------------------  
# ---- NUMBER OF YEARS in OUTPUT FILES -----
#-------------------------------------------  
 sy_in=(0)

# -----------------
# --- META INFO ---
# -----------------
 path_grid='/nobackup/rossby20/sm_grini/Data/FX/grid_new/'
 path_meta=$CORDEX_META          # path to meta files
 ref_time='1850-01-01,00:00'     # reference time
 cdo='cdo -s'
 

# ----------------------
# --- OUTPUT DOMAIN  ---
# ----------------------
 domain_out='GLB-1deg'


# --- GRIDS ---
# case $domain_out in
#   GLB-2deg) 
#        file_grid=$path_grid'GLB-2_lon180_lat89_reg_coor.grid'
#        echo ... GLOBAL 2deg regular grid ... $file_grid ;;
#          *)  
#        echo ... 'Output domain is not defined TERMINATED'
#        exit;;
# esac


# --- Number of variables, runs etc..  ---
 num_var=${#var_in[@]}      # number of variables 
 num_run=${#run_in[@]}      # number of simulations
 num_freq=${#freq_in[@]}
 num_fy=${#fy_in[@]}       
 num_ly=${#ly_in[@]}       
 num_sy=${#sy_in[@]}

# --- check if fy_in, ly_in and sy_in have the same dimension ---
if [ $num_fy -ne $num_ly -o $num_fy -ne $num_sy ]; then
 echo ... fy_in, ly_in and sy_in have different dimensions .... TERMINATED
 exit
fi

# --- does output path defined -----
if [ ${#path_out} -eq 0 ]; then
 po=no
fi


#-------------------------------
#------  MAIN BLOCK  -----------
#-------------------------------
echo
echo ... START  ...
echo
beg_time="$(date +%s)"


# ---- SIMULATION LOOP ------  
for ((run=0;run<=num_run-1;run++)); do    # simulation loop


# --- read simulation info (simulation id) ---
 unset run_id
 run_id=${run_in[$run]}
 echo ... RUN ID  ... $run_id
 
 run_id_drs=($(echo $run_id | tr "_" "\n"))
 gcm_name=${run_id_drs[0]}
 gcm_exp=${run_id_drs[1]}
 gcm_mem=${run_id_drs[2]}
 gcm_grid=${run_id_drs[3]}
 
 echo ... GCM "  "  ...  $gcm_name
 echo ... Exp "  " ... $gcm_exp
 echo ... Member ... $gcm_mem
 echo ... Grid " " ... $gcm_grid
    
 if [ ${#gcm_name} -eq 0 -o ${#gcm_exp} -eq 0 -o ${#gcm_mem} -eq 0 -o ${#gcm_grid} -eq 0 ]; then
  echo ... some DRS elemets are not defined TERMINATED
  exit
 fi
 

#------------------------------
# --- INPUT and OUTPUT PATH ---
#------------------------------
 path_ref_in="/nobackup/rossby27/users/sm_petli/cmip6_gcm_aerosol_ens_mean/"
 path_ref_out="/nobackup/rossby24/users/sm_grini/Data/CMIP6/aerosol/ens_7gcm/ratio/"

 path_in=$path_ref_in"/"$gcm_exp"/"
 path_out=$path_ref_out"/"$gcm_exp"/"
 [ ! -d "$path_out" ] && mkdir -p $path_out
 
# --- post-processing info ---
  echo
  echo ... SIMULATION    ' ...' ${run_in[$run]} '|' $gcm_name '|' $gcm_exp '|' $gcm_mem '|' $gcm_grid 
  echo ... INPUT PATH ' ...' $path_in
  echo ... OUTPUT PATH ...  $path_out
  

# ---- VARIABLE LOOP --------
for ((var=0;var<=num_var-1;var++)); do   # variable loop

 case ${var_in[$var]} in
  od550bcrt) 
      long_name='ratio between od550bc (Black Carbon Optical Thickness at 550nm) and od550aer'
      st_name='atmosphere_optical_thickness_due_to_black_carbon_ambient_aerosol_ratio_od550aer'
      units='1';;
  od550dustrt) 
      long_name='ratio between od550dust (Dust Optical Thickness at 550nm) and od550aer'
      st_name='atmosphere_optical_thickness_due_to_dust_ambient_aerosol_particles_ratio_od550aer'
      units='1';;
  od550oart) 
      long_name='ratio between od550oa (Total Organic Aerosol Optical Depth at 550nm) and od550aer'
      st_name='atmosphere_optical_thickness_due_to_particulate_organic_matter_ambient_aerosol_particles_ratio_od550aer'
      units='1';;
  od550so4rt) 
      long_name='ratio between od550so4 (Sulfate Aerosol Optical Depth at 550nm) and od550aer'
      st_name='atmosphere_optical_thickness_due_to_sulfate_ambient_aerosol_particles_ratio_od550aer'
      units='1';;
  od550ssrt) 
      long_name='ratio between od550ss (Sea-Salt Aerosol Optical Depth at 550nm) and od550aer'
      st_name='atmosphere_optical_thickness_due_to_sea_salt_ambient_aerosol_particles_ratio_od550aer'
      units='1';;                     
             
esac

# --- YEAR POSITION in FILE NAMES ---
case $freq in
  mon) f_pos=-16
       l_pos=-9;;
  day) f_pos=-20
       l_pos=-11;;
esac


# ---- all files for simulation and variable ----
mask_file_in=$path_in${var_in[$var]}_$table_in'_'$gcm_name'_'$gcm_exp'_'$gcm_grid'_'*'.nc'
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

# ---first and last year in output file ---
 fy_out=$((fy+(ff-1)*sy)) # first year in output file
 ly_out=$((fy_out+sy-1))  #  last year in output file

 file_out=$path_out${var_in[$var]}_$table_out'_'$gcm_name'_'$gcm_exp'_'$gcm_mem'_'$gcm_grid'_'$fy_out'-'$ly_out'.nc'
 [ -f $file_out ] && rm $file_out

 echo ... VARIABLE'    ...' ${var_in[$var]} 
 echo ... SIMULATION'  ... ' ${run_in[$run]}':' $gcm_name '|' $gcm_exp '|' $gcm_mem '|'$gcm_grid'|' $fy_out'-'$ly_out '|'
 echo ... OUTPUT FILE ... $file_out
 echo
 
 
# --- select only given years ---
f_date=$fy_out'-01-01T00:00:00'
l_date=$ly_out'-12-31T23:59:00'

echo ... $f_date
echo ... $l_date
echo

 count=0
 for ((nn=0;nn<=$((num_file_in-1));nn++)); do

 if [ ${fy_file[$nn]} -ge $fy_out -a ${fy_file[$nn]} -le $ly_out ] || \
    [ ${ly_file[$nn]} -ge $fy_out -a ${ly_file[$nn]} -le $ly_out ] || \
    [ $fy_out -ge ${fy_file[$nn]} -a $fy_out -le ${ly_file[$nn]} ]; then

     echo ... now processing ... ${file_in_all[$nn] }
     cdo -f nc cat -settbounds,'month' -setmissval,1e20 -setreftime,1850-01-01,00:00 -seldate,$f_date,$l_date ${file_in_all[$nn]} $file_out
 
  fi
 done


if [ -f "$file_out" ]; then

# ---------------------
# ----     TIME    ----
# ---------------------
  ncap2 -h -O -s 'time=( (time_bnds(:,0)+time_bnds(:,1))/2. )' $file_out $file_out
  
# -----------------------
# ----  ATTRIBUTES   ----
# -----------------------
ncatted  -a standard_name,${var_in[$var]},o,c,"$st_name" \
         -a long_name,${var_in[$var]},o,c,"$long_name" \
         -a units,${var_in[$var]},o,c,"$units" \
         -a cell_methods,${var_in[$var]},o,c,"area: time: mean" -h $file_out  


# -------------------------------------
# ---  DATES in FILE NAME: YYYYMMDD ---
# -------------------------------------
 num_time=`$cdo ntime $file_out`
 f_date=`$cdo showdate -seltimestep,1 $file_out`; f_date=${f_date// /}; f_date=${f_date//-/}
 f_time=`$cdo showtime -seltimestep,1 $file_out`; f_time=${f_time:1:2}
 l_date=`$cdo showdate -seltimestep,$num_time $file_out`; l_date=${l_date// /}; l_date=${l_date//-/}
 l_time=`$cdo showtime -seltimestep,$num_time $file_out`; l_time=${l_time:1:2}

 case $freq in
  day) file_cmip=$path_out${var_in[$var]}'_'$table_out'_'$gcm_name'-'$domain_out'_'$experiment_id'_'$gcm_version_id'_'${f_date}'_'${l_date}'.nc';;
  mon) file_cmip=$path_out${var_in[$var]}'_'$table_out'_'$gcm_name'_'$gcm_exp'_'$gcm_mem'_'$gcm_grid'_'${f_date:0:6}'-'${l_date:0:6}'.nc';;
 esac

 echo
 echo ... FINAL FILE   ' '... $file_cmip
 echo
 
 nccopy -k 4 -d 1 -s $file_out $file_cmip
 [ -f $file_out ] && rm $file_out
 
# -------------------------
# --- GLOBAL ATRIBUTES  ---
# -------------------------
 ncatted -a creation_date,global,o,c,"$( date +%Y'-'%m'-'%d'-T'%T'Z')" \
         -a frequency,global,o,c,"$freq" \
         -a experiment_id,global,o,c,"$gcm_exp" \
         -a mip_era,global,o,c,"CMIP6" \
         -a tracking_id,global,o,c,`/home/rossby/host/${NSC_RESOURCE_NAME}/bin/uuid -v 4` -h $file_cmip
         

# --- GLOBAL ATTRIBUTES ----
 #ncks -A -x ${file_in_all[$((nn-1))] } $file_cmip
 ncatted -a history,global,d,, -h $file_cmip
 ncatted -a CDI,global,d,, -h $file_cmip
 ncatted -a CDO,global,d,, -h $file_cmip
 ncatted -a NCO,global,d,, -h $file_cmip

else
    echo ... OUTPUT FILE does not exist $file_tmp0
fi # if file_out exists

   done  # output file loop
  done # file loop
 done  # variable loop
done  # simulation loop

end_time="$(date +%s)"
echo
echo ELAPSED TIME: "$(expr $end_time - $beg_time)" sec
echo
echo "END"




