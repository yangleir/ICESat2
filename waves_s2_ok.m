% one-D in time domain.
clear all;
Vwind=5;              % wind speed at 19.4 m
dw=0.01;                % the difference between successive frequencies
w=0.01:dw:4;            % angular frequencies
dt=1;
t=0:dt:200;         % simulation time second
dx=2; % m
x=-0:dx:5000; %m
% x=0;
Nx=length(x);
Nt=length(t);
el=zeros(Nx,Nt);

S=waveSpectrum(Vwind,w);
figure (200);
plot(w/2/pi,S*2*pi);
xlabel('frequency [rad/s]');
ylabel('wave spectrum [cm^2/s]');
grid on;
% output=[1./(w'/2/pi),S'*2*pi];
% save('psd_pm.txt','output','-ascii')

for i=1:Nt
    for j=1:Nx
        el(j,i)=waveGen(S,w,x(j),t(i));
    end
end

swh=std(el(1,:))*4 
swh=std(el(:,1))*4 


figure (1);subplot(2,1,1);
plot(t(1:200),el(1,1:200));
xlabel('time [s]');
ylabel('wave elevation [m]');
subplot(2,1,2);
plot(x(1:1000),el(1:1000,1));
xlabel('distance [s]');
ylabel('wave elevation [m]');


%%
tmp=reshape(el(:,1),1,length(el));
fs=1/dx;%m
[Pxx_s6,fxx_s6]=pwelch(tmp,length(el)/8,[],[],fs,'onesided');

tmp=reshape(el(1,:),1,length(el(1,:)));
fs=1/dt;%m
[Pxx_s,fxx_s]=pwelch(tmp,length(el(1,:))/8,[],[],fs,'onesided');

figure('name','wavenumber')
loglog(fxx_s6,Pxx_s6,'red');hold on
loglog(fxx_s,Pxx_s,'blue');

figure('name','wavenumber1')
plot(fxx_s6,Pxx_s6,'red');hold on
k=9.80665./(fxx_s.^2)/(2*pi);
pk=Pxx_s*9.80665./fxx_s/(4*pi);
plot(1./k,pk,'red');
plot(fxx_s,Pxx_s,'blue');

