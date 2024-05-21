# c <- read.csv("~/TRANSFORM/egb/wfmi/data/station/coords.csv", sep = ",")
# f <- read.csv("~/TRANSFORM/egb/wfmi/data/forecast/Stations_Durations.csv", sep = ",")
# cf <- merge(c,f, by = "name")
# cf <- cf[!duplicated(cf$name),]
# 
# # decimalplaces <- function(x) {
# #     if (abs(x - round(x)) > .Machine$double.eps^0.5) {
# #         nchar(strsplit(sub('0+$', '', as.character(x)), ".", fixed = TRUE)[[1]][[2]])
# #     } else {
# #         return(0)
# #     }
# # }
# 
# # for (station in cf$name){
# #   d <- cf[cf$name == station,]
# #   if(!is.na(d$X) & !is.na(d$Y)){
# #     for (year in seq(d$start, d$end)){
# #       if(decimalplaces(d$X) == 0 | decimalplaces(d$Y) == 0){
# #         x <- d$X + 0.5
# #         Y <- d$Y + 0.5
# #       }
# #       else {
# #         x <- d$X
# #         y <- d$Y
# #       }
# #       # system(paste('python3 /home/jovyan/TRANSFORM/egb/wfmi/s5_download.py', floor(x), ceiling(x), floor(y), ceiling(y), year, gsub(" ", "_", trimws(station)), sep = ' '))
# #       r <- terra::rast(paste0('/home/jovyan/common_data/ecmwf_s5-wfmi/intermediate/', station, '_rain_', year, '.nc'))
# #       p <- terra::vect(data.frame("x" = x, "y" = y), geom = c("x", "y"), crs="+proj=longlat +datum=WGS84")
# #       o <- as.numeric(terra::extract(r, p, xy = T)[1,])
# #     }
# #   }
# # }
# 
# for(year in seq(sort(cf$start)[1], sort(cf$end)[length(sort(cf$start))])){
#   system(paste('python3 /home/jovyan/TRANSFORM/egb/wfmi/s5_download.py', year, sep = ' '))
#   x <- terra::rast(paste0("/home/jovyan/common_data/ecmwf_s5-wfmi/intermediate/ecmwf_s5_rain_", year, ".nc"))
#   o <- terra::rast()
#   for (lyr in 1:terra::nlyr(x)) {
#     if (lyr == 1){
#       terra::add(o) <- x[[lyr]]
#     }
#     else {
#       s0 <- x[[lyr-1]]
#       s1 <- x[[lyr]]
#       s <- s1 - s0
#       terra::add(o) <- s
#     }
#   }
#   terra::crs(o) <- "EPSG:4326"
#   terra::writeCDF(o, paste0("/home/jovyan/common_data/ecmwf_s5-wfmi/intermediate/ecmwf_s5_rain_", year, ".nc"), overwrite=TRUE,
#                   unit="mm", compression = 5)
# }

ecmwf.dwnld <- function(date = NULL, X = NULL, Y = NULL, out.dir = NULL){
  # Format input arguments
  year <- as.character(format(date, "%Y"))
  month <- as.character(format(date, "%m"))
  day <- as.character(format(date, "%d"))
  xmin <- as.numeric(X-1)
  ymin <- as.numeric(Y-1)
  xmax <- as.numeric(X+1)
  ymax <- as.numeric(Y+1)
  dir.create(paste0(out.dir, "/raw"), recursive = TRUE)
  dir.create(paste0(out.dir, "/intermediate"), recursive = TRUE)
  # Download
  system(paste('python3 /home/jovyan/TRANSFORM/egb/wfmi/s5_download.py', year, month, day, xmin, ymin, xmax, ymax, out.dir, sep = ' '))
  x <- terra::rast(paste0(out.dir, '/intermediate/ecmwf-s5_prec_', year, month, day, '.nc'))
  # x <- terra::rast(paste0("/home/jovyan/common_data/ecmwf_s5-wfmi/intermediate/ecmwf_s5_rain_", year, ".nc"))
  o <- terra::rast()
  for (lyr in 1:terra::nlyr(x)) {
    if (lyr == 1){
      terra::add(o) <- x[[lyr]]
    }
    else {
      s0 <- x[[lyr-1]]
      s1 <- x[[lyr]]
      s <- s1 - s0
      terra::add(o) <- s
    }
  }
  terra::crs(o) <- "EPSG:4326"
  terra::writeCDF(o, paste0(out.dir, '/intermediate/ecmwf-s5_prec', '.nc'), overwrite=TRUE,
                  unit="mm", compression = 5)
  # terra::writeCDF(o, paste0("/home/jovyan/common_data/ecmwf_s5-wfmi/intermediate/ecmwf_s5_rain_", year, ".nc"), overwrite=TRUE,
  #                 unit="mm", compression = 5)
  system(paste0("rm -f ", out.dir, '/intermediate/ecmwf-s5_prec_', year, month, day, '.nc'))
}
