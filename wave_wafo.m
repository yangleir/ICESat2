% wave simulation by WAFO
% 验证了wafo和matlab计算谱的一致性
rmpath C:\Users\yangleir\Documents\MATLAB\diwasp
clc
clear all
Hm0 = 0.4;
Tp  = 3.03;
plotflag = 1;
ST=torsethaugen([],[Hm0 Tp],plotflag); %1/(2.085/2/pi) 角频率和纯时间频率

dt = 0.1; N = 2000;
xs = spec2sdat(ST,N,dt);
waveplot(xs)

fs=1/dt;%m
[Pxx_s,fxx_s]=pwelch(xs(:,2),length(xs)/4,[],[],fs,'onesided');

figure ('name','test1')
plot((ST.w/2/pi),ST.S*2*pi); hold on
xlabel('1/s')
plot(fxx_s,Pxx_s); % ok

plotflag = 1; clf
Nt = 100;   % number of angles
th0 = 0; % primary direction of waves ,ie. pi/4
Sp  = 15;   % spreading parameter
D1 = spreading(Nt,'cos',th0,Sp,[],0); % frequency independent
D12 = spreading(Nt,'cos',0,Sp,ST.w,1); % frequency dependent

STD1 = mkdspec(ST,D1);
STD12 = mkdspec(ST,D12);
plotspec(STD1,plotflag), hold on, plotspec(STD12,plotflag,'-.'); hold off
wafostamp('','(ER)')

rng('default'); 
opt = simoptset('Nt',1,'dt',1,'Nu',1024*10','du',1,'Nv',4,'dv',1);
W1 = spec2field(STD1,opt);

wav=[W1.y W1.Z(1,:)'];
STest = dat2spec(wav);

fs=1;%m
[Pxx_s,fxx_s]=pwelch(W1.Z(1,:),length(W1.Z(1,:))/20,[],[],fs,'onesided');
plot((STest.w/2/pi),STest.S*2*pi); hold on
plot(fxx_s,Pxx_s); % ok


% wavelength=9.8*Tp^2/(2*pi) % 应该是这个数




