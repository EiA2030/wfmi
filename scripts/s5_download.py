import numpy as np
import time
import os
import sys
import xarray as xr # Need to install
import cdsapi # Need to install

out = str(sys.argv[8])
year = str(sys.argv[1])
month = str(sys.argv[2])
day = str(sys.argv[3])
xmin = float(sys.argv[4])
ymin = float(sys.argv[5])
xmax = float(sys.argv[6])
ymax = float(sys.argv[7])
area = [ymax, xmin, ymin, xmax,]
# area = [32, -32, -35, 52,]

c = cdsapi.Client()

variables = ['total_precipitation']

for var in variables:
    if var == 'total_precipitation':
        # times = ["{:01d}".format(n) for n in range(24, 5166, 24)]
        times = ["{:01d}".format(n) for n in range(24, 2184, 24)]
    c.retrieve(
        'seasonal-original-single-levels',
        {
            'format': 'netcdf',
            'variable': var,
            'originating_centre': 'ecmwf',
            'system': '5',
            'year': year,
            'month': month,
            'day': '01',
            'leadtime_hour': times,
            'area': area,
        },
        out + '/raw/ecmwf-s5_prec_' + str(year) + str(month) + str(day) + '.nc',
    )
    time.sleep(1)
    if var == 'total_precipitation':
        rain = xr.open_dataset(out + '/raw/ecmwf-s5_prec_' + str(year) + str(month) + str(day) + '.nc')
        rain = rain * 1000
        rain = rain.mean(dim = 'number')
        # rain.to_netcdf('/home/jovyan/common_data/ecmwf_s5-wfmi/intermediate/ecmwf_s5_rain_' + str(year) + '.nc')
        rain.to_netcdf(out + '/intermediate/ecmwf-s5_prec_' + str(year) + str(month) + str(day) + '.nc')
        # os.remove('/home/jovyan/common_data/ecmwf_s5/raw/' + var + '_' + str(year) + '.nc')
  
        
