# NorESM2-MM conversion scripts

These scripts are intended to convert NetCDF data from the NorESM2-MM model availabe at ESGF servers to grib format that can be used as forcing for HARMONIE-Climate (HCLIM).

## Instructions

1. Download the data from ESGF. You can use the wget scripts in the **wget-NorESM2** folder (you need an ESGF account/openID).
2. Use the (bash) script **Prepare_NorESM2-MM_sic_tos_ts.sh** to interpolate sea-ice concentration (sic), sea surface temperature (tos) and skin temperature (ts) from daily or monthly values to 6-hourly values.
You need to adjust the paths before running!
3. Use the (bash) scripts **NorESM2-MMtoGRIB_*.sh** to convert the NetCDF data from NorESM2-MM to grib format.
You will need grib_api and cdo. Again, adjust the paths before running!

  - **NorESM2-MMtoGRIB_YYYY.sh** converts historical input files. Takes year as input parameter.

## Not yet adapted:
  - **NorESM2-MMtoGRIB_YYYY_ssp585.sh** converts ssp585 input files. Takes year as input parameter.
  - **NorESM2-MMtoGRIB_21010101_rcp85.sh** produces 01.01.2101 (copy of 31.12.2100)
  
  ## Good luck!

