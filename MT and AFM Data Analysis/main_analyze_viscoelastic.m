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
% load data as X and Y coordinates in um

%% calculate d vs t
for i=1:1:(length(X)-1)
    Displacement(i)=sqrt((X(i+1)-X(1))^2+(Y(i+1)-Y(1))^2);
end
Time=0:1:(length(X)-2);
Time=Time';
plot(Time,Displacement);
set(gca,'FontSize',15);
xlabel('Time (s)','FontSize',15);
ylabel('Displacement (microns)','FontSize',15);
box on
pbaspect([1 1 1])
%% select select indentation roi, this ROI will be used to calculate elastic modulus
[eTime,eDisplacement,ind]=manual_select_line_roi(Time,Displacement,'select indentation roi',para.indent_data_length,'brucker'); 
fDisplacement=eDisplacement(end)-eDisplacement(1);
K=para.force/(fDisplacement*3*pi*para.diameter);  
Esample=2*K*(1+para.v_sample);

%% select select indentation roi, this ROI will be used to calculate Viscosity
[vTime,vDisplacement,ind]=manual_select_line_roi(Time,Displacement,'select indentation roi',para.indent_data_length,'brucker');
vDisplacement=vDisplacement*3*pi*para.diameter/para.force;
vTime=vTime-eTime(1);
[cfL,gof]=createFit_line_poly_N(vTime, vDisplacement,1);
v0=1/cfL.p1;
Result=[Esample v0];

 %% full fitting
[vTime,vDisplacement,ind]=manual_select_line_roi(Time,Displacement,'select indentation roi',para.indent_data_length,'brucker');
vDisplacement=vDisplacement*3*pi*para.diameter/para.force;
vTime=vTime-eTime(1);
[cfL1, gof1] = createFit_SLSwDP(vTime, vDisplacement,K,v0);
v1=cfL1.b;
k0=cfL1.a;
k1=K-k0;
tau=v1*K/k0*k1;
Result_full=[Esample v0 K k0 k1 v1 tau]';
    