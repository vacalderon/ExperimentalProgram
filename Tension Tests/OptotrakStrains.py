# -*- coding: utf-8 -*-
"""
Created on Fri Sep 24 15:20:29 2021

@author: VACALDER
"""
import pandas as pd
import numpy as np
number_of_markers=10
markers_id=[1,2,3,4,5,6,7,8,9,10]
optotrakfile='TDPBSE_CL5_T-1_2021_09_24_115825_001_3d.csv'
optotrak_df=pd.read_csv(optotrakfile, skiprows = 4)

SG1=[]

# Obtain average start position for each marker

marker1ypos = optotrak_df['Marker_1 y'].values
marker2ypos = optotrak_df['Marker_2 y'].values
marker3ypos = optotrak_df['Marker_3 y'].values
marker4ypos = optotrak_df['Marker_4 y'].values
marker5ypos = optotrak_df['Marker_5 y'].values
marker6ypos = optotrak_df['Marker_6 y'].values
marker7ypos = optotrak_df['Marker_7 y'].values
marker8ypos = optotrak_df['Marker_8 y'].values
marker9ypos = optotrak_df['Marker_9 y'].values
marker10ypos = optotrak_df['Marker_10 y'].values
number_of_points=len(marker1ypos)

marker1_init_y=np.average(marker1ypos[0:4])
marker2_init_y=np.average(marker2ypos[0:4])
marker3_init_y=np.average(marker3ypos[0:4])
marker4_init_y=np.average(marker4ypos[0:4])
marker5_init_y=np.average(marker5ypos[0:4])
marker6_init_y=np.average(marker6ypos[0:4])
marker7_init_y=np.average(marker7ypos[0:4])
marker8_init_y=np.average(marker8ypos[0:4])
marker9_init_y=np.average(marker9ypos[0:4])
marker10_init_y=np.average(marker10ypos[0:4])

for i in range(5,number_of_points):
    SG1.append((marker2ypos[i]-marker1ypos[i]-(marker2_init_y-marker1_init_y))/(marker2_init_y-marker1_init_y))
