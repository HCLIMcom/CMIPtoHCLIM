#!/bin/bash
#SBATCH -N 1
#SBATCH -t 168:00:00 

#######################################################################
####                                                               ####
####    MERRA2 separate stratospheric and troposheric aerosol      ####
####                                                               ####    
#######################################################################

path_in="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/aer_tmp/input/"
path_out="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/aer_tmp/"

#date='199407'
#date='199412'

#date='201507'
date='201512'

file_aer=$path_in"MERRA2_OPPMONTH_wb10.${date}.nc"

#file_trop=$path_in"MERRA2_200.instM_2d_asm_Nx.${date}.nc4"
file_trop=$path_in"MERRA2_400.instM_2d_asm_Nx.${date}.nc4"

echo ... aerosol file ... $file_aer
echo ... tropop  file ... $file_trop

file_tmp0=$path_out"tmp0_MERRA2_OPPMONTH_${date}.nc"
file_tmp1=$path_out"tmp1_MERRA2_OPPMONTH_${date}.nc"

[ -f $file_tmp0 ] && rm $file_tmp0
[ -f $file_tmp1 ] && rm $file_tmp1


ncks -v DELP,PS $file_aer $file_tmp0
ncatted -a coordinates,DELP,d,, -h $file_tmp0
ncks -O -x -v wl $file_tmp0 $file_tmp0

ncap2 -s "pk=DELP; pk(:,:,:)=0.; pk(0,:,:)=0.01+DELP(0,:,:);" $file_tmp0 $file_tmp1
ncatted -a _FillValue,DELP,d,, -a _FillValue,pk,d,, -h $file_tmp1
ncap2 -O -s "for(k=1;k<=71;k++){pk(k,:,:)=pk(k-1,:,:)+DELP(k,:,:);}" $file_tmp1 $file_tmp1


ncks -A -v TROPPB $file_trop $file_tmp1
ncap2 -O -s "tropk=TROPPB; tropk(:,:,:)=0.;" $file_tmp1 $file_tmp1


#ncap2 -O -s 'lat_p=$lat.size; for(latt=0;latt<lat_p;latt++) { print("Lat= "); print(latt,"%f"); }' $file_tmp1 $file_tmp1

#ncap2 -O -s 'z=0; lat_p=$lat.size; for(latt=0;latt<lat_p;latt++) { print(latt); }' $file_tmp1 $file_tmp1

beg_time="$(date +%s)"
#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<lat_p-1;latt++) { for(lonn=0;lonn<lon_p-1;lonn++) { for(k=1;k<=69;k++) { print(k); print(latt); print(lonn); }}} ' $file_tmp1 $file_tmp1
#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<1;latt++) { for(lonn=0;lonn<lon_p-1;lonn++) { for(k=1;k<=69;k++) { print(k); print(latt); print(lonn); }}} ' $file_tmp1 $file_tmp1

#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<1;latt++) { for(lonn=0;lonn<15;lonn++) { for(k=1;k<=69;k++) { print(latt); if( TROPPB(0,latt,lonn) > pk(k,latt,lonn) && TROPPB(0,latt,lonn) < pk(k+1,latt,lonn) ) tropk(0,latt,lonn)=k; }}} ' $file_tmp1 $file_tmp1

# ---- works ---
#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<lat_p-1;latt++) { print(latt); for(lonn=0;lonn<lon_p-1;lonn++) { for(k=1;k<=69;k++) { if( TROPPB(0,latt,lonn) > pk(k,latt,lonn) && TROPPB(0,latt,lonn) < pk(k+1,latt,lonn) ) tropk(0,latt,lonn)=k; }}} ' $file_tmp1 $file_tmp1
#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<1;latt++) { print(latt); for(lonn=0;lonn<1;lonn++) { k=20; while( TROPPB(0,latt,lonn) > pk(k,latt,lonn) ) { tropk(0,latt,lonn)=k; k=k+1; }}} ' $file_tmp1 $file_tmp1

ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<lat_p-1;latt++) { print(latt); for(lonn=0;lonn<lon_p-1;lonn++) { k=20; while( TROPPB(0,latt,lonn) > pk(k,latt,lonn) ) { tropk(0,latt,lonn)=k; k=k+1; }}} ' $file_tmp1 $file_tmp1

[ -f $file_tmp0 ] && rm $file_tmp0

end_time="$(date +%s)"
echo
echo ELAPSED TIME: "$(expr $end_time - $beg_time)" sec


#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<lat_p-1;latt++) for(lonn=0;lonn<lon_p-1;lonn++) for(k=1;k<=69;k++) {  print(k,"%f"); print(latt,"%f"); print(lonn,"%f"); if(TROPPB(0,latt,lonn) < pk(k,latt,lonn)) tropk(0,latt,lonn)=5.; } ' $file_tmp1 $file_tmp1
#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<lat_p-1;latt++); for(lonn=0;lonn<lon_p-1;lonn++); for(k=1;k<=69;k++); { if( TROPPB(0,latt,lonn) > pk(k,latt,lonn) && TROPPB(0,latt,lonn) < pk(k+1,latt,lonn) ) tropk(0,latt,lonn)=5; } ' $file_tmp1 $file_tmp1



#ncap2 -O -s 'lat_p=$lat.size; lon_p=$lon.size; for(latt=0;latt<lat_p;latt++); for(lonn=0;lonn<lon_p;lonn++); for(k=1;k<=71;k++); {if( TROPPB(0,latt,lonn) < pk(k,latt,lonn) ) tropk(0,latt,lonn)=k; }' $file_tmp1 $file_tmp1


#for(*idx=0;idx<sz_idx;idx++)
#ncap2 -O -s "for(k=1;k<=71;k++){ where(TROPPB(:,:) < pk(k,:,:) || TROPPB(:,:) > pk(k+1,:,:) ) tropk(:,:)=k; }" $file_tmp1 $file_tmp1


#ncwa -O --no_cll_mth -a time -h $file_tmp1 $file_tmp1
#ncap2 -O -s "tropk=TROPPB; tropk(:,:)=0.;" $file_tmp1 $file_tmp1


#ncap2 -O -s "for(k=1;k<=71;k++){ where(TROPPB(:,:) < pk(k,:,:) || TROPPB(:,:) > pk(k+1,:,:) ) tropk(:,:)=k; }" $file_tmp1 $file_tmp1
#ncap2 -O -s "for(k=1;k<=71;k++){ where(TROPPB($time,:,:) < pk(k,:,:) || TROPPB($time,:,:) > pk(k+1,:,:) ) tropk($time,:,:)=k; }" $file_tmp1 $file_tmp1



#ncap2 -s 'where(th < 0.0 || th > 50.0) th=th.get_miss();' in.nc out.nc
#ncap2 -O -s "for(k=1;k<71;k++)" $file_tmp1 $file_tmp1
#for(*idx=0;idx<sz_idx;idx++)
#TROPPB

echo
echo
echo "END"
