ncei_format <- function(x, y){

  require(tidyverse)
  require(lubridate)
  
  origin <- getwd()
    
  # create variable cubes
  setwd("/home/jovyan/TRANSFORM/egb/wfmi/data/forecast/ncei/data/process")
  for (dir in list.dirs()) {
    if(dir == paste0(".")){}
    else {
      assign(paste0(sub("./", "", dir)), terra::rast(), envir = .GlobalEnv)
      for (file in list.files(path = paste0(dir), full.names = TRUE)) {
        cube <- get(paste0(sub("./", "", dir)), envir = .GlobalEnv)
        terra::add(cube) <- terra::rast(file)
      }
    }
  }
  
  dates <- c()
  prc <- c()
  tmx <- c()
  tmn <- c()
  srd <- c()
  vpr <- c()
  wnd <- c()
  for (d in seq_len(terra::nlyr(prec))) {
    date <- terra::varnames(prec)[d]
    date <- substr(substr(date, 1, nchar(date)-9), 16, nchar(substr(date, 1, nchar(date)-9)))
    dates <- c(dates, date)
    pr <- terra::extract(prec[[d]], data.frame(x, y))[,2]
    tx <- terra::extract(tmax[[d]], data.frame(x, y))[,2]
    tn <- terra::extract(tmin[[d]], data.frame(x, y))[,2]
    sr <- terra::extract(srad[[d]], data.frame(x, y))[,2]
    wn <- terra::extract(wind[[d]], data.frame(x, y))[,2]
    prc <- c(prc, pr)
    tmx <- c(tmx, tx)
    tmn <- c(tmn, tn)
    srd <- c(srd, sr)
    wnd <- c(wnd, wn)
  }
  
  weather <- data.table::data.table("date" = dates, "prec" = prc, "tmax" = tmx, "tmin" = tmn, "srad" = srd, "wind" = wnd)
  weather$date <- format(as.Date(weather$date, "%Y%m%d"), "%Y-%m-%d")
    
  # wth$SRAD <- as.numeric(weather$SRAD)
  weather$srad <- as.numeric(rnorm(length(weather$date), 20.5, 5))
  weather$tmax <- as.numeric(weather$tmax)
  weather$tmin <- as.numeric(weather$tmin)
  weather$prec <- as.numeric(weather$prec)
  weather$wind <- as.numeric(weather$wind)
    
  setwd(origin)

  return(weather)
}