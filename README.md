# pgis-2-r
Functions for importing spatial tables from Postgresql databases in R

These functions covert spatial tables in Postgresql databases to Spatial* (`sp` package) or Raster (`raster` package) objects in R. They require a connection object to the Postgresql (using `RPostgreSQL`) database as an argument, e.g.:

```
library(RPostgreSQL)
drv<-dbDriver("PostgreSQL")
conn<-dbConnect(drv,dbname='dbname',host='host',port='5432',user='user',password='password')
```

Postgresql table name, geometry/raster column (default 'geom'/'rast'), and geometry ID column (default 'gid') are required arguments. Projection should be entered as the EPSG code number (but can be left null). 

For geometries, the other.cols argument allows to select a list of columns from the table to attach as a data frame in R (default is all columns). If this is set to null the function will return a Spatial-only object (no data frame). An optional 'query' argument can send additional SQL (`AND`,`LIMIT`,`ORDER BY`,etc.) to modify the table selection. Note that character values will need to be escaped out using R syntax (e.g., `\'text\'`. Default selection is all non-null geometries.

The pgis2rast() function is a work-around which actually converts PostGIS rasters to a data frame of XYZ values and rebuilds it as a raster in R, using the `raster` function `rasterfromXYZ` (and the `digits` argument from [that function](http://www.inside-r.org/packages/cran/raster/docs/rasterFromXYZ) can be specified).  As such it is not as efficient as direct raster imports and should only be used for small rasters (< ~1 million pixels) unless a clipping box is specified. The `NSEW` argument uses coordinates in the rasters coordinate system to create a box to clip the raster (e.g., `NSEW = c(50,45,5,0)`) (order: North, South, East, West). If this argument is given, the `proj` must be specified as well.
