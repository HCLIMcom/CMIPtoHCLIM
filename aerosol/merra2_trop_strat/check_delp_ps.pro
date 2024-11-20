yy='1980'
mm='01'

path_aero_in="/home/rossby/imports/obs/MERRA/MERRA2/orig/mon/OPPMONTH_wb10/"
file_aero_in=path_aero_in+'MERRA2_OPPMONTH_wb10.'+yy+mm+'.nc'

delp=nc_varget(file_aero_in, 'DELP')
ps=nc_varget(file_aero_in, 'PS')
aod=nc_varget(file_aero_in, 'AOD')

air=nc_varget(file_aero_in, 'AIRDENS')

bc=nc_varget(file_aero_in, 'EXTBC')
du=nc_varget(file_aero_in, 'EXTDU')
oc=nc_varget(file_aero_in, 'EXTOC')
su=nc_varget(file_aero_in, 'EXTSU')
ss=nc_varget(file_aero_in, 'EXTSS')

;fac=delp/(air*9.80665)
fac=delp/(air*9.81)


aod_bc=total(bc*fac,3)
aod_du=total(du*fac,3)
aod_oc=total(oc*fac,3)
aod_su=total(su*fac,3)
aod_ss=total(ss*fac,3)

aod_est=aod_bc+aod_du+aod_oc+aod_su+aod_ss

;--- LONS and LATS  -----
 lons=NC_VARGET(file_aero_in,'lon')
 lats=NC_VARGET(file_aero_in,'lat')
 xxx=size(ps) & lon_p=xxx(1) & lat_p=xxx(2)
 
 print, ps(300,300)-total(delp(300,300,*),3)

 ; --- pressure at model levels --- 
 ;delp=aero.data_vars['DELP']   # model layer thickness
 ;pk=0.01+delp.cumsum('lev')    # pressure at model levels 

;----- END OF PROGRAM ----
eop:
IF !D.NAME EQ 'PS' then device,/close
set_plot,'X'
!P.MULTI=0
print,'END'
end
