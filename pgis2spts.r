pgis2spts <- function(conn,table,geom='geom',gid='gid',proj=NULL,other.cols='*',query=NULL) {
  
  require(sp)
  require(rgdal)
  require(rgeos)
  
  if (is.null(other.cols))
  {dfTemp<-suppressWarnings(dbGetQuery(conn,paste0("select ",gid," as tgid,st_astext(",geom,") as wkt from ",table," where ",geom," is not null ",query,";")))
  row.names(dfTemp) = dfTemp$tgid}
  else {dfTemp<-suppressWarnings(dbGetQuery(conn,paste0("select ",gid," as tgid,st_astext(",geom,") as wkt,",other.cols," from ",table," where ",geom," is not null ",query,";")))
  row.names(dfTemp) = dfTemp$tgid}
  
  if (is.null(proj)){
    tt<-mapply(function(x,y) readWKT(x,y), x=dfTemp[,2], y=dfTemp[,1])}
  else {
    EPSG<-make_EPSG()
    p4s<-EPSG[which(EPSG$code == proj), "prj4"]
    tt<-mapply(function(x,y,z) readWKT(x,y,z), x=dfTemp[,2], y=dfTemp[,1], z=p4s)
  }
  
  Spts <-do.call("rbind",tt)
  
  if (is.null(other.cols)){ return(Spts) } 
  else {try(dfTemp[geom]<-NULL)
    try(dfTemp['wkt']<-NULL)
    spdf<-SpatialPointsDataFrame(Spts, dfTemp)
    spdf@data['tgid']<-NULL
    return(spdf)}
}
