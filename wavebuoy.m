% 南海某浮标数据绘图
%%
%GMT
cd C:\Users\yangleir\Documents\MATLAB\icesat\ICESat2
oldpath = path; % Add GMT path. The GMT is available from https://github.com/GenericMappingTools/gmt
path(oldpath,'C:\programs\gmt6exe\bin'); % Add GMT path

format long
%% 
!gawk "NR>20 && !/-/ {print $2, $3}" ./buoy/2019.txt > ./buoy/2019.d
!gawk "NR>20 && !/-/ {print $2, $3}" ./buoy/2020.txt > ./buoy/2020.d
!gawk "NR>20 && !/-/ {print $2, $3}" ./buoy/2021.txt > ./buoy/2021.d

wb2019=load ('./buoy/2019.d');
wb2020=load ('./buoy/2020.d');
wb2021=load ('./buoy/2021.d');
% 2021
wb=wb2021;
tm=num2str(wb(:,1));
wave2021=wb(:,2);

year=tm(:,1:4);
mm=tm(:,5:6);
dd=tm(:,7:8);
hh=tm(:,9:10);
min=tm(:,11:12);
tm2021=strcat(year,'-',mm,'-',dd,32,hh,':',mm,':00');
datenn2021 = datenum(tm2021);
% 2019
wb=wb2019;
tm=num2str(wb(:,1));
wave2019=wb(:,2);

year=tm(:,1:4);
mm=tm(:,5:6);
dd=tm(:,7:8);
hh=tm(:,9:10);
min=tm(:,11:12);
tm2019=strcat(year,'-',mm,'-',dd,32,hh,':',mm,':00');
datenn2019 = datenum(tm2019);
% 2020
wb=wb2020;
tm=num2str(wb(:,1));
wave2020=wb(:,2);

year=tm(:,1:4);
mm=tm(:,5:6);
dd=tm(:,7:8);
hh=tm(:,9:10);
min=tm(:,11:12);
tm2020=strcat(year,'-',mm,'-',dd,32,hh,':',mm,':00');
datenn2020 = datenum(tm2020);

xdate2019=datetime(tm2019,'InputFormat','yyyy-mm-dd HH:MM:SS');

plot(xdate2019,wave2019)

%% GMT

gmt('gmtset FONT_ANNOT_PRIMARY=7p MAP_FRAME_PEN=thinner,black FONT_LABEL=7p,4,black FONT_ANNOT_SECONDARY=7p')
gmt('gmtset MAP_FRAME_WIDTH=0.01c')
gmt('gmtset FONT_LABEL=7 MAP_LABEL_OFFSET=5p')
% gmt gmtset MAP_GRID_PEN_PRIMARY	= 0.1p,0/0/0,2_1_0.25_1:0
t1 = num2str(datenum('2019-1-1'));
t2 = num2str(datenum('2022-1-1'));

order=strcat('psbasemap -R2019-1-1T00:00:00/2022-1-1T00:00:00/0/1000 -JX15/5  -Byaf -Bpxf1oa4o -Bsxf1ya1y -BSWen  -K -Bx+l"time"  -By+l"SWH/cm" > ./tmp/dist_sigma.ps ');
gmt(order);  
input=[datenn2019,wave2019];
order=strcat('psxy -R',t1,'/',t2,'/0/1000 -J  -Sc0.05 -Gblue -K -O -t20 >> ./tmp/dist_sigma.ps ');
gmt(order,input);

input=[datenn2020,wave2020];
order=strcat('psxy -R',t1,'/',t2,'/0/1000 -J -Sc0.05 -Gred -K -O -t20 >> ./tmp/dist_sigma.ps ');
gmt(order,input);

input=[datenn2021,wave2021];
order=strcat('psxy -R',t1,'/',t2,'/0/1000 -J -Sc0.05 -Gblack  -O  -t20 >> ./tmp/dist_sigma.ps ');
gmt(order,input);

gmt('psconvert ./tmp/dist_sigma.ps -P -Tf -A')
