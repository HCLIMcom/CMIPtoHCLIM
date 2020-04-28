# NorESM2-MM conversion scripts

These scripts are intended to convert NetCDF data from the NorESM2-MM model availabe at ESGF servers to grib format that can be used as forcing for HARMONIE-Climate (HCLIM).
## IMPORTANT
There are two NorESM-specific errors that I had to deal with. If you are planning to adapt this script to another CMIP6 model please remove them:
1. The 6-hourly data (ta, ua, va and hus) from NorESM2-MM has incorrect timestamp, as documented here:
   https://github.com/NorESMhub/noresm2cmor/issues/109
   (Short summary: It should be 00/06/12/18h but is 21/03/09/15h.)
   This applies to the historical period only, not SSP585.
   I have therefore added a "shifttime+3hours" to the cdo commands for these files. If you are adapting this script to another model which does not have this issue, please remove these. 
2. siconc has missing values in longitude and latitude variables. Documented at https://github.com/NorESMhub/noresm2cmor/issues/39
   I have dealt with this by manually appending them from another variable, e.g. tos. (ncks -A -v longitude tos.nc siconc.nc)

## Instructions

1. Download the data from ESGF. (I should put scripts in the wget folder just like for GFDL scripts, but I haven't done this yet. You can use the wget scripts in the **wget-NorESM2** folder (you need an ESGF account/openID).)
2. Use the (bash) script **Prepare_NorESM2-MM_sic_tos_ts.sh** to interpolate sea-ice concentration (sic), sea surface temperature (tos) and skin temperature (ts) from daily or monthly values to 6-hourly values.
You need to adjust the paths before running!
3. Use the (bash) scripts **NorESM2-MMtoGRIB_*.sh** to convert the NetCDF data from NorESM2-MM to grib format.
You will need grib_api and cdo. Again, adjust the paths before running!

  - **NorESM2-MMtoGRIB_YYYY.sh** converts historical input files. Takes year as input parameter. Uses shifttime +3hours for 6-hourly data (see above).
  - **NorESM2-MMtoGRIB_YYYY_ssp585.sh** converts ssp585 input files. Takes year as input parameter.

## Not yet adapted:
  - **NorESM2-MMtoGRIB_21010101_ssp585.sh** produces 01.01.2101 (copy of 31.12.2100)
  
  ## Good luck!

