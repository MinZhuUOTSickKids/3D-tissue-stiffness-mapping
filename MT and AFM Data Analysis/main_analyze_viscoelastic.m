% This main function is used to calculate viscoelastic properties using SLS
% with a serial dashpot

%% clear
clear all;
close all
clearvars -global

para.v_sample=0.4;             % posion ratio of the sample
para.force=200;                % force in pN
para.diameter=2.8;             % diameter of the bead
para.indent_data_length=1024;  % length of indent length
para.time=1;                   % time interval in seconds
% load data as X and Y coordinates of the bead in um

%% calculate displacement vs time
for i=1:1:(length(X)-1)
    Displacement(i)=sqrt((X(i+1)-X(1))^2+(Y(i+1)-Y(1))^2);
end
Time=0:para.time:(length(X)-2);
Time=Time';
plot(Time,Displacement);
set(gca,'FontSize',15);
xlabel('Time (s)','FontSize',15);
ylabel('Displacement (microns)','FontSize',15);
box on

%% select select indentation roi, this ROI will be used to calculate elastic modulus
[eTime,eDisplacement,ind]=manual_select_line_roi(Time,Displacement,'select indentation roi',para.indent_data_length,'brucker'); 
fDisplacement=eDisplacement(end)-eDisplacement(1);
K=para.force/(fDisplacement*3*pi*para.diameter);  
Esample=2*K*(1+para.v_sample); %Elastic modulus in pa

%% select select indentation roi, this ROI will be used to calculate viscosity
[vTime,vDisplacement,ind]=manual_select_line_roi(Time,Displacement,'select indentation roi',para.indent_data_length,'brucker');
vDisplacement=vDisplacement*3*pi*para.diameter/para.force;
vTime=vTime-eTime(1);
[cfL,gof]=createFit_line_poly_N(vTime, vDisplacement,1);
v0=1/cfL.p1; %Viscosity in pas
Result=[Esample v0];

 %% full fitting tp decouple all the parameters
[vTime,vDisplacement,ind]=manual_select_line_roi(Time,Displacement,'select indentation roi',para.indent_data_length,'brucker');
vDisplacement=vDisplacement*3*pi*para.diameter/para.force;
vTime=vTime-eTime(1);
[cfL1, gof1] = createFit_SLSwDP(vTime, vDisplacement,K,v0);
v1=cfL1.b;
k0=cfL1.a;
k1=K-k0;
tau=v1*K/k0*k1; %Relaxation time in seconds
Result_full=[Esample v0 K k0 k1 v1 tau]'; 
    