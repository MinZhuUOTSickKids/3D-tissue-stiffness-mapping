% show indent data, extend in red and retract in blue
% input z_piezo_NM, bruker_readout

function show_indentation_data(z_piezo_NM,bruker_readout);


ind_peak=find(z_piezo_NM==max(z_piezo_NM));
ind_peak=ind_peak(1);
z_piezo_NM_c{1}=z_piezo_NM(1:ind_peak);
z_piezo_NM_c{2}=z_piezo_NM(ind_peak:end);
bruker_readout_c{1}=bruker_readout(1:ind_peak);
bruker_readout_c{2}=bruker_readout(ind_peak:end);

global show_figure_on1_off0
if show_figure_on1_off0==1

figure(101)
clf
plot(z_piezo_NM_c{1},bruker_readout_c{1},'r.-')
hold on
plot(z_piezo_NM_c{2},bruker_readout_c{2},'b.-')
grid on
legend('indent','withdraw')
xlabel('indentation depth (nm)')
ylabel('deflection d_{tip} (nm)')
title('show indentation data')
end