# CMIPtoHCLIM
Converts NetCDF data from CMIP models to grib format to be used as forcing for HCLIM.

Initial development by Oskar Landgren (oskar.landgren@met.no) & Andreas Dobler (andreas.dobler@met.no)

The idea here is to produce grib files of the same format as the ERA-Interim forcing used by Harmonie
so that no changes have to be made in the Harmonie system, i.e., we are using HOST_MODEL=ifs
Another possibilty would be to use e.g. HOST_MODEL=CMIP (or similar) and adjust the Harmonie system accordingly.


