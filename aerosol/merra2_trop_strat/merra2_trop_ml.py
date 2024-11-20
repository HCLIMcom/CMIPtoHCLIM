###########################################################
####                                                   ####
####                    MERRA2                         ####
####           Model level of the Tropopause           ####
####               instM_2d_asm_Nx                     ####
####             TROPPB (blended_estimate)             ####
####                 monthly mean                      ####
####                                                   ####
###########################################################

import xarray as xr
import os
import time

# ------------
# --- PATH ---
# ------------
path_aero_in="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/OPPMONTH_wb10/"
path_trop_in="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/M2IMNXASM/"
path_out="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/derived/tropk/"

# --------------------
# --- DRS elements ---
# --------------------
table_in="Amon"
gcm_name="NASA-MERRA2"
gcm_exp="rean"
gcm_mem="r1i1p1-vl"

# ---------------------
# ---   FREQUENCY   ---
# ---------------------
freq="mon"

# ---------------------
# ---   Variables   ---
# ---------------------
var="tropk"

# --- Control period ---
fy_ctl=1980
ly_ctl=1980

mons=["01","02","03","04","05","06","07","08","09","10", "11", "12"]

# --- Year Loop ---
for yy in range(fy_ctl, ly_ctl+1):
 print("Year: ", yy)
 
# --- Month Loop ---
 for mm in range(0, 12):
  #for mm in range(9, 12):
  print("Month: ",mons[mm])
  
 # ---- aerosol file --- 
  file_aero_in=''.join([path_aero_in,'MERRA2_OPPMONTH_wb10.',str(yy),mons[mm],'.nc'])
  print(file_aero_in)
 
 # ---- pressure at the tropopause file --- 
  if yy >= 1979 and yy <= 1991: version='MERRA2_100'
  if yy >= 1992 and yy <= 2000: version='MERRA2_200'
  if yy >= 2001 and yy <= 2010: version='MERRA2_300'
  if yy >= 2011 and yy <= 2021: version='MERRA2_400'
  if yy == 2020 and mm == 8 : version='MERRA2_401'
  if yy == 2021 and mm >= 5 and mm <=8 : version='MERRA2_401'
  
  file_trop_in=''.join([path_trop_in,version,'.instM_2d_asm_Nx.',str(yy),mons[mm],'.nc4'])
  print(file_trop_in)
  
 # --- read datasets ---
  aero = xr.open_dataset(file_aero_in)
  dyna = xr.open_dataset(file_trop_in)
  
  glob_attrs=dyna.attrs
  
 # --- pressure at model levels --- 
  delp=aero.data_vars['DELP']   # model layer thickness
  pk=1.+delp.cumsum('lev')      # pressure at model levels 
  
 # --- the tropopause position in terms of model levels --- 
  trop=dyna.data_vars['TROPPB'] 
  tropk=xr.zeros_like(trop, dtype=float)
  tropk=tropk.rename('tropk')
       
  lon_p=trop.lon.size
  lat_p=trop.lat.size
  
  start_time = time.time()
  
  #for lon in range(0, lon_p):
  # for lat in range(0, lat_p):
  for lon in range(0, lon_p):
   for lat in range(0, lat_p):
    one_tmp=pk[:,lat,lon]
    diff_abs=abs(one_tmp-trop[0,lat,lon])
    ind_k=diff_abs.idxmin()
    tropk[0,lat,lon]=ind_k
    
  print("")
  print(" ... CALCULATION TIME "+str(yy),mons[mm]+" ... "+str(int(time.time() - start_time))+" sec")
  print("") 
  
     
 # ---- output ----
  file_out_tmp0=''.join([path_out,'tmp0_',var,'_',table_in,'_',gcm_name,'_',gcm_exp,'_',gcm_mem,'_',str(yy),'-',str(yy),'.nc'])
  file_out=''.join([path_out,var,'_',table_in,'_',gcm_name,'_',gcm_exp,'_',gcm_mem,'_',str(yy),'-',str(yy),'.nc'])    
    
  del tropk.lon.attrs['vmax']
  del tropk.lon.attrs['vmin'] 
  del tropk.lon.attrs['valid_range']
  tropk.lon.attrs['standard_name']='longitude'
  
  del tropk.lat.attrs['vmax']
  del tropk.lat.attrs['vmin'] 
  del tropk.lat.attrs['valid_range']
  tropk.lat.attrs['standard_name']='latitude'
  
  del tropk.time.attrs['vmax']
  del tropk.time.attrs['vmin'] 
  del tropk.time.attrs['valid_range']
  del tropk.time.attrs['time_increment']
  del tropk.time.attrs['begin_date']
  del tropk.time.attrs['begin_time']
  tropk.time.attrs['standard_name']='time'
  
  del tropk.attrs['vmax']
  del tropk.attrs['vmin']
  del tropk.attrs['valid_range']
  del tropk.attrs['fmissing_value']
  tropk.attrs['units']='1'
  tropk.attrs['long_name']='model level of the tropopause'
  tropk.attrs['standrad_name']='tropopause_model_level'
  tropk.attrs['cell_methods']='time: mean'
  tropk.attrs['comments']='based on TROPPB (blended_estimate) assimilation'     
  
    
 # --- global attributes --- 
  ds_tropk = tropk.to_dataset(name='tropk')
  ds_tropk.attrs=glob_attrs
      
 # --- Saving netcdf ---   
  var_enc = {  'lat': {'zlib': False, '_FillValue': None},
               'lon': {'zlib': False, '_FillValue': None},
              'time': {'zlib': False, '_FillValue': None, 'dtype': 'float64', 'units': 'days since 1949-12-01 00:00:00'},
             'tropk': {'zlib': True, 'complevel': 1, 'dtype': 'float32', '_FillValue': 1.e20},
            }
            
  ds_tropk.to_netcdf(file_out_tmp0, encoding=var_enc, unlimited_dims="time")

 # --- fix time bounds and time ---
  cdo_com="cdo -s -settbounds,month "+file_out_tmp0+" "+file_out 
  os.system(cdo_com)
  os.system("[ -f "+file_out_tmp0+" ] && rm "+file_out_tmp0)
  
  nco_com="ncap2 -h -O -s 'time(:)=( (time_bnds(:,0)+time_bnds(:,1))/2. );' "+file_out+" "+file_out
  os.system(nco_com)
  
  
  # -------------------------------------
  # ---  DATES in FILE NAME: YYYYMMDD ---
  # -------------------------------------
  num_time = os.popen("cdo -s ntime "+file_out).read()
  num_time=num_time.replace("\n", "")
  f_date=os.popen("cdo -s showdate -seltimestep,1 "+file_out).read(); f_date=f_date.replace("\n", ""); f_date=f_date.replace(" ", ""); f_date=f_date.replace("-", "")
  l_date=os.popen("cdo -s showdate -seltimestep,"+num_time+" "+file_out).read(); l_date=l_date.replace("\n", ""); l_date=l_date.replace(" ", ""); l_date=l_date.replace("-", "")

  if freq =="mon":
   file_cmip=''.join([path_out,var,'_',table_in,'_',gcm_name,'_',gcm_exp,'_',gcm_mem,'_',f_date[0:6],'-',l_date[0:6],'.nc'])
  elif freq =="day":
   print("day")

  print("")
  print("--------------------------")
  print(" ... FINAL CMIP FILE ... "+file_cmip)
  print("--------------------------")
  os.system("mv "+file_out+" "+file_cmip)

print() 
print("------------------")
print("----   DONE  -----")
print("------------------")
print("")  

