% llc4320 ssh spectrum + wave simulation

format long
% set GMT path
oldpath = path; % Add GMT path. The GMT is available from https://github.com/GenericMappingTools/gmt
path(oldpath,'C:\programs\gmt6exe\bin'); % Add GMT path

%%
ssh=h5read('./llc4320/acc.nc','/Eta');
xc=h5read('./llc4320/acc.nc','/XC');
yc=h5read('./llc4320/acc.nc','/YC');
% imagesc(ssh)

ssh_tmp=ssh(1:7000,1000);
id=find(isnan(ssh_tmp));
ssh_tmp(id)=0;

% GMT
p1=[xc(1,1000) yc(1,1000)];
p2=[xc(2,1000) yc(2,1000)];
input=[p1;p2];
ellip=gmt('mapproject  -fg -Gn+a+i+uk -i0,1',input);
dx=ellip.data(2,4);

fs=1/dx;%m
[Pxx_s6,fxx_s6]=pwelch(ssh_tmp,length(ssh_tmp)/2,[],[],fs,'onesided');
figure('name','wavenumber')
loglog(fxx_s6,Pxx_s6,'red');hold on

%%
dx=ellip.data(2,4);
x1=0:dx:(7000-1)*dx;
dx2=0.002;
x2 = 0:dx2:(7000-1)*dx;% 插值成大约2m一个点。dx是每个网格的m数。从pangeo计算
ssh_h = interp1(x1,ssh_tmp,x2);

fs=1/dx2;
[Pxx_s6,fxx_s6]=pwelch(ssh_h,length(ssh_h)/2,[],[],fs,'onesided');
loglog(fxx_s6,Pxx_s6,'black');

%%
Vwind=5;              % wind speed at 19.4 m
dw=0.01;                % the difference between successive frequencies
w=0.01:dw:4;            % angular frequencies
dt=1;
t=1:dt:1;         % simulation time second
dx=2; % m
x=0:dx:50000-1; %m
% x=0;
Nx=length(x);
Nt=length(t);
el=zeros(Nx,Nt);

S=waveSpectrum(Vwind,w);
for i=1:Nt
    for j=1:Nx
        el(j,i)=waveGen(S,w,x(j),t(i));
    end
end

tmp=reshape(el(:,1),1,length(el));
dx=2;
fs=1/dx*1000; %km
[Pxx_s,fxx_s]=pwelch(tmp,length(el)/8,[],[],fs,'onesided');
loglog(fxx_s,Pxx_s,'blue');

%% llc+wave

dx=2;
wave=repmat( tmp , 1 , 2000 );
x=1:dx:50000*2000; %m
dx=ellip.data(2,4);
dx2=0.002;%km
x2 = 0:dx2:(7000-1)*dx;% 插值成大约2m一个点。dx是每个网格的m数。从pangeo计算
wave_l = interp1(x/1000,wave,x2);
sse=ssh_h+wave_l;
id=find(isnan(sse));
sse(id)=0;

fs=1/dx2;
[Pxx_s5,fxx_s5]=pwelch(sse,length(sse)/2,[],[],fs,'onesided');
Pxx_s6 = smooth(fxx_s5,Pxx_s5,5000,'moving');
loglog(fxx_s5(5000:1000000),Pxx_s6(5000:1000000),'green');
loglog(fxx_s6,2*1e-7*fxx_s6.^-3)
legend('llc','llc_high','wave','llc+wave','-3 slope')
xlabel('cpkm')
ylabel('m^2/cpkm')