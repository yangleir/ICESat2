%% NECI buoy
clear
clc
% ncdisp('./ncei/NDBC_46006_202101_D5_v00.nc')
% ncinfo('./ncei/NDBC_46006_202101_D5_v00.nc')
format long
% swh=ncread('./ncei/NDBC_46006_202101_D5_v00.nc','/payload_4/wave_sensor_1/significant_wave_height');

swh=h5read('./ncei/NDBC_46006_202101_D5_v00.nc','/payload_4/wave_sensor_1/significant_wave_height');
tm2=h5read('./ncei/NDBC_46006_202101_D5_v00.nc','/time_wpm_20');
tm1=h5read('./ncei/NDBC_46006_202101_D5_v00.nc','/time');

swh(abs(swh)==swh(1,1))=NaN;
z=find(~isnan(swh));
swh2=swh(z,:);
tm0=double(tm1(z,:));
tm3=tm0/(24*3600)+datenum('1970-01-01 00:00:00.0');
formatOut = 'yyyy-mm-dd HH:MM:SS';
tm=datestr(tm3,formatOut);%yyyy-mm-dd HH:MM:SS
xdate=datetime(tm,'InputFormat','yyyy-MM-dd HH:mm:ss');

figure('name','swh')
plot(xdate,swh2)

psd=h5read('./ncei/NDBC_46006_202101_D5_v00.nc','/payload_4/wave_sensor_1/c11');
fr=h5read('./ncei/NDBC_46006_202101_D5_v00.nc','/wave_wpm');

dr=h5read('./ncei/NDBC_46006_202101_D5_v00.nc','/payload_4/wave_sensor_1/mean_wave_direction');
dr=dr(z);

psd2=psd(:,z);
figure('name','psd')
plot(fr,psd2(:,2))

figure('name','direction')
plot(xdate,dr)
rose(dr/180*pi)
polarhistogram(dr/180*pi)

%% 2D
% meshgrid
x = tm0;
y = fr;
[X,Y] = meshgrid(x,y);

F=psd2;
C = del2(F);
C=gradient(F);
surf(X,Y,F,C,'FaceLighting','gouraud','LineWidth',0.3)

imagesc(F)
%% txt file
!gawk "NR>2 {print $1,$2,$3,$4,$9,$12}" ./ncei/46006h2019.txt | gawk "!/99.00/  {print $0}"> ./ncei/2019.d
swh2019=load('./ncei/2019.d');
plot(swh2019(:,5))
polarhistogram(swh2019(:,6)/180*pi)

