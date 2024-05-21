# Sub-set forecasts by stations as agreed on 26.01.2023 (LT0; LT1; LT2)

sts <- read.csv("~/TRANSFORM/egb/wfmi/data/station/prec-filtered.csv")
sts$date <- as.Date(sts$date)
sts <- sts[sts$date >= "2012-01-01",] # Remove dates where CFS is not available
sts <- sts[,colSums(is.na(sts))<nrow(sts)] # Filter-out stations with No Data
sts.names <- colnames(sts)[2:length(sts)] # Get stations names
# Load stations coordinates
st.xy <- read.csv("~/TRANSFORM/egb/wfmi/data/station/coords.csv")
st.xy <- st.xy[!is.na(st.xy$X) & !is.na(st.xy$Y),]
st.xy$name <- gsub(" ", ".", st.xy$name)
st.xy <- st.xy[st.xy$name %in% sts.names,] # Filter stations XY with data available
st.xy <- st.xy[!duplicated(st.xy$name),]

# Load ECMWF data
ecmwf <- terra::rast()
lapply(grep(list.files("~/common_data/ecmwf_s5-wfmi/intermediate/", pattern = "*.nc", full.names = TRUE), pattern='.aux.xml', invert=TRUE, value=TRUE),
       function(x){
         f <- terra::rast(x)
         names(f) <- terra::time(f[[1:terra::nlyr(f)]])
         terra::add(ecmwf) <- f
       })
# Load CFS data
cfs <- terra::rast()
lapply(grep(list.files("~/common_data/noaa_cfs-wfmi", pattern = "*.nc", full.names = TRUE), pattern='.aux.xml', invert=TRUE, value=TRUE),
       function(x){
         y <- as.integer(gsub("/home/jovyan/common_data/noaa_cfs-wfmi/cfs_prec_", "", gsub(".nc", "", x)))
         f <- terra::rast(x)
         names(f) <- seq(as.Date(1, origin = as.Date(paste0(y-1, "-12-31"))),
                         as.Date(terra::nlyr(f), origin = as.Date(paste0(paste0(y-1, "-12-31")))),
                         by = "day")
         terra::add(cfs) <- f
       })

# Processing data
for (s in sts.names) {
  sn <- gsub("\\.", "-", s)
  x <- st.xy[st.xy$name == s, "X"]
  y <- st.xy[st.xy$name == s, "Y"]
  if(length(x) == 0 | length(y) == 0){
    next
  }
  st <- sts[!(is.na(sts[s]) | sts[s]==""), c("date", s)] # Remove empty rows for each station and subset
  years <- unique(format(st$date, "%Y"))
  for (year in years) {
    for (month in sprintf("%02d", 1:3)){
      if (month == "01"){
        day <- "02"
      }
      else {day <- "01"}
      dates <- seq(as.Date(paste(year, month, day, sep = "-")),
                   as.Date(paste(year, paste0("0", as.integer(month)+1), 1, sep = "-"))-1,
                   by = "day")
      out <- st[st$date %in% dates,]
      colnames(out) <- c("date", "gauge.prec")
      if (nrow(out) < 1 | year == 2017){
        next
      }
      # Extract CFS data
      sub.cfs <- cfs[[as.character(out$date)]]
      ext.cfs <- as.data.frame(t(terra::extract(sub.cfs, terra::vect(data.frame("x" = as.numeric(x), "y" = as.numeric(y)), geom=c("x", "y")))))
      ext.cfs <- as.data.frame(cbind(row.names(ext.cfs), round(as.numeric(ext.cfs[,1]), digits = 1)))
      colnames(ext.cfs) <- c("date", "cfs.prec")
      ext.cfs$date <- as.Date(ext.cfs$date, "%Y-%m-%d")
      out <- merge(out, ext.cfs, by = "date", all.x = TRUE)
      # Extract ECMWF data
      sub.ecmwf <- ecmwf[[as.character(out$date)]]
      ext.ecmwf <- as.data.frame(t(terra::extract(sub.ecmwf, terra::vect(data.frame("x" = as.numeric(x), "y" = as.numeric(y)), geom=c("x", "y")))))
      ext.ecmwf <- as.data.frame(cbind(row.names(ext.ecmwf), round(as.numeric(ext.ecmwf[,1]), digits = 1)))
      colnames(ext.ecmwf) <- c("date", "ecmwf.prec")
      ext.ecmwf$date <- as.Date(ext.ecmwf$date, "%Y-%m-%d")
      out <- merge(out, ext.ecmwf, by = "date", all.x = TRUE)
      # Write output
      write.table(out, paste0("~/TRANSFORM/egb/wfmi/data/processed/LeadTimes/", sn, "..", year, "..",
                              ifelse(month == "01", "LT0",
                                     ifelse(month == "02", "LT1", "LT2")),
                              ".csv"),
                  row.names = FALSE, sep = ",")
    }
  }
}

# Structure according to Winifred's request (17/02/2023)
for (s in sts.names) {
  sn <- gsub("\\.", "-", s)
  x <- st.xy[st.xy$name == s, "X"]
  y <- st.xy[st.xy$name == s, "Y"]
  if(length(x) == 0 | length(y) == 0){
    next
  }
  st <- sts[!(is.na(sts[s]) | sts[s]==""), c("date", s)] # Remove empty rows for each station and subset
    for (lt in c("LT0", "LT1", "LT2")){
      files <- intersect(list.files("~/TRANSFORM/egb/wfmi/data/processed/LeadTimes", pattern = sn, full.names = TRUE),
                         list.files("~/TRANSFORM/egb/wfmi/data/processed/LeadTimes", pattern = lt, full.names = TRUE))
      o <- data.frame("date" = NA, "gauge.prec" = NA, "cfs.prec" = NA, "ecmwf.prec" = NA)
      for (file in files) {
        oo <- read.csv(file)
        o <- rbind(o, oo)
        o <- o[1:nrow(o),]
      }
      o <- o[2:nrow(o),]
      write.table(o, paste0("~/TRANSFORM/egb/wfmi/data/processed/LeadTimesWinifred/", sn, "..", lt, ".csv"), row.names = FALSE, sep = ",")
    }
}


