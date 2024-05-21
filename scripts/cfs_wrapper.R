source("/home/jovyan/TRANSFORM/egb/wfmi/02_ncei_download.R")

c <- read.csv("~/TRANSFORM/egb/wfmi/data/station/coords.csv", sep = ",")
f <- read.csv("~/TRANSFORM/egb/wfmi/data/forecast/Stations_Durations.csv", sep = ",")
cf <- merge(c,f, by = "name")
cf <- cf[!duplicated(cf$name) & cf$start == 2017,]

# for(yr in seq(sort(cf$start)[1], sort(cf$end)[length(sort(cf$start))])){
#   cfs.dwnld(yr = yr)
# }

cfs.dwnld(yr = 2013)

# for(yr in 2012){
#   cfs.dwnld(yr = yr)
# }
