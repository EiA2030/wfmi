#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 14 15:05:58 2022

@author: Dr. Atiah
"""



import glob
import pandas as pd  
import matplotlib.pyplot as plt
import numpy as np

import math
from scipy.stats.stats import pearsonr





####################################################
#		Mean
####################################################

def mean(x):
    return np.mean(x)



####################################################
#		Power
####################################################

def power(x,y):
    return x**y


	
####################################################
#	size inverse (sz_inv) (1/N)
####################################################

def sz_inv(x):
    return 1./(len(x))


####################################################
#	Mean Error (m_err)
####################################################

def m_err(x,y):
    return sz_inv(x)*sum(abs(x-y))



####################################################
#	Root Mean Square Error (RMS)
####################################################

def rms(x,y):
    return (np.sqrt(sz_inv(x)*sum(power((x-y),2))))/np.nanmean(y)



	
####################################################
#		Efficiency (eff)
####################################################

def eff(x,y):
    return 1-(sum(power((x-y),2))/sum(power((y-np.mean(y)),2)))


	
####################################################
#		Bias
####################################################

def bias(x,y):
    
    return np.nanmean(y)/np.nanmean(x)
    




def hits(gauge, sat, thresh):
    obs_RD = gauge.where(gauge>0)
    sat_RD = sat.where(sat>0)
    return sat_RD.where(obs_RD>0).count()

def missed(gauge, sat, thresh):
    obs_RD = gauge.where(gauge>0)
    sat_RD = sat.where(sat<=0)
    return sat_RD.where(obs_RD>0).count()

def false(gauge, sat, thresh):
    obs_RD = gauge.where(gauge<=0)
    sat_RD = sat.where(sat>0)
    return sat_RD.where(obs_RD<=0).count()

def pod(h,m):
    return h/(h+m)

def csi(h,f,m):
    return h/(h+m+f)

def far(f,h):
    return f/(f+h)

def FBI(h,f,m):
    return (h+f)/(h+m)


#nas=np.logical_or(np.isnan(gauge), np.isnan(CFS))


#########################################################################
## USAGE OF FUNCTIONS BEGINS HERE
#########################################################################
#####Reading data Cordinates
cds = pd.read_csv('cords_176.csv')
lons = cds['X']
lats = cds['Y']
llo=lons.to_frame()
lla=lats.to_frame()
a=np.transpose(llo)
llons=list(a)

                                                                                                                                                                                                                                                                                                                                                    
df= pd.read_csv('prec-filtered_alt.csv')
list_of_stations = df.columns
stats=list_of_stations[1:]
avail_stats=[]

pods=[]
fars=[]
biass=[]
stass=[]
csii=[]
fbii=[]
cor=[]
rmse=[]
for stat in stats:
    prec = pd.read_csv("Guage_CFS/all/"+str(stat)+".csv")
       
    if  not prec['gauge'].empty:
        #fff=prec['gauge'].dropna(how='any')
        gauge = prec.gauge
        CFS = prec.cfs
    
        #cor= gauge.corr(CFS)
        
        
        H = hits(gauge, CFS,   0.99)
        M = missed(gauge, CFS, 0.99)
        F = false(gauge, CFS,  0.99)
        
        
        PoD = pod(H,M)
        cSi = csi(H,F,M)
        fbi = FBI(H,F,M)
        FaR = far(F,H)
        bs = bias(gauge,CFS)
        rm = m_err(gauge,CFS)

        pods.append(PoD)
        fars.append(FaR)
        biass.append(bs)
        stass.append(stat)
        #rmss.append(rm)
        csii.append(cSi)
        fbii.append(fbi)
        
        ######Correlation
        
        nas=np.logical_or(np.isnan(gauge), np.isnan(CFS))
        if  not len(gauge[~nas])==0:
            corr = pearsonr(gauge[~nas], CFS[~nas])
        if  not len(gauge[~nas])>0:
        
            corr=np.nan,np.nan
            
        if  not len([~nas])>0:
            corr=np.nan,np.nan
        cor.append(corr[0])
            
        mse=np.square(np.subtract(gauge,CFS)).mean()
        mr=math.sqrt(mse)
        rmse.append(mr)
            
            
     
    
        s_0=pd.Series(lons)
        s_1=pd.Series(lats)
        s0 = pd.Series(stass)
        s1=pd.Series(pods)
        s2=pd.Series(fars)
        s3=pd.Series(biass)
        s4=pd.Series(csii)
        s5=pd.Series(fbii)
        s6=pd.Series(cor)
        s7=pd.Series(rmse)
            
        
        sta_list = pd.concat([s_0,s_1,s0,s1,s2,s3,s4,s5,s6,s7], axis=1) 
        cols = ['lons','lats','names','POD','FAR','BIAS','CSI','FBI','r','RMSE']
        dfsts = pd.DataFrame(sta_list)
        #### Rename Columns
        dfsts.set_axis(cols, axis=1,inplace=True)
        dfsts.to_csv("Maps/yy_yy/all_stats_CFS.csv")
  
