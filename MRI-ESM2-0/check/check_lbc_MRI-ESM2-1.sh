#!/bin/bash
#SBATCH -N 1
#SBATCH -N 1
#SBATCH -t 10:00:00


#######################################################################
####                                                               ####
####                   check CMIP6 LBC files                       ####
####                                                               ####  
#######################################################################

#-----------------------------
# ---     EXPERIMENT       ---
#-----------------------------
 #grb_name='MRI-ESM2-0_r1i1p1f1_hist'
  grb_name='MRI-ESM2-0_r1i1p1f1_ssp585'
#-----------------------------
# --- FIRST and LAST YEARS ---
#-----------------------------
 fy=2015   # first year
 ly=2072   # last year

#-----------------------------
# ---     CALENDAR         ---
#-----------------------------
 cal='standard'

# -----------------------------
# ---INPUT and OUTPUT PATHS ---
#------------------------------
 #path_in='/nobackup/rossby24/proj/rossby/boundary/CMIP6/MRI-ESM2-0/r1i1p1f1/historical/grb/'
 path_in='/nobackup/rossby24/proj/rossby/boundary/CMIP6/MRI-ESM2-0/r1i1p1f1/ssp585/grb/'
 

# -----------------
# --- META INFO ---
# -----------------
 cdo='cdo -s'
 mm_s=(01 02 03 04 05 06 07 08 09 10 11 12) # months
 days=(31 28 31 30 31 30 31 31 30 31 30 31) # number of days 


# --------------------
# ---   YEAR LOOP  ---
# --------------------
 count_file_var=0
 count_file=0
 count_leap=0
 year_p=$((ly-fy+1))

 file_report='check_'$grb_name'_'$fy'-'$ly'.txt' 
 [ -f $file_report ] && rm $file_report
 echo ... EXPERIMENT '     ' ... $grb_name | tee -a $file_report
 echo ... INPUT PATH '     ' ... $path_in | tee -a $file_report
 echo ------------------------------------------------------------------------------------------------------------------ | tee -a $file_report

 beg_time="$(date +%s)"
 for ((yy=fy;yy<=ly;yy++)); do   # year loop
 echo ... processing ... $yy 

# ---------------------
# ---   MONTH LOOP  ---
# ---------------------
 for m in 1 2 3 4 5 6 7 8 9 10 11 12 ; do   # month loop
   #for m in 2 ; do   # month loop

    mm=${mm_s[$((m-1))]}

# ---- number of days February -------- 
  if [[ $m -eq 2 && $(($yy%4)) -eq 0 ]]; then
   num_day=29
   count_leap=$((count_leap+1))
  else
   num_day=${days[$((m-1))]}
  fi

# --- DAY LOOP ---
for ((dd=1;dd<=$num_day;dd++)); do   # year loop
 #echo ... $dd ... 

# ---- day string ------
 if [ $dd -lt 10 ]; then
   day='0'$dd
 else
   day=$dd
 fi

# --- 6hr HOUR LOOP --- 
 for hh in 00 06 12 18; do   # month loop 
  file_in=$path_in$grb_name'_'$yy$mm$day$hh'00+000H00M'
  if [ -f $file_in ] ; then
   
   if [ $count_file -eq 0 ]; then
    size_ref=$(stat -c%s "$file_in")
    echo ... Ref. file size ... $size_ref
   fi
   
   size=$(stat -c%s "$file_in")
   if [ $size -eq $size_ref ]; then 
    count_file=$((count_file+1))
   else
    echo Wrong size ... $file_in | tee -a $file_report
   fi
  
   #num_var=`$cdo npar $file_in`
   #if [ $num_var -eq 20 ]; then
   # count_file_var=$((count_file_var+1))
   #else
   # echo NO 20 VARS ... $file_in | tee -a $file_report
   #fi
 
  else
   echo NO FILE ... $file_in | tee -a $file_report
  fi
   done # hours
  done # days
 done # months
done # years

# --- final stat ---
 exp_file=$((4*(year_p*365+count_leap)))
 echo ... $grb_name ... $fy'-'$ly
 #echo ... number of files found ... $count_file '  expected ... ' $exp_file '   with 20 vars ... ' $count_file_var | tee -a $file_report
  echo ... number of files found ... $count_file '  expected ... ' $exp_file | tee -a $file_report
 end_time="$(date +%s)"
 echo
 echo ... ELAPSED TOTAL TIME ALL :  "$(expr $end_time - $beg_time)" sec
 echo ... END

