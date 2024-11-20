########################################################
#####                                               ####
#####                     MERRA2                    ####
#####           AODs from Vertical Profiles         ####
#####                                               ####
########################################################

import xarray as xr
import os
import time
from datetime import datetime
import pandas as pd

# ------------
# --- PATH ---
# ------------
path_aero_in="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/OPPMONTH_wb10/"
path_trop_in="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/derived/tropk/"
path_out="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/derived/aod/year/"

# --------------------
# --- DRS elements ---
# --------------------
table_in="AERmon"
gcm_name="NASA-MERRA2"
gcm_exp="rean"
gcm_mem_in="r1i1p1-vl"
gcm_mem_out="r1i1p1-vl-trop"

# ---------------------
# ---   FREQUENCY   ---
# ---------------------
freq="mon"


# ---------------------
# ---   Variables   ---
# ---------------------
#var_id=["od550aer","od550bc","od550dust","od550oa","od550so4","od550ss"]
#var_id=["od550bc"]
#var_id=["od550dust"]
#var_id=["od550oa"]
var_id=["od550so4"]
#var_id=["od550ss"]

# ----------------------
# ---     Period     ---
# ----------------------
fy_ctl=1980
ly_ctl=1980

mons=["01","02","03","04","05","06","07","08","09","10", "11", "12"]

# --- Variable Loop --- 
for idv, var in enumerate(var_id):
 
 
# --- Year Loop ---
 for yy in range(fy_ctl, ly_ctl+1):
  print("Year: ", yy)
  count=0
  aod_tot=[]
 
# --- Month Loop ---
  for mm in range(0, 12):
   print("Month: ",mons[mm])
   start_time = time.time()
   count=count+1
  
 # --- aerosol file --- 
   file_aero_in=''.join([path_aero_in,'MERRA2_OPPMONTH_wb10.',str(yy),mons[mm],'.nc'])
   print(file_aero_in)
  
 # --- tropk file --- 
   file_trop_in=''.join([path_trop_in,'tropk_Amon_',gcm_name,'_',gcm_exp,'_',gcm_mem_in,'_',str(yy),mons[mm],'-',str(yy),mons[mm],'.nc'])
   print(file_trop_in)
  
 # --- read datasets ---
   aero = xr.open_dataset(file_aero_in)
   trop = xr.open_dataset(file_trop_in)
   
  # --- variable definition ---
   if var == "od550bc": 
    var_merra="EXTBC"
    st_name="atmosphere_optical_thickness_due_to_black_carbon_ambient_aerosol"
    ln_name="Black Carbon Optical Thickness at 550nm"
    units="1"
   
   if var == "od550dust": 
    var_merra="EXTDU"
    st_name="atmosphere_optical_thickness_due_to_dust_ambient_aerosol_particles"
    ln_name="Dust Optical Thickness at 550nm"
    units="1"

   if var == "od550oa": 
    var_merra="EXTOC"
    st_name="atmosphere_optical_thickness_due_to_particulate_organic_matter_ambient_aerosol_particles"
    ln_name="Total Organic Aerosol Optical Depth at 550nm"
    units="1"

   if var == "od550so4": 
    var_merra="EXTSU"
    st_name="atmosphere_optical_thickness_due_to_sulfate_ambient_aerosol_particles"
    ln_name="Sulfate Aerosol Optical Depth at 550nm" 
    units="1"

   if var == "od550ss": 
    var_merra="EXTSS"
    st_name="atmosphere_optical_thickness_due_to_sea_salt_ambient_aerosol_particles"
    ln_name="Sea-Salt Aerosol Optical Depth at 550nm"
    units="1"
     
 # --- get variables ---
   ext=aero.data_vars[var_merra]    # aerosol ext. vertical profile 
   air=aero.data_vars['AIRDENS']    # air density vertical profile
   delp=aero.data_vars['DELP']      # model layer thickness
   tropk=trop.data_vars['tropk']    # tropopause (model level)
      
   aod_tot_tmp=xr.zeros_like(tropk, dtype=float)
   
   lon_p=tropk.lon.size
   lat_p=tropk.lat.size
 
  # --- total AOD (troposphere and stratosphere) ---
   tmp=[] 
   tmp=(ext*delp)/(air*9.80665)
      
   for lon in range(0, lon_p):
    for lat in range(0, lat_p):
     aod_tot_tmp[0,lat,lon]=tmp[ int(tropk[0,lat,lon].values):,lat,lon].sum(dim="lev") 
          
   if count == 1:
    aod_tot=aod_tot_tmp
   else:
    aod_tot=xr.concat( (aod_tot,aod_tot_tmp) ,dim="time" )  
    
  
