# -*- coding: utf-8 -*-
"""
Created on Thu Oct 21 11:32:36 2021

@author: VACALDER
"""
# Program to PostProcess Strain Results from Tension Tests

optroak_files_path=r'C:\ConditionDependentPBEE\ExperimentalProgram\Tension Tests\Optotrak'
daq_files_path=r'C:\ConditionDependentPBEE\ExperimentalProgram\Tension Tests\DAQ'
corrosion_levels=[1,2]
diameters_CL=[0.5,0.5]
tension_test_number=[1,2]
import tensionresults

counter=0
for i in corrosion_levels:
    corrosionlevel=i
    diameter_of_bar=diameters_CL[counter]
    test_number=tension_test_number[counter]
    figure_number=counter+1
    optotrakfile=optroak_files_path+'//TD''-T'+str(test_number)+'_optotrak.csv'
    daq_file=daq_files_path+'//TD'+'-T'+str(test_number)+'.txt'
    tensionresults.tensionresults(optotrakfile,daq_file,diameter_of_bar,corrosionlevel,test_number,figure_number)
    counter=counter+1