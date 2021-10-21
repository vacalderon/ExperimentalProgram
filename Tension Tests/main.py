# -*- coding: utf-8 -*-
"""
Created on Thu Oct 21 11:32:36 2021

@author: VACALDER
"""
# Program to PostProcess Strain Results from Tension Tests

optroak_files_path=r'C:\ConditionDependentPBEE\ExperimentalProgram\Tension Tests\Optotrak'
daq_files_path=r'C:\ConditionDependentPBEE\ExperimentalProgram\Tension Tests\DAQ'
corrosion_levels=[5,5,10,10,10,20,20,20]
diameters_CL=[0.7116,0.7061,0.7093,0.6911,0.6904,0.6721,0.6721,0.6721]
tension_test_number=[2,3,1,2,3,1,2,3]
import tensionresults

counter=0
for i in corrosion_levels:
    corrosionlevel=i
    diameter_of_bar=diameters_CL[counter]
    test_number=tension_test_number[counter]
    figure_number=counter+1
    optotrakfile=optroak_files_path+'//CL'+str(corrosionlevel)+'-T'+str(test_number)+'_optotrak.csv'
    daq_file=daq_files_path+'//CL'+str(corrosionlevel)+'-T'+str(test_number)+'.txt'
    tensionresults.tensionresults(optotrakfile,daq_file,diameter_of_bar,corrosionlevel,test_number,figure_number)
    counter=counter+1