# -------------------
# ---    OUTPUT   ---
# -------------------
  
# ---- output file ----   
  file_out_tmp0=''.join([path_out,'tmp0_',var,'_',table_in,'_',gcm_name,'_',gcm_exp,'_',gcm_mem_out,'_',str(yy),'-',str(yy),'.nc'])
  file_out=''.join([path_out,var,'_',table_in,'_',gcm_name,'_',gcm_exp,'_',gcm_mem_out,'_',str(yy),'-',str(yy),'.nc'])

 # --- define variable attributes ---
  aod_tot.attrs['units']=units
  aod_tot.attrs['long_name']=ln_name
  aod_tot.attrs['standrad_name']=st_name
  aod_tot.attrs['cell_methods']='time: mean'
  aod_tot.attrs['comments']='troposhere' 
  
 # ---clean and convert to dataset ---
  ds_aod_tot = aod_tot.to_dataset(name=var)

# --- define global attributes ---
  glob_attrs = { "institution": "NASA Global Modeling and Assimilation Office",
                 "institute_id": "NASA",
                 "reanalysis": "MERRA2",
                 "reanalysis_id": "NASA-MERRA2",  
                 "source": "rean",  
                 "frequency": "mon",
                 "product": "reanalysis",
                 "references": "http://gmao.gsfc.nasa.gov",   
                 "comments": "calculated from vertical profiles: https://b2share.fz-juelich.de/records/?community=a140d3f3-0117-4665-9945-4c7fcb9afb51",
               }

  ds_aod_tot.attrs=glob_attrs
   
# --- saving netcdf ---   
  var_enc = {  'lat': {'zlib': False, '_FillValue': None},
               'lon': {'zlib': False, '_FillValue': None},
              'time': {'zlib': False, '_FillValue': None, 'dtype': 'float64', 'units': 'days since 1949-12-01 00:00:00'},
                 var: {'zlib': True, 'complevel': 1, 'dtype': 'float32', '_FillValue': 1.e20},
           }
            
  ds_aod_tot.to_netcdf(file_out_tmp0, encoding=var_enc, unlimited_dims="time") 
  
# --- fix time bounds and time ---
  cdo_com="cdo -s -sellonlatbox,-0.05,359.9,-90.,90. -settbounds,month "+file_out_tmp0+" "+file_out
  os.system(cdo_com)
  os.system("[ -f "+file_out_tmp0+" ] && rm "+file_out_tmp0)

  nco_com="ncap2 -h -O -s 'time(:)=( (time_bnds(:,0)+time_bnds(:,1))/2. );' "+file_out+" "+file_out
  os.system(nco_com)

# --- fix global attributes ----
  os.system("ncatted -a history,global,d,, -a CDI,global,d,, -a CDO,global,d,, -h "+file_out)
  os.system("ncatted -a creation_date,global,o,c,"+"$( date +%Y'-'%m'-'%d'-T'%T'Z')"+" -h "+file_out)
  os.system("ncatted -a tracking_id,global,o,c,"+"`/home/rossby/host/${NSC_RESOURCE_NAME}/bin/uuid -v 4`"+" -h "+file_out)

# -------------------------------------
# ---  DATES in FILE NAME: YYYYMMDD ---
# -------------------------------------
  num_time = os.popen("cdo -s ntime "+file_out).read()
  num_time=num_time.replace("\n", "")
  f_date=os.popen("cdo -s showdate -seltimestep,1 "+file_out).read(); f_date=f_date.replace("\n", ""); f_date=f_date.replace(" ", ""); f_date=f_date.replace("-", "")
  l_date=os.popen("cdo -s showdate -seltimestep,"+num_time+" "+file_out).read(); l_date=l_date.replace("\n", ""); l_date=l_date.replace(" ", ""); l_date=l_date.replace("-", "")

  if freq =="mon":
   file_cmip=''.join([path_out,var,'_',table_in,'_',gcm_name,'_',gcm_exp,'_',gcm_mem_out,'_',f_date[0:6],'-',l_date[0:6],'.nc'])
  elif freq =="day":
   print("day")

  print("")
  print("--------------------------")
  print(" ... FINAL CMIP FILE ... "+file_cmip)
  print("--------------------------")
  os.system("mv "+file_out+" "+file_cmip)
   

 print("")
 print(" ...  TIME ... "+str(int(time.time() - start_time))+" seconds")
 print("")

 print("------------------")
 print("----   DONE  -----")
 print("------------------")
 print("")  
