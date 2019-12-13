# GFDL-CM3 conversion scripts

These scripts are intended to convert NetCDF data from the GFDL-CM3 model availabe at ESGF servers to grib format that can be used as forcing for HARMONIE-Climate (HCLIM).

## Instructions

1. Download the data from ESGF. You can use the wget scripts in the **wget-GFDL** folder (you need an ESGF account/openID).
2. Use the (bash) script **Prepare_GFDL-CM3_sic_tos_ts.sh** to interpolate sea-ice concentration (sic), sea surface temperature (tos) and skin temperature (ts) from daily or monthly values to 6-hourly values.
You need to adjust the paths before running!
3. Use the (bash) scripts **GFDL-CM3toGRIB_*.sh** to convert the NetCDF data from GFDL-CM3 to grib format.
You will need grib_api and cdo. Again, adjust the paths before running!

  - **GFDL-CM3toGRIB_YYYY.sh** converts historical input files. Takes year as input parameter.
  - **GFDL-CM3toGRIB_YYYY_rcp85.sh** converts rcp85 input files. Takes year as input parameter.
  - **GFDL-CM3toGRIB_2006_rcp85.sh** converts year 2006 (mixture of historical and rcp85 input files)
  - **GFDL-CM3toGRIB_21010101_rcp85.sh** produces 01.01.2101 (copy of 31.12.2100)
  
  ## Good luck!

