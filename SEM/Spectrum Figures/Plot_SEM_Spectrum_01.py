# -*- coding: utf-8 -*-
"""
Created on Fri Jan 21 10:02:15 2022

@author: VACALDER
"""

import matplotlib.pyplot as plt
import numpy as np


spectrum_file = r'CL10_B_200_Spectrum_5.txt'


with open(spectrum_file) as datafile:
    data = datafile.readlines()[50:-1]



    
x = [line.split(',')[0] for line in data]
y = [line.split(',')[1] for line in data]

energy = [float(i) for i in x]
counts = [float(i) for i in y]


c_counts = np.interp(0.277, energy, counts)      #OXINSTLABEL: 6, 0.277, C
fe1_counts = np.interp(0.615, energy, counts)    #OXINSTLABEL: 26, 0.615, Fe
fe2_counts = np.interp(0.703, energy, counts)    #OXINSTLABEL: 26, 0.703, Fe
fe3_counts = np.interp(6.404, energy, counts)    #OXINSTLABEL: 26, 6.404, Fe
fe4_counts = np.interp(7.058, energy, counts)    #OXINSTLABEL: 26, 7.058, Fe
Mn1_counts = np.interp(5.899, energy, counts)    #OXINSTLABEL: 25, 5.899, Mn
Mn2_counts = np.interp(6.490, energy, counts)    #OXINSTLABEL: 25, 6.490, Mn
Mn3_counts = np.interp(0.636, energy, counts)    #OXINSTLABEL: 25, 0.636, Mn
Mn4_counts = np.interp(0.556, energy, counts)    #OXINSTLABEL: 25, 0.556, Mn
Si_counts = np.interp(1.740, energy, counts)     #OXINSTLABEL: 14, 1.740, Si
S1_counts = np.interp(2.308, energy, counts)     #OXINSTLABEL: 16, 2.308, S
S2_counts = np.interp(2.464, energy, counts)     #OXINSTLABEL: 16, 2.464, S
Cr1_counts = np.interp(5.416, energy, counts)    #OXINSTLABEL: 24, 5.415, Cr
Cr2_counts = np.interp(5.947, energy, counts)    #OXINSTLABEL: 24, 5.947, Cr
Cr3_counts = np.interp(0.573, energy, counts)    #OXINSTLABEL: 24, 0.573, Cr
Cr4_counts = np.interp(0.500, energy, counts)    #OXINSTLABEL: 24, 0.500, Cr
V1_counts = np.interp(4.952, energy, counts)     #OXINSTLABEL: 23, 4.952, V
V2_counts = np.interp(5.427, energy, counts)     #OXINSTLABEL: 23, 5.427, V
V3_counts = np.interp(0.511, energy, counts)     #OXINSTLABEL: 23, 0.511, V
V4_counts = np.interp(0.446, energy, counts)     #OXINSTLABEL: 23, 0.446, V


counts_plot= [i/1000 for i in counts]

plt.rcParams.update({'font.family':'serif'})
plt.rcParams.update({'font.serif':'Times New Roman'})
plt.figure(figsize=(3.0,2.5),frameon=False)


plt.plot(energy,counts_plot,color="#d94545")
plt.xlim(0,10)
plt.ylim(0,25)
plt.xlabel('Energy (keV)', fontsize=11)
plt.ylabel('Counts (x10$^3$)', fontsize=11)
plt.tick_params(direction='out',axis='both',labelsize=10)
plt.text(0.277-0.15, c_counts/1000, "C")      #OXINSTLABEL: 6, 0.277, C
plt.text(0.615-0.215, fe1_counts/1000, "Fe")   #OXINSTLABEL: 26, 0.615, Fe
plt.text(0.703, fe2_counts/1000, "Fe")   #OXINSTLABEL: 26, 0.703, Fe
plt.text(6.404, fe3_counts/1000, "Fe")   #OXINSTLABEL: 26, 6.404, Fe
plt.text(7.058, fe4_counts/1000,"Fe")    #OXINSTLABEL: 26, 7.058, Fe
plt.text(5.899, Mn1_counts/1000, "Mn")   #OXINSTLABEL: 25, 5.899, Mn
#plt.text(6.490, Mn2_counts, "Mn")   #OXINSTLABEL: 25, 6.490, Mn
#plt.text(0.636, Mn3_counts, "Mn")   #OXINSTLABEL: 25, 0.636, Mn
#plt.text(0.556, Mn4_counts, "Mn")   #OXINSTLABEL: 25, 0.556, Mn
plt.text(1.740, Si_counts/1000, "Si")    #OXINSTLABEL: 14, 1.740, Si
plt.text(2.308, S1_counts/1000, "S")    #OXINSTLABEL: 16, 2.308, S
#plt.text(2.464, S2_counts, "S")     #OXINSTLABEL: 16, 2.464, S
plt.text(5.416,Cr1_counts/1000, "Cr")    ##OXINSTLABEL: 24, 5.415, Cr
#plt.text(5.947, Cr2_counts , "Cr")  #OXINSTLABEL: 24, 5.947, Cr
#plt.text(0.573, Cr3_counts, "Cr")   #OXINSTLABEL: 24, 0.573, Cr
#plt.text(0.500, Cr4_counts, "Cr")   #OXINSTLABEL: 24, 0.500, Cr
plt.text(4.952, V1_counts/1000, "V")     ##OXINSTLABEL: 23, 4.952, V
#plt.text(5.427, V2_counts, "V")     ##OXINSTLABEL: 23, 5.427, V
plt.text(0.511, V3_counts/1000, "V")     ##OXINSTLABEL: 23, 0.511, V
#plt.text(0.446, V4_counts, "V")     ##OXINSTLABEL: 23, 0.446, V
plt.grid()
plt.savefig("Spectrum5.pdf",dpi=600,bbox_inches='tight', pad_inches=0)