# Function creates a new SpatialLines or SpatialLinesDataFrame object from a table with geometry in Postgresql. 
# Requires that a connection already is established to the database using the dbDriver() and dbConnect() functions in the package RPostgreSQL.

pgis2slin <- function(conn,table,geom='geom',gid='gid',proj=NULL,other.cols = '*') {

  require(sp)
  require(rgdal)
  require(rgeos)
  
  if (is.null(other.cols))
    {dfTemp<-dbGetQuery(conn,paste0("select ",gid," as tgid,st_astext(",geom,") as wkt from ",table," where ",geom," is not null;"))
    row.names(dfTemp) = dfTemp$tgid}
  else {dfTemp<-dbGetQuery(conn,paste0("select ",gid," as tgid,st_astext(",geom,") as wkt,",other.cols," from ",table," where ",geom," is not null;"))
    row.names(dfTemp) = dfTemp$tgid}
  
  if (is.null(proj)){
    tt<-mapply(function(x,y) readWKT(x,y), x=dfTemp[,2], y=dfTemp[,1])}
  else {
    EPSG<-make_EPSG()
    p4s<-EPSG[which(EPSG$code == proj), "prj4"]
    tt<-mapply(function(x,y,z) readWKT(x,y,z), x=dfTemp[,2], y=dfTemp[,1], z=p4s)
  }
  
  Sline <- SpatialLines(lapply(1:length(tt), function(i) {
    lin <- slot(tt[[i]], "lines")[[1]]
    slot(lin, "ID") <- slot(slot(tt[[i]], "lines")[[1]],"ID")  ##assign original ID to Line
    lin
  }))
  
  Sline@proj4string<-slot(tt[[1]], "proj4string")

  if (is.null(other.cols)){ return(Sline) } 
  else {try(dfTemp[geom]<-NULL)
        try(dfTemp['wkt']<-NULL)
    spdf<-SpatialLinesDataFrame(Sline, dfTemp)
    spdf@data['tgid']<-NULL
    return(spdf)}
}
