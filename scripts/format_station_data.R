require(doParallel)
# Set number of parallel workers
cls <- parallel::makePSOCKcluster(16)
doParallel::registerDoParallel(cls)

origin <- "/home/jovyan/TRANSFORM/egb/wfmi/"
setwd(origin)

#  Load station db
dt <- data.table::fread("./data/station/station_db.csv")
# Set indexes on table
data.table::setkeyv(dt, c("date", "name"))

# Source functions to download forecast data
source('./02_ncei_download.R')

# Source functions to process forecast data
source('./04_format_forecast_data.R')

# Create list of weather stations
stations <- unique(dt$name)

# Loop through all stations
# for (station in stations[1:5]){
foreach::foreach(i=seq_along(stations), .export = '.GlobalEnv', .inorder = TRUE, .packages = c("tidyverse")) %dopar% {
  station <- stations[i]
  dir.create(paste0("/home/jovyan/TRANSFORM/egb/wfmi/data/forecast/ncei/", station), showWarnings = FALSE)
  # print(paste0("########################## - ", station, " - ##########################"))
  data <- dt[dt$name == station,]
  # Calculate SOS
  rain.year <- data %>%
    group_by(year = lubridate::year(date)) %>%
    summarise_if(is.numeric, sum, na.rm = TRUE)
  for (i in seq_along(rain.year$year)) {
    year <- rain.year$year[i]
    ann.prec <- rain.year$prec[i]
    if (!is.na(year) & year >= 2016 & year <= 2017){ # For now filtering between 2011 & 2013
      dir.create(paste("/home/jovyan/TRANSFORM/egb/wfmi/data/forecast/ncei", station, year, sep = "/"), showWarnings = FALSE)
      daily <- data[data$date >= as.Date(paste0(year,"-01-01")) & data$date <= as.Date(paste0(year,"-12-31")),]
      sos <- length(which(cumsum(daily$prec) <= ann.prec*0.05))
      sos <- daily$date[sos]
      ground <- daily[daily$date >= as.Date(sos) & daily$date <= as.Date(sos)+180,]
      # print(paste0("For ", station, " the SOS in ", year, " happens on ", sos))
      # Download NOAA data from SOS
      setwd(paste("/home/jovyan/TRANSFORM/egb/wfmi/data/forecast/ncei", station, year, sep = "/"))
      dir.create("data", showWarnings = FALSE)
      download.noaa(sos)
      setwd(origin)
      x <- unique(ground$X)
      y <- unique(ground$Y)
      forecast <- data.table::setkeyv(data.table::as.data.table(ncei_format(x = x, y = y)), c("date"))
      forecast <- forecast[forecast$date >= as.Date(sos) & forecast$date <= as.Date(sos)+180,]
      # plot(ground$prec, forecast$prec)
      out <- data.frame("date" = forecast$date, "obs" = ground$prec, "sim" = forecast$prec, "x" = x, "y" = y, "station" = station)
      write.table(out, paste0("./data/processed/NCEI_NOAA_", station, "_", year, ".csv"), row.names = FALSE, sep = ",")
      # print(paste0("Processed NOAA NCEI into", paste0("./data/processed/NCEI_NOAA_", station, "_", year, ".csv")))
    }
    # else {
    #   print(paste0("No data available for ", station, " in ", year))
    # }
  }
}
