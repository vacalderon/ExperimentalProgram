# -*- coding: utf-8 -*-
"""
Created on Fri Sep 24 15:20:29 2021

@author: VACALDER
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# INPUTS 

number_of_markers=10
number_of_gages=number_of_markers-1
markers_id=[1,2,3,4,5,6,7,8,9,10]
optotrakfile='TDPBSE_CL5_T-1_2021_09_24_115825_001_3d.csv'
optotrak_df=pd.read_csv(optotrakfile, skiprows = 4)
counter =0
L0=[]
with open(optotrakfile) as f:
    first_line = f.readline()
number_of_points=int(first_line[18:22])
strain=np.empty([number_of_points,number_of_gages])
diameter_of_bar=0.7291
force_file='CL5-T2.txt'
Force=[]
f=open(force_file)
linesf = f.readlines()
F = [line.split() for line in linesf]
number_of_force_points =len(F)
stresses=[]
color=['#CC0000','#D14905','cyan','#6F7D1C','#427E93','#4156A1']

# DATA ANALYSIS

for i in range(0,number_of_gages-1):
    print(i)
    counter=counter+1
    print('counter=',counter)
    x1 = optotrak_df['Marker_'+str(counter)+" x"].values
    y1 = optotrak_df['Marker_'+str(counter)+" y"].values
    z1 = optotrak_df['Marker_'+str(counter)+" z"].values
    
    x2 = optotrak_df['Marker_'+str(counter+1)+" x"].values
    y2 = optotrak_df['Marker_'+str(counter+1)+" y"].values
    z2 = optotrak_df['Marker_'+str(counter+1)+" z"].values
    for j in range(0,4):
        Linit=np.sqrt((x2[j]-x1[j])**2+(y2[j]-y1[j])**2+(z2[j]-z1[j])**2)
        L0.append(Linit)
    Lnaught=np.average(L0)
    for k in range(5,number_of_points):
        deltaL=np.sqrt((x2[k]-x1[k])**2+(y2[k]-y1[k])**2+(z2[k]-z1[k])**2)
        strain[k,i]=(deltaL-Lnaught)/Lnaught
        
    L0=[]



for q in range(8,number_of_force_points-1):
    Force.append(float(F[q][2]))
    stresses.append(Force[q-8]/(0.25*np.pi*diameter_of_bar**2))
    

# PLOTTING DATA
for i in range(0,number_of_gages-1):
    plt.figure(1)
    plt.plot(strain[0:(number_of_force_points-9),i],stresses)
    plt.xlim(0,0.15)
    plt.ylim(0,120)
    plt.title('Stress Strain', fontsize=32)
    plt.xlabel('Strain (in/in)', fontsize=24)
    plt.ylabel(r'stress, $\sigma$ (ksi)', fontsize=24)
    plt.tick_params(direction='out',axis='both',labelsize=20)
    plt.grid()
plt.show() 
