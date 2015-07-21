# pgis-2-r
Functions for importing spatial tables from Postgresql databases in R

These functions covert spatial tables in Postgresql databases to Spatial* (`sp` package) objects in R. They require a connection object to the Postgresql (using `RPostgreSQL`) database as an argument, e.g.:

```
library(RPostgreSQL)
drv<-dbDriver("PostgreSQL")
conn<-dbConnect(drv,dbname='dbname',host='host',port='5432',user='user',password='password')
```

Table name, geometry column (default 'geom'), and geometry ID column (default 'gid') are required arguments. Projection should be entered as the EPSG code number (but can be left null). The other.cols argument allows to select a list of columns from the table to attach as a data frame in R (default is all columns). If this is set to null the function will return a Spatial-only object (no data frame).
