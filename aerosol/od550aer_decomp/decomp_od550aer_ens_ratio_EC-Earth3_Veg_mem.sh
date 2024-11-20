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
 #var_in=(od550ss)
 var_in=(od550bc od550dust od550oa od550so4 od550ss)
 #var_in=(od550bc od550dust od550oa od550so4)
 
 #var_in=(od550bcrt od550dustrt od550oart od550so4rt od550ssrt)
 #var_in=(od550bc od550dust od550oa od550so4 od550ss)


# -----------------------
# ------ SIMULATIONS ----
# -----------------------
  run_in=(EC-Earth3-Veg_historical_r2i1p1f1_gr)
 
 
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
 grid_out_id='gr90N'

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

 fy_in=(1950)   # first year
 ly_in=(2014)   # last year

 #fy_in=(1850)   # first year
 #ly_in=(2005)   # last year

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
 
 if [ ${#gcm_name} -eq 0 -o ${#gcm_exp} -eq 0 -o ${#gcm_mem} -eq 0 -o ${#gcm_grid} -eq 0 ]; then
  echo ... some DRS elemets are not defined TERMINATED
  exit
 fi
 
 if [ ${gcm_exp} = 'historical' ]; then gcm_act='CMIP'; else gcm_act='ScenarioMIP'; fi
 
 case $gcm_name in
  CNRM-ESM2-1)   gcm_ins='CNRM-CERFACS';;
  EC-Earth3-Veg) gcm_ins='EC-Earth-Consortium';;
  CMCC-CM2-SR5)  gcm_ins='CMCC';;
 esac
  
 echo ... Act "  "  ...  $gcm_act
 echo ... Ins "  "  ...  $gcm_ins
 echo ... GCM "  "  ...  $gcm_name
 echo ... Exp "  " ... $gcm_exp
 echo ... Member ... $gcm_mem
 echo ... Grid " " ... $gcm_grid
 

# ---- VARIABLE LOOP --------
for ((var=0;var<=num_var-1;var++)); do   # variable loop


#------------------------------
# --- INPUT and OUTPUT PATH ---
#------------------------------
 path_ref_in="/home/rossby/data_lib/esgf/CMIP6/"
 #path_ref_in="/nobackup/rossby24/users/sm_grini/Data/CMIP6/data_esgf_tmp/CMIP6/"
 
 path_ref_out="/nobackup/rossby24/users/sm_grini/Data/CMIP6/aerosol/ens_7gcm/decomp/"
 path_ref_rat="/nobackup/rossby24/users/sm_grini/Data/CMIP6/aerosol/ens_7gcm/ratio/"

 #path_in=$path_ref_in"/"$gcm_act"/"$gcm_ins"/"$gcm_name"/"$gcm_exp"/"$gcm_mem"/"$table_in"/od550aer/"$gcm_grid"/latest/"
 path_in=$path_ref_in"/"$gcm_act"/"$gcm_ins"/"$gcm_name"/"$gcm_exp"/r1i1p1f1/"$table_in"/od550aer/"$gcm_grid"/latest/"  
 path_out=$path_ref_out$gcm_name"/"$gcm_mem"/"$gcm_exp"/"
 [ ! -d "$path_out" ] && mkdir -p $path_out
 
 path_rat_in=$path_ref_rat$gcm_exp"/"
 file_rat=$path_rat_in${var_in[$var]}"rt_AERmon_ENSMEAN_historical_r1i1p1f1_gr90N_195001-201412.nc"
 
# --- post-processing info ---
  echo
  echo ... SIMULATION    ' ...' ${run_in[$run]} '|' $gcm_name '|' $gcm_exp '|' $gcm_mem '|' $gcm_grid 
  echo ... INPUT PATH ' ...' $path_in
  echo ... OUTPUT PATH ...  $path_out
  echo ... RATIO PATH ' ...'  $path_rat_in
  echo
  echo ... File Ratio ... $file_rat
  
 case ${var_in[$var]} in
  od550bc) 
      long_name='Black Carbon Optical Thickness at 550nm'
      st_name='atmosphere_optical_thickness_due_to_black_carbon_ambient_aerosol'
      units='1';;
  od550dust) 
      long_name='Dust Optical Thickness at 550nm'
      st_name='atmosphere_optical_thickness_due_to_dust_ambient_aerosol_particles'
      units='1';;
  od550oa) 
      long_name='Total Organic Aerosol Optical Depth at 550nm'
      st_name='atmosphere_optical_thickness_due_to_particulate_organic_matter_ambient_aerosol_particles'
      units='1';;
  od550so4) 
      long_name='Sulfate Aerosol Optical Depth at 550nm'
      st_name='atmosphere_optical_thickness_due_to_sulfate_ambient_aerosol_particles'
      units='1';;
  od550ss) 
      long_name='Sea-Salt Aerosol Optical Depth at 550nm'
      st_name='atmosphere_optical_thickness_due_to_sea_salt_ambient_aerosol_particles'
      units='1';;
      *) echo ... ;;                     
             
