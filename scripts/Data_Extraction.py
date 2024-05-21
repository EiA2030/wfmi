#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 12:35:35 2022

@author: Dr. Atiah
"""


import os
import glob
from netCDF4 import Dataset
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


##Reading observation Data

path = os.getcwd()
#stations = []
##################    Model  data: cfs #########################
df= pd.read_csv('prec-filtered_alt.csv') 
list_of_stations = df.columns
stats=list_of_stations[1:]
stas=list_of_stations[:]

rain = []

###Looping thorugh all stations data for Model data
for st in stats:
    
    file = path+'/MOdel_data/cfs/all/'+str(st)+'_out.nc'

    data = Dataset(file,'r')
        
    prec = data.variables['Band1'][:]
    prec[prec<0]=np.nan
    pp=np.average(prec,axis=1)
    pp1=np.average(pp,axis=1)

    rain.append(pp1)


    rains=np.transpose(rain)
                   
                   

df1 = pd.DataFrame(rains,columns = stats)


df1.to_csv('MOdel_data/cfs/all/all_data.csv',index=True)


df2= pd.read_csv('prec-filtered_alt.csv',parse_dates=[0], index_col=0)

dates=[]
for yy in range(2012,2023):
    if yy != 2017:

        dd=df2.loc[str(yy)+'-01-01' : str(yy)+'-07-01']
       
        if yy==2022:
            dd=df2.loc[str(yy)+'-01-02' : str(yy)+'-05-31']
            #dates.append(dd)
    
        dates.append(dd)
        

    df222=pd.concat(dates, ignore_index=True)

df222.to_csv("Gauge_data/all_years_cfs.csv", index=True)

print(df222)


###### PAIRING MODEL AND GAUGE BY STATION
dfm=pd.read_csv('MOdel_data/cfs/all/all_data.csv') 
    
dfg=pd.read_csv('Gauge_data/all_years_cfs.csv')
     
for stat in stats:
    head1=['gauge']
    dfg[str(stat)].columns = head1
    dfm[str(stat)].columns ='cfs'
    #dfm[str(stat)].set_axis= ['cfs']
    df_rows = pd.concat([dfg[str(stat)], dfm[str(stat)]],axis=1) ##SIDE BY SIDE
    df_rows.columns =['gauge','cfs']
    df_rows.to_csv("Guage_CFS/all/"+str(stat)+".csv")
print(df_rows)







df4.to_csv('Gauge_data/misses.csv')
    #plt.show()
    
'''
