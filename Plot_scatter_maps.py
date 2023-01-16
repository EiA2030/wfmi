#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Dec  3 11:50:13 2022

@author: Dr. Atiah
"""


import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.path import Path
from mpl_toolkits.axes_grid1.inset_locator import zoomed_inset_axes
from mpl_toolkits.axes_grid1.inset_locator import mark_inset
import matplotlib.patches as patches
from mpl_toolkits.axes_grid1 import make_axes_locatable
import numpy as np
import scipy as sp
import os
import pandas as pd

#POD	FAR	BIAS	CSI	FBI	r
df1= pd.read_csv('yy_yy/all_stats_CFS.csv')

df2= pd.read_csv('yy_yy/all_stats_ECMWF.csv')



lons = df1['lons']
lats = df1['lats']

r= df1['r']
bias=df1['BIAS']
rmse= df1['RMSE']

r1= df2['r']
bias1=df2['BIAS']
rmse1= df2['RMSE']


path = os.getcwd()
spc=0.5
lat_beg=0
lat_end=30
lon_beg=-20
lon_end=15

fig = plt.figure(figsize=(14,7))
fig.subplots_adjust(hspace=0.01,wspace=0.05)
plt.subplot(2,3,1)
plt.title('CC',fontsize=12)

plt.ylabel('CFS',labelpad=26, fontsize=12)
ax = plt.gca()
divider = make_axes_locatable(ax)
##plt.title('(a)',fontsize=12)
map3 = Basemap(projection='merc',llcrnrlon= -20, llcrnrlat=-40, urcrnrlon=50, urcrnrlat=20,resolution='i')
map3.drawmapboundary(fill_color='white')
map3.drawcountries(linewidth=1)
map3.drawcoastlines(linewidth=1)
parallels = np.arange(-40,20,10) # make latitude lines ever 5 degrees from 30N-50N
meridians = np.arange(-20,50,20)
map3.drawparallels(parallels,labels=[1,0,0,0],fontsize=10,linewidth=1)
map3.drawmeridians(meridians,labels=[0,0,0,0],fontsize=10,linewidth=1)
x,y=map3(lons,lats)
#x,y=map3(lons,lats)
#x,y=map3(lons,lats)
ss=plt.scatter(x,y,c=r,marker='o',alpha=1,s=200,
cmap='plasma',vmin=-0.27,vmax=1)
#plt.set_label('Days', labelpad=-27, y=1.06, rotation=0,fontsize=10)


fig.subplots_adjust(hspace=0.01,wspace=0.05)
plt.subplot(2,3,2)
plt.title('BIAS',fontsize=12)
#plt.ylabel('CHIRPS',labelpad=24, fontsize=10)
ax = plt.gca()
divider = make_axes_locatable(ax)
##plt.title('(a)',fontsize=12)
map3 = Basemap(projection='merc',llcrnrlon= -20, llcrnrlat=-40, urcrnrlon=50, urcrnrlat=20,resolution='i')
map3.drawmapboundary(fill_color='white')
map3.drawcountries(linewidth=1)
map3.drawcoastlines(linewidth=1)
parallels = np.arange(-40,20,10) # make latitude lines ever 5 degrees from 30N-50N
meridians = np.arange(-20,50,20)
map3.drawparallels(parallels,labels=[0,0,0,0],fontsize=10,linewidth=1)
map3.drawmeridians(meridians,labels=[0,0,0,0],fontsize=10,linewidth=1)

x,y=map3(lons,lats)
#x,y=map3(lons,lats)

#x,y=map3(lons,lats)
ss=plt.scatter(x,y,c=bias,marker='o',alpha=1,s=200,
cmap='plasma',vmin=-0,vmax=40)


fig.subplots_adjust(hspace=0.01,wspace=0.05)
plt.subplot(2,3,3)
plt.title('RMSE',fontsize=12)
#plt.ylabel('CHIRPS',labelpad=24, fontsize=10)
ax = plt.gca()
divider = make_axes_locatable(ax)
##plt.title('(a)',fontsize=12)
map3 = Basemap(projection='merc',llcrnrlon= -20, llcrnrlat=-40, urcrnrlon=50, urcrnrlat=20,resolution='i')
map3.drawmapboundary(fill_color='white')
map3.drawcountries(linewidth=1)
map3.drawcoastlines(linewidth=1)
parallels = np.arange(-40,20,10) # make latitude lines ever 5 degrees from 30N-50N
meridians = np.arange(-20,50,20)
map3.drawparallels(parallels,labels=[0,0,0,0],fontsize=10,linewidth=1)
map3.drawmeridians(meridians,labels=[0,0,0,0],fontsize=10,linewidth=1)

x,y=map3(lons,lats)
#x,y=map3(lons,lats)

#x,y=map3(lons,lats)
ss=plt.scatter(x,y,c=rmse,marker='o',alpha=1,s=200,
cmap='plasma',vmin=0,vmax=24)




fig.subplots_adjust(hspace=0.01,wspace=0.05)
plt.subplot(2,3,4)
#plt.title('POD',fontsize=12)
#plt.ylabel('CHIRPS',labelpad=24, fontsize=10)
ax = plt.gca()
divider = make_axes_locatable(ax)
##plt.title('(a)',fontsize=12)
map3 = Basemap(projection='merc',llcrnrlon= -20, llcrnrlat=-40, urcrnrlon=50, urcrnrlat=20,resolution='i')
map3.drawmapboundary(fill_color='white')
map3.drawcountries(linewidth=1)
map3.drawcoastlines(linewidth=1)
parallels = np.arange(-40,20,10) # make latitude lines ever 5 degrees from 30N-50N
meridians = np.arange(-20,50,20)
map3.drawparallels(parallels,labels=[1,0,0,0],fontsize=10,linewidth=1)
map3.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10,linewidth=1)
plt.ylabel('ECWMF',labelpad=26, fontsize=12)

x,y=map3(lons,lats)
#x,y=map3(lons,lats)

#x,y=map3(lons,lats)
ss=plt.scatter(x,y,c=r1,marker='o',alpha=1,s=200,
cmap='plasma',vmin=-0.27,vmax=1)
cbar_ax = fig.add_axes([0.32, 0.04, 0.014, 0.90])
cb=fig.colorbar(ss,cax=cbar_ax,extend="both")
#cb.set_label('mm', labelpad=-47, y=1.07, rotation=0,fontsize=10)
    
    
    

fig.subplots_adjust(hspace=0.01,wspace=0.05)
plt.subplot(2,3,5)
#plt.title('CSI',fontsize=12)
#plt.ylabel('CHIRPS',labelpad=24, fontsize=10)
ax = plt.gca()
divider = make_axes_locatable(ax)
##plt.title('(a)',fontsize=12)
map3 = Basemap(projection='merc',llcrnrlon= -20, llcrnrlat=-40, urcrnrlon=50, urcrnrlat=20,resolution='i')
map3.drawmapboundary(fill_color='white')
map3.drawcountries(linewidth=1)
map3.drawcoastlines(linewidth=1)
parallels = np.arange(-40,20,10) # make latitude lines ever 5 degrees from 30N-50N
meridians = np.arange(-20,50,20)
map3.drawparallels(parallels,labels=[0,0,0,0],fontsize=10,linewidth=1)
map3.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10,linewidth=1)

x,y=map3(lons,lats)
#x,y=map3(lons,lats)
#plt.ylabel('ECMWF',labelpad=26, fontsize=12)

#x,y=map3(lons,lats)
ss22=plt.scatter(x,y,c=bias1,marker='o',alpha=1,s=200,
cmap='plasma',vmin=0,vmax=40)

#cb.set_label('mm', labelpad=-47, y=1.07, rotation=0,fontsize=10)


fig.subplots_adjust(hspace=0.01,wspace=0.05)
plt.subplot(2,3,6)
#plt.title('FAR',fontsize=12)
#plt.ylabel('CHIRPS',labelpad=24, fontsize=10)
ax = plt.gca()
divider = make_axes_locatable(ax)
##plt.title('(a)',fontsize=12)
map3 = Basemap(projection='merc',llcrnrlon= -20, llcrnrlat=-40, urcrnrlon=50, urcrnrlat=20,resolution='i')
map3.drawmapboundary(fill_color='white')
map3.drawcountries(linewidth=1)
map3.drawcoastlines(linewidth=1)
parallels = np.arange(-40,20,10) # make latitude lines ever 5 degrees from 30N-50N
meridians = np.arange(-20,50,20)
map3.drawparallels(parallels,labels=[0,0,0,0],fontsize=10,linewidth=1)
map3.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10,linewidth=1)

x,y=map3(lons,lats)
#x,y=map3(lons,lats)

#x,y=map3(lons,lats)
ss=plt.scatter(x,y,c=rmse1,marker='o',alpha=1,s=200,
cmap='plasma',vmin=0,vmax=24)
cbar_ax = fig.add_axes([0.95, 0.04, 0.014, 0.9])
cb=fig.colorbar(ss,cax=cbar_ax,extend="both")

cbar_ax = fig.add_axes([0.63, 0.04, 0.014, 0.9])
cb=fig.colorbar(ss22,cax=cbar_ax,extend="both")