esac


# --- YEAR POSITION in FILE NAMES ---
case $freq in
  mon) f_pos=-16
       l_pos=-9;;
  day) f_pos=-20
       l_pos=-11;;
esac


# ---- all files for simulation and variable ----
mask_file_in=$path_in$"od550aer"_$table_in'_'$gcm_name'_'$gcm_exp'_r1i1p1f1_'$gcm_grid'_'*'.nc'
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
 
 file_out=$path_out${var_in[$var]}'_'$table_out'_'$gcm_name'_'$gcm_exp'_'$gcm_mem'_'$grid_out_id'_'$fy_out'-'$ly_out'.nc'
 file_out_tmp0=$path_out'tmp0_'${var_in[$var]}'_'$table_out'_'$gcm_name'_'$gcm_exp'_'$gcm_mem'_'$grid_out_id'_'$fy_out'-'$ly_out'.nc'
 
 [ -f $file_out ] && rm $file_out
 [ -f $file_out_tmp0 ] && rm $file_out_tmp0

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
     cdo -L -f nc cat $remap,$grid_out -seldate,$f_date,$l_date ${file_in_all[$nn]} $file_out_tmp0
     
  fi
 done
 
if [ -f "$file_out_tmp0" ]; then

# ----------------------------
# ----  AOD Calculation   ----
# ----------------------------
 ncks -A -v ${var_in[$var]}'rt' $file_rat $file_out_tmp0
 ncap2 -O -s "${var_in[$var]}=od550aer*${var_in[$var]}rt;" $file_out_tmp0 $file_out
 ncks -O -x -v od550aer,${var_in[$var]}'rt' $file_out $file_out
 [ -f $file_out_tmp0 ] && rm $file_out_tmp0
 
# -----------------------
# ----  ATTRIBUTES   ----
# -----------------------
ncatted  -a standard_name,${var_in[$var]},o,c,"$st_name" \
         -a long_name,${var_in[$var]},o,c,"$long_name" \
         -a units,${var_in[$var]},o,c,"$units" -h $file_out   
 
# -------------------------------------
# ---  DATES in FILE NAME: YYYYMMDD ---
# -------------------------------------
 num_time=`$cdo ntime $file_out`
 f_date=`$cdo showdate -seltimestep,1 $file_out`; f_date=${f_date// /}; f_date=${f_date//-/}
 f_time=`$cdo showtime -seltimestep,1 $file_out`; f_time=${f_time:1:2}
 l_date=`$cdo showdate -seltimestep,$num_time $file_out`; l_date=${l_date// /}; l_date=${l_date//-/}
 l_time=`$cdo showtime -seltimestep,$num_time $file_out`; l_time=${l_time:1:2}

 case $freq in
   mon) file_cmip=$path_out${var_in[$var]}'_'$table_out'_'$gcm_name'_'$gcm_exp'_'$gcm_mem'_'$grid_out_id'_'${f_date:0:6}'-'${l_date:0:6}'.nc';;
 esac

 echo
 echo ... FINAL FILE   ' '... $file_cmip
 echo
 
 nccopy -k 4 -d 1 -s $file_out $file_cmip
 [ -f $file_out ] && rm $file_out
 
# -------------------------
# --- GLOBAL ATRIBUTES  ---
# -------------------------
 ncatted -a description,${var_in[$var]},d,, \
         -a creation_date,global,o,c,"$( date +%Y'-'%m'-'%d'-T'%T'Z')" \
         -a tracking_id,global,o,c,`/home/rossby/host/${NSC_RESOURCE_NAME}/bin/uuid -v 4` -h $file_cmip
         

# --- GLOBAL ATTRIBUTES ----
 #ncks -A -x ${file_in_all[$((nn-1))] } $file_cmip
 ncatted -a history,global,d,, -h $file_cmip
 ncatted -a CDI,global,d,, -h $file_cmip
 ncatted -a CDO,global,d,, -h $file_cmip
 ncatted -a NCO,global,d,, -h $file_cmip
 ncatted -a history_of_appended_files,global,d,, -h $file_cmip
 
 

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




