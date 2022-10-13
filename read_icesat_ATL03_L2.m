% Author: Lei Yang
% Email:leiyang@fio.org.cn
% Processing the Icesat-2 data (ALT03 and ALT12)


%%
%GMT
cd C:\Users\yangleir\Documents\MATLAB\icesat
oldpath = path; % Add GMT path. The GMT is available from https://github.com/GenericMappingTools/gmt
path(oldpath,'C:\programs\gmt6exe\bin'); % Add GMT path

format long
%% A03

FILE_NAME = 'D:\icesat\data\nanhai\processed_ATL03_20211106022917_06821301_005_01.h5';
% FILE_NAME = 'C:\Users\yangleir\Documents\icesat\data\nanhai\5000003308977\239125967\processed_ATL03_20211114021240_08041301_005_01.h5';

% FILE_NAME = 'C:\Users\yangleir\Documents\icesat\data\5000003282189\224762955\processed_ATL03_20190409153854_01740302_005_01.h5';
extent='-150/150/18/18.9';
track='gt2l';
pl=0;% 0 不绘制地图，1绘制地图
[pxx_03,fxx_03]=read_alt03_l2a(FILE_NAME,extent,track,pl);

%% Alt12 ocean product
FILE_NAME = 'D:\icesat\data\nanhai\ATL12_20211106005500_06811301_005_01.h5';
extent='112/116/15.0/21';
track='gt3l';
[Pxx_12,fxx_12]=read_alt12_l3a(FILE_NAME,extent,track);

%%
% S6A
sla_s6a=load('C:\Users\yangleir\Documents\phd\code\out\s6a_hr\P0114l2p.dat');
gmt('select -R0/360/10/19 > ./tmp/out.txt',sla_s6a);
s6a_hainan_dist=gmt('mapproject  -fg -Gn+a+i+uk ./tmp/out.txt');
ssa=s6a_hainan_dist.data;
data=[ssa(:,5) ssa(:,3)];
fs=1/5.766;%km
[Pxx_s6,fxx_s6]=pwelch(ssa(:,3),fix(length(data)/2),[],[],fs,'onesided');

%%
figure('name','s6a wavenumber and hainan jizai and SAR','Position', [0,0,400,600])
% S6A
loglog(fxx_s6,Pxx_s6,'red');hold on
% Insar
hainan_jz=load('C:\Users\yangleir\Documents\phd\code\wavenumber_hainan_80km_removeMSS_new.txt');
loglog(hainan_jz(:,1),hainan_jz(:,2),'blue');
% SAR
hainan_sar=load('C:\Users\yangleir\Documents\phd\code\wavenumber_hainan_sar.txt');
loglog(hainan_sar(:,1),hainan_sar(:,2),'black');
% ICESAT-2
loglog(fxx_03,pxx_03,'-')
loglog(fxx_12,Pxx_12,'-')
xlabel('cpkm')
ylabel('m2/cpkm')
legend('S6A','InSAR','SAR','Icesat03','Icesat12')

%% 和MASS比较


%%
% 使用MSS模型判断异常值
% mss=gmt('grdtrack  -G./tmp/nh_mss.nc',sel);
% delta_mss=mss.data(:,3)-mss.data(:,4);
% % remove outlier
% [n]=find(abs(delta_mss)>4);
% data2(n,2)=NaN;
% delta_mss(n)=NaN;
% data2(any(isnan(data2), 2),:) = [];


%%
% 试一试EMD
% imf=emd(data_conf(:,2));
% emd_visu(data_conf(:,2),data_conf(:,1),imf')  % EMD专用画图函数
% data3=data_conf(:,2)-imf(:,2)-imf(:,1);
% 
% figure('name','mss')
% plot(data_conf(:,2),'o');hold on
% plot(data3,'o')
% 
% % PSD
% [pxx,f] = plomb(data3,data_conf(:,1));
% 
% figure ('name','wafo and pwelch Ka wavenumber')
% loglog(f,pxx)

%%
% DBSCAN 太慢了
% epsilon=0.1;                          %规定两个关键参数的取值
% MinPts=10;
% IDX=DBSCAN(data2,epsilon,MinPts);         %传入参数运行
% PlotClusterinResult(data2, IDX);          %传入参数，绘制图像