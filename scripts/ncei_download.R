cfs.dwnld <- function(yr){
  date <- paste0(yr, "-01-01")
  url <- paste0("https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/6-hourly-flux")
  add.months <- function(date,n) seq(date, by = paste (n, "months"), length = 2)[2]
  system(paste0("rm -r -f /home/jovyan/common_data/noaa_cfs-wfmi/raw/", yr, "/*"))
  dir.create(paste0("/home/jovyan/common_data/noaa_cfs-wfmi/raw/", yr), showWarnings = FALSE)
  dir.create(paste0("/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", yr), showWarnings = FALSE)
  for (i in as.list(seq(as.Date(date), add.months(as.Date(date), 6), by = "day"))) {
    year <- format(as.Date(date),"%Y")
    month <- format(as.Date(date),"%m")
    day <- format(as.Date(date),"%d")
    year.f <- format(as.Date(i),"%Y")
    month.f <- format(as.Date(i),"%m")
    day.f <- format(as.Date(i),"%d")
    for (t in c("00")) {
    # for (t in c("00", "06", "12", "18")) {
      # for (t.f in c("00")) {
      for (t.f in c("00", "06", "12", "18")) {
        files <- paste0(url, "/",
                        year, "/",
                        year, month, "/",
                        year, month, day, "/",
                        year, month, day, t, "/",
                        "flxf", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".grb2")
        tryCatch(
          expr = download.file(url = files,
                               destfile = paste0("/home/jovyan/common_data/noaa_cfs-wfmi/raw/", year,"/flxf", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".grb2"),
                               quiet = TRUE),
          error = function(e){
            message(paste("Does not exist: ", files, sep = ""))
          }
        )
        bands <- 31 # prec band
        bname <- "prec"
        bunits <- "kg/(m^2 s)"
        dir.create(paste("/home/jovyan/common_data/noaa_cfs-wfmi/intermediate", year, bname, sep = "/"), showWarnings = FALSE)
        system(paste0("gdal_translate -b ",bands," -co COMPRESS=LZW -co BIGTIFF=YES ",
                      "/home/jovyan/common_data/noaa_cfs-wfmi/raw/", year,"/flxf", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".grb2 ",
                      "/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname,"/flxf_", bname, "_", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".tif"))
        system(paste0("gdalwarp -t_srs '+proj=longlat +datum=WGS84 +ellps=WGS84 +units=m +no_defs' -te -32 -35 52 32 -te_srs '+proj=longlat +datum=WGS84 +ellps=WGS84 +units=m +no_defs' -co COMPRESS=LZW -co BIGTIFF=YES --config CENTER_LONG 0 -overwrite ",
                      "/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname,"/flxf_", bname, "_", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".tif ",
                      "/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname,"/flxf_4326_", bname, "_", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".tif"))
        system(paste0("rm -r -f ",
                      "/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname,"/flxf_", bname, "_", year.f, month.f, day.f, t.f, ".01.", year, month, day, t,".tif"))
      }
    }
    band <- "prec"
    p.files <- list.files(paste0("/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname),
                          pattern = paste0("flxf_4326_", band, "_", year.f, month.f, day.f),
                          full.names = TRUE)
    avg <- terra::tapp(terra::rast(p.files), fun = mean, index = 1)*86400
    terra::writeRaster(avg, paste0("/home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname, "/", "cfs_", band, "_4326_", year.f, month.f, day.f, "_", year, month, day, ".nc"),
                       datatype = "FLT4S", filetype = "netCDF", gdal = c("BIGTIFF=YES"), names = paste0("Precipitation [mm] ", year.f, month.f, day.f))
    system(paste0("rm -r -f /home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname, "/flxf_4326_*"))
    gc(verbose = FALSE, full = TRUE)
  }
  system(paste0("ncecat /home/jovyan/common_data/noaa_cfs-wfmi/intermediate/", year, "/", bname, "/", "*.nc /home/jovyan/common_data/noaa_cfs-wfmi/cfs_", bname, "_", year, ".nc"))
}
