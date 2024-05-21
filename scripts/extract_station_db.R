dt <- data.table::fread("./data/station/station_db.csv")
data.table::setkeyv(dt, c("date", "name"))

extract <- function(station, var){
  sb <- subset(dt, name == station & !is.na(var))
  sv <- c("date", var)
  sb <- sb[, ..sv]
  v <- paste0('i.', var)
  out[sb, on = 'date', paste0(station) := mget(v)]
}

dates <- seq(as.Date(min(dt$date, na.rm = T)), as.Date(max(dt$date, na.rm = T)), by = "day")
station <- unique(dt$name)
var <- c("prec", "wind", "srad", "tmax", "tmin")

for (v in var){
  out <- data.table::data.table("date" = dates)
  data.table::setkeyv(out, "date")
  for (s in station){
    extract(station = s, var = v)
  }
  write.table(out, paste0("./data/station/", v, ".csv"), row.names = FALSE, sep = ",")
  # Filter DB
  f <- subset(out, date >= as.Date("1993-01-01"))
  write.table(f, paste0("./data/station/", v, "-filtered.csv"), row.names = FALSE, sep = ",")
}

# Extract coordinates of each station
coords <- dt[!duplicated(dt[,c("X", "Y", "name")]),c("X", "Y", "name")]
write.table(coords, "./data/station/coords.csv", row.names = FALSE, sep = ",")
