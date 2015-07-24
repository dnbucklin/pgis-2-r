pgis2rast <- function(conn,table,rast='rast',proj=NULL,digits=9, NSEW=c(NULL,NULL,NULL,NULL)){
  
  require(raster)
  require(rgdal)
  
  if (!is.null(NSEW) && is.null(proj)) {stop('proj is required if a clipping box is given')}
  
  if (is.null(NSEW)) {trast<-suppressWarnings(dbGetQuery(conn,paste0("SELECT ST_X(ST_Centroid((gv).geom)) as x, ST_Y(ST_Centroid((gv).geom)) as y, (gv).val FROM (SELECT ST_PixelAsPolygons(",rast,") as gv FROM ",table,") a;")))}
  else {trast<-suppressWarnings(dbGetQuery(conn,paste0("SELECT ST_X(ST_Centroid((gv).geom)) as x, ST_Y(ST_Centroid((gv).geom)) as y, (gv).val FROM (SELECT ST_PixelAsPolygons(ST_Clip(",rast,",ST_SetSRID(ST_GeomFromText('POLYGON((",NSEW[4]," ",NSEW[1],",",NSEW[4]," ",NSEW[2],",
  ",NSEW[3]," ",NSEW[2],",",NSEW[3]," ",NSEW[1],",",NSEW[4]," ",NSEW[1],"))'),",proj,"))) as gv FROM ",table,"
  WHERE ST_Intersects(",rast,",ST_SetSRID(ST_GeomFromText('POLYGON((",NSEW[4]," ",NSEW[1],",",NSEW[4]," ",NSEW[2],",
  ",NSEW[3]," ",NSEW[2],",",NSEW[3]," ",NSEW[1],",",NSEW[4]," ",NSEW[1],"))'),",proj,"))) a;")))
  }
  
  if(!is.null(proj)) {
    EPSG<-make_EPSG()
    p4s<-EPSG[which(EPSG$code == proj), "prj4"]
    return(rasterFromXYZ(trast,crs=CRS(p4s),digits=digits))
  } else {return(rasterFromXYZ(trast,digits=digits))}
}
