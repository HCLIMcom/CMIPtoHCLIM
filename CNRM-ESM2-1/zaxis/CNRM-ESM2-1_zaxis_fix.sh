# CNRM-ESM2-1 zaxis description 

ncks -O -d time,1 /home/rossby/boundary/CMIP6/CNRM-ESM2-1/r1i1p1f1/historical/nc/atmos/va_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_201409010600-201501010000.nc /nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/CNRM-ESM2-1/zaxis/va_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_1ts.nc

path_in='/nobackup/rossby24/users/sm_grini/Data/CMIP6/LBC/CNRM-ESM2-1/zaxis/'

file_in=$path_in'va_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_1ts.nc'
file_out=$path_in'va_6hrLev_CNRM-ESM2-1_historical_r1i1p1f2_gr_1ts_clean.nc'
file_tmp0=$path_in'tmp0_CNRM-ESM2-1.nc'

file_out=$file_in
#ncks -O -x -v ps $file_in $

# --- delete all global attributes --
ncatted -O -a ,global,d,, -h $file_out $file_out


# --- fix lev attributes ---
 ncatted -a long_name,lev,o,c,"hybrid sigma pressure coordinate" -h $file_out
 ncatted -a axis,lev,o,c,"Z" -h $file_out
 ncatted -a name,lev,d,, -h $file_out
 ncatted -a formula_term,lev,d,, -h $file_out
 ncatted -a formula_terms,lev,o,c,"ap: ap b: b ps: ps" -h $file_out
 ncatted -a bounds,lev,o,c,"lev_bnds" -h $file_out

# --- fix lev_bnds ---
 ncrename -O -v lev_bounds,lev_bnds -h $file_out
 ncatted -a formula_terms,lev_bnds,o,c,"ap: ap_bnds b: b_bnds ps: ps" -h $file_out
 ncatted -a formula_term,lev_bnds,d,, -h $file_out

# --- fix var attribures ---
 ncatted -a coordinates,va,d,, -h $file_out
 ncatted -a coordinates,ps,d,, -h $file_out

# --- fix psattribures ---
 ncatted -a long_name,ps,o,c,"vertical coordinate formula term: ps" -h $file_out

# --- clean ap ---
 ncatted -a units,ap,o,c,"Pa" -h $file_out
 ncatted -a online_operation,ap,d,, -h $file_out
 ncatted -a coordinates,ap,d,, -h $file_out

# --- clean ap_bnds ---
 ncatted -a units,ap_bnds,o,c,"Pa" -h $file_out
 ncatted -a online_operation,ap_bnds,d,, -h $file_out
 ncatted -a coordinates,ap_bnds,d,, -h $file_out

# --- clean b ---
 ncatted -a online_operation,b,d,, -h $file_out
 ncatted -a coordinates,b,d,, -h $file_out

# --- clean b_bnds ---
 ncatted -a online_operation,b_bnds,d,, -h $file_out
 ncatted -a coordinates,b_bnds,d,, -h $file_out

# --- lev bounds fix dimension ---
 #ncks -O -v ap_bnds,b_bnds -h $file_out $file_tmp0
 #ncpdq -O -v ap_bnds,b_bnds -a lev,bnds $file_tmp0 $file_tmp0
 ncks -O -x -v ap_bnds,b_bnds -h $file_out $file_out
 #ncrename -O -d axis_nbounds,bnds -h $file_out
 ncks -A -v ap_bnds,b_bnds -h 'CNRM_models_vertical_coordinates.nc' $file_out


###### ncks -A -v ap_bnds,b_bnds -h $file_tmp0 $file_out



exit

ncrename -O -v lev_bounds,lev_bnds $file_out
#ncatted -a bounds,lev,o,c,"lev_bnds" $file_out
ncatted -a bounds,lev,d,, $file_out
ncatted -a formula_term,lev,d,, $file_out
ncatted -a formula_terms,lev,o,c,"ap: ap b: b ps: ps" $file_out

# --- lev bounds ---
ncks -O -v lev_bnds $file_out $file_tmp0
ncrename -O -d axis_nbounds,bnds $file_tmp0

ncks -O -x -v lev_bnds $file_out $file_out
ncwa -O --no_cll_mth -a axis_nbounds -h $file_out $file_out
ncks -A -v lev_bnds $file_tmp0 $file_out
ncatted -a bounds,lev,o,c,"lev_bnds" $file_out
exit




exit



# --- clean ap ---
 ncatted -a units,ap,o,c,"Pa" $file_out
 ncatted -a online_operation,ap,d,, $file_out
 ncatted -a coordinates,ap,d,, $file_out

# --- clean ap_bnds ---
 ncatted -a units,ap_bnds,o,c,"Pa" $file_out
 ncatted -a online_operation,ap_bnds,d,, $file_out
 ncatted -a coordinates,ap_bnds,d,, $file_out

# --- clean b ---
 ncatted -a online_operation,b,d,, $file_out
 ncatted -a coordinates,b,d,, $file_out

# --- clean b_bnds ---
 ncatted -a online_operation,b_bnds,d,, $file_out
 ncatted -a coordinates,b_bnds,d,, $file_out

exit

MPI
double lev(lev) ;
		lev:bounds = "lev_bnds" ;
		lev:units = "1" ;
		lev:axis = "Z" ;
		lev:positive = "down" ;
		lev:long_name = "hybrid sigma pressure coordinate" ;
		lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
		lev:formula = "p = ap + b*ps" ;
		lev:formula_terms = "ap: ap b: b ps: ps" ;


double lev(lev) ;
                lev:bounds = "lev_bnds" ;
                lev:units = "1" ;
                lev:axis = "Z" ;
                lev:positive = "down" ;
                lev:long_name = "hybrid sigma pressure coordinate" ;
		lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
		lev:formula = "p = ap + b*ps" ;
		lev:formula_terms = "ap: ap b: b ps: ps" ;


#lev:long_name = "hybrid sigma pressure coordinate" ;
#lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;


#ncrename -O -v lev_bounds,lev_bnds $file_in $file_out

#ncrename -O -d axis_nbounds,bnds $file_out

#ncatted -a bounds,lev,o,c,"lev_bnds" $file_out


