# -*- coding: utf-8 -*-
"""
Created on Fri Sep 24 15:20:29 2021

@author: VACALDER
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def tensionresults(optotrakfile,daq_file,diameter_of_bar,corrosionlevel,test_number,figure_number):
# INPUTS 

    
    optotrak_df=pd.read_csv(optotrakfile, skiprows = 4)
    number_of_markers=int((len(optotrak_df.columns)-1)/3)
    number_of_gages=number_of_markers-1
    markers_id=np.linspace(1,number_of_markers,num=number_of_markers)
    
    L0=[]
    with open(optotrakfile) as f:
        first_line = f.readline()
    number_of_points=int(first_line[18:22])

    strain=np.empty([number_of_points,number_of_gages])


    Force=[]
    f=open(daq_file)
    linesf = f.readlines()
    F = [line.split() for line in linesf]
    number_of_force_points =len(F)
    stresses=[]
    color=['#CC0000','#D14905','cyan','#6F7D1C','#427E93','#4156A1']
    complete_data_points=min(number_of_force_points-2,number_of_points)
    
    # DATA ANALYSIS
    counter =0
    for i in range(0,number_of_gages-1):
        counter=counter+1
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

    print(complete_data_points) 
    for q in range(8,complete_data_points):
        #print(q)
        Force.append(float(F[q][2]))
        stresses.append(Force[q-8]/(0.25*np.pi*diameter_of_bar**2))

    complete_data_points=len(stresses)
    # PLOTTING DATA
    for i in range(0,number_of_gages-1):
        plt.figure(figure_number)
        plt.plot(strain[0:complete_data_points,i],stresses[0:complete_data_points])
        plt.xlim(0,0.15)
        plt.ylim(0,120)
        plt.title('Stress Strain', fontsize=32)
        plt.xlabel('Strain (in/in)', fontsize=24)
        plt.ylabel(r'stress, $\sigma$ (ksi)', fontsize=24)
        plt.tick_params(direction='out',axis='both',labelsize=20)
        plt.grid()
    plt.show() 
    
    # EXPORTING DATA
    
    data_dictionary={'stress':stresses[0:complete_data_points],
                     'strain_1':strain[0:complete_data_points,1],
                     'strain_2':strain[0:complete_data_points,2],
                     'strain_3':strain[0:complete_data_points,3],
                     'strain_4':strain[0:complete_data_points,4],
                     'strain_5':strain[0:complete_data_points,5],
                     'strain_6':strain[0:complete_data_points,6],
                     'strain_7':strain[0:complete_data_points,7]}    
    
    data_frame_out=pd.DataFrame(data_dictionary)
    data_frame_out.to_csv('stress_strain_CL'+str(corrosionlevel)+'-test_'+str(test_number)+'.csv')