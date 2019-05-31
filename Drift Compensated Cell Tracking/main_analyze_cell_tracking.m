%%data imported as column vectors
%the data should be in following default Imaris exported excel format and
%imported as column vectors
%Position X_Ecto	Position Y_Ecto	Position Z_Ecto	Unit_Ecto	Category_Ecto	Collection_Ecto	Time_Ecto	TrackID	ID_Ecto
%Position X_Meso	Position Y_Meso	Position Z_Meso	Unit_Meso	Category_Meso	Collection_Meso	Time_Meso	TrackID	ID_Meso
%Position X_Bead	Position Y_Bead	Position Z_Bead	Unit_Bead	Category_Bead	Collection_Bead	Time_Bead	TrackID	ID_Bead

%% clear
clear all;
close all;
clearvars -global;

%% drift compensation
tracks_Ecto=min(TrackID_Ecto);
trackf_Ecto=max(TrackID_Ecto);

for i=tracks_Ecto:1:trackf_Ecto
x=find(TrackID_Ecto==i); %row number
time=Time_Ecto(x); %time info
temp0=find (Time_Bead==time(1));
PositionXF_Ecto(x(1),1)=PositionX_Ecto(x(1));
PositionYF_Ecto(x(1),1)=PositionY_Ecto(x(1));
PositionZF_Ecto(x(1),1)=PositionZ_Ecto(x(1));
for j=2:1:length(x)  
temp=find(Time_Bead==time(j));
PositionXF_Ecto(x(j),1)=PositionX_Ecto(x(j))-(PositionX_Bead(temp)-PositionX_Bead(temp0));
PositionYF_Ecto(x(j),1)=PositionY_Ecto(x(j))-(PositionY_Bead(temp)-PositionY_Bead(temp0));
PositionZF_Ecto(x(j),1)=PositionZ_Ecto(x(j))-(PositionZ_Bead(temp)-PositionZ_Bead(temp0));
end
end

tracks_Meso=min(TrackID_Meso);
trackf_Meso=max(TrackID_Meso);

for i=tracks_Meso:1:trackf_Meso
x=find(TrackID_Meso==i); %row number
time=Time_Meso(x); %time info
temp0=find (Time_Bead==time(1));
PositionXF_Meso(x(1),1)=PositionX_Meso(x(1));
PositionYF_Meso(x(1),1)=PositionY_Meso(x(1));
PositionZF_Meso(x(1),1)=PositionZ_Meso(x(1)); 
for j=2:1:length(x)  
temp=find(Time_Bead==time(j));
PositionXF_Meso(x(j),1)=PositionX_Meso(x(j))-(PositionX_Bead(temp)-PositionX_Bead(temp0));
PositionYF_Meso(x(j),1)=PositionY_Meso(x(j))-(PositionY_Bead(temp)-PositionY_Bead(temp0));
PositionZF_Meso(x(j),1)=PositionZ_Meso(x(j))-(PositionZ_Bead(temp)-PositionZ_Bead(temp0));
end
end

%% 2D rotation for plotting if necessary
CenterX=400;CenterY=400; %enter center coordinates here to center the tracking data for rotation
PositionXF_Ecto=PositionXF_Ecto-CenterX;
PositionYF_Ecto=PositionYF_Ecto-CenterY;
PositionXF_Meso=PositionXF_Meso-CenterX;
PositionYF_Meso=PositionYF_Meso-CenterY;
theta = 45; % to rotate 45 counterclockwise enter the angle here
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

for ii=1:1:length(PositionXF_Ecto)
rotatedxy=R*[PositionXF_Ecto(ii);PositionYF_Ecto(ii)];
PositionXF_Ecto(ii)=rotatedxy(1);
PositionYF_Ecto(ii)=rotatedxy(2);
end

for ii=1:1:length(PositionXF_Meso)
rotatedxy=R*[PositionXF_Meso(ii);PositionYF_Meso(ii)];
PositionXF_Meso(ii)=rotatedxy(1);
PositionYF_Meso(ii)=rotatedxy(2);
end

%% plot cell migration
figure()
hold on
for i=tracks_Ecto:1:trackf_Ecto
    x=find(TrackID_Ecto==i);
plot3(PositionXF_Ecto(x),PositionYF_Ecto(x),PositionZF_Ecto(x),'LineWidth',1.5,'Color','b'); 
j = find (x==max(x));
h = scatter3(PositionXF_Ecto(x(j)),PositionYF_Ecto(x(j)),PositionZF_Ecto(x(j)),'filled','b');
h.SizeData = 20;
end

for i=tracks_Meso:1:trackf_Meso
    x=find(TrackID_Meso==i);
plot3(PositionXF_Meso(x),PositionYF_Meso(x),PositionZF_Meso(x),'LineWidth',1.5,'Color','r'); 
j = find (x==max(x));
h = scatter3(PositionXF_Meso(x(j)),PositionYF_Meso(x(j)),PositionZF_Meso(x(j)),'filled','r');
h.SizeData = 20;
end

%% cell migration speed calculation in um/hrs
interval=1/6; %time interval in hrs
ind=1;
for i=tracks_Ecto:1:trackf_Ecto 
    x=find(TrackID_Ecto==i); 
    for j=1:1:length(x)-1
    dis=sqrt((PositionXF_Ecto(x(j))-PositionXF_Ecto(x(j+1)))^2+(PositionYF_Ecto(x(j))-PositionYF_Ecto(x(j+1)))^2+(PositionZF_Ecto(x(j))-PositionZF_Ecto(x(j+1)))^2);   
    v_temp(j,1)= dis/interval;
    end
    v_ecto(ind,1)=mean(v_temp);%ectodermal cell migration speed
    v_temp=[];
    ind=ind+1;
end

ind=1;
for i=tracks_Meso:1:trackf_Meso 
    x=find(TrackID_Meso==i); 
    for j=1:1:length(x)-1
    dis=sqrt((PositionXF_Meso(x(j))-PositionXF_Meso(x(j+1)))^2+(PositionYF_Meso(x(j))-PositionYF_Meso(x(j+1)))^2+(PositionZF_Meso(x(j))-PositionZF_Meso(x(j+1)))^2);   
    v_temp(j,1)= dis/interval;
    end
    v_meso(ind,1)=mean(v_temp);%mesodermal cell migration speed
    v_temp=[];
    ind=ind+1;
end

%% plot cell migration speed
figure ()
hold on 
notBoxPlot(v_ecto,1);
notBoxPlot(v_meso,2);
names = {'Ectoderm'; 'Mesoderm';};
set(gca,'FontSize',15);
set(gca,'xtick',[1,2],'xticklabel',names)
ylabel('Cell Migration Speed (microns/hour)','FontSize',15);
box on
