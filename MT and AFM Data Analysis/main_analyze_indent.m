% This main function is used to calculate recorded young's modulus using
% linear curve fitting

%% clear
clear all;
close all
clearvars -global

% initialize
global select_extend1_withdraw2     %
global re_select_roi_N0_L1_C2       % -1 auto, 2 manul 
global show_figure_on1_off0
show_figure_on1_off0=1

re_select_roi_N0_L1_C2=2            % set everything manul
InMain_select_extend1_withdraw2=1  

select_extend1_withdraw2=InMain_select_extend1_withdraw2

% set parameters for both tip and sample
para.indent_data_length=1024;   % length of indent length
para.R=17500                    % tip radius of the probe, in nanometer
para.v_sample=0.4;              % poisson ratio of the sample
para.v_tip=0.5;                 % consider the conflict of both tip and sample
para.E_tip=135;                 % young's modulus of the tip Gpa  
%% load data
pa = 'C:\Users\...'

filename='*.txt' 
[filename,pa]=uigetfile([pa filename])
% load txt in column
 
%define a global pathway  
global pfn   
FN=dir([pa filename])
pfn=[pa FN.name]

% z_piezo_NM:height in nm, prc_readout: force in pN 
[z_piezo_NM,brucker_readout,z_tip_NM,paras]=read_indentation_file_brucker(pfn);

% show data
show_indentation_data(z_piezo_NM,brucker_readout);
% show_indentation_data(prc_readout,z_piezo_NM);

%% level_indentation_data
[z_piezo_NM_c,brucker_readout_adjusted_c,z_tip_NM_c] = level_indentation_data(z_piezo_NM,brucker_readout,z_tip_NM);
Displacement=z_piezo_NM_c{select_extend1_withdraw2}-z_tip_NM_c{select_extend1_withdraw2};      % convert and use extend data
Force=brucker_readout_adjusted_c{select_extend1_withdraw2};   % convert and use extend data

%% select select indentation roi, this ROI will be used to calculate Young's modulus
[sDisplacement,sForce,ind]=manual_select_line_roi(Displacement,Force,'select indentation roi',para.indent_data_length,'brucker');
[Esample,EL,EH,cfL,gofR2]=fit_youngs_modulus_linear(sDisplacement,sForce,para,0,1)
            
 %% save data 
 % define a struct named youngs and save all the variables related to youngs
    youngs.Esample = Esample;
    youngs.EL = EL;
    youngs.cfL = cfL;
    youngs.gofR2 = gofR2;
    youngs.sDisplacement = sDisplacement;
    youngs.sForce = sForce; 
    
    cd('C:\Users\...');
    save( 'spot1.mat', 'youngs');
    cd('C:\Users\...')

