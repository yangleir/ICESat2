function [pxx,f]=read_alt03_l2a(FILE_NAME,ex,tra,pl)
% Input: FILE_NAME: 文件名；ex：坐标范围；tra：轨道类型，gt1l/gt1r/gt2l/...，
% pl:是否绘空间点位图，1 plot or 0 no plot
%  This example code illustrates how to access and visualize
%  ICESat-2 ATL03 L2A version 4 HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r ATL03_20181027235521_04480111_004_01_h5
%
% Tested under: MATLAB R2020a
% Last updated: 2021-05-06

% Open the HDF5 File.
% clear

file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
% h5disp(FILE_NAME);

% Open the datasets.
LATFIELD_NAME=strcat(tra,'/heights/lat_ph');
% LATFIELD_NAME='gt1l/geolocation/reference_photon_lat';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME=strcat(tra,'/heights/lon_ph');
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME=strcat(tra,'/heights/h_ph');
temp_id=H5D.open(file_id, DATAFIELD_NAME);

otide=H5D.open(file_id, strcat(tra,'/geophys_corr/tide_ocean'));
dac=H5D.open(file_id, strcat(tra,'/geophys_corr/dac'));

DATAFIELD_NAME=strcat(tra,'/heights/signal_conf_ph');
temp_id_confi=H5D.open(file_id, DATAFIELD_NAME);

% Read the datasets.
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
% temp=H5D.read(temp_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
%              'H5P_DEFAULT');
conf=H5D.read(temp_id_confi,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
o_tide=H5D.read(otide,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
dac_c=H5D.read(dac,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');         
temp=H5D.read(temp_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
         
         
% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (temp_id, ATTRIBUTE);
units_temp = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (temp_id, ATTRIBUTE);
long_name_temp = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (temp_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);
% 


if pl==1
    % Create the graphics figure.
    f = figure('Name', FILE_NAME, ...
               'Renderer', 'zbuffer', ...
               'Position', [0,0,800,600], ...
               'visible','on');

    % Put title.
    var_name = sprintf('%s', long_name_temp);
    tstring = {FILE_NAME;var_name};
    title(tstring,...
          'Interpreter', 'none', 'FontSize', 16, ...
          'FontWeight','bold');
    axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
          'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

    % Plot world map coast line.
    slice=1:10000:length(lon);
    scatterm(latitude(slice), lon(slice), 1, temp(slice));
    h = colorbar();
    units_str = sprintf('%s', char(units_temp));
    set (get(h, 'title'), 'string', units_str, 'FontSize', 8, ...
                       'Interpreter', 'None', ...
                       'FontWeight','bold');

    % Plot world map coast line.
    coast = load('coast.mat');
    plotm(coast.lat, coast.long, 'k');
    tightmap;

    % saveas(f, [FILE_NAME '.m.png']);
    % exit;
end

data=temp;
extent=ex;%
order=strcat('select -R',extent);

% input=[lon,latitude, data];
% input2=input;
% sel=gmt(order,input2);
% 

% dist=gmt('mapproject  -fg -Gn+a+i+uk',sel);
% data2=[dist.data(:,5),dist.data(:,3)]; % 数据[累计距离 SSH]

% filter by confidence
[n]=find(conf(2,:)==4);% 选择质量最高的数据
lat=latitude(n);
lon2=lon(n);
data=data(n);

input3=[lon2,lat, data];
sel=gmt(order,input3);

% kml
slice=1:100:length(sel.data);
gmt('gmt2kml  -Gred+f -Fs >  ./tmp/mypoints.kml',sel.data(slice,:));
% track 
mss=gmt('grdtrack  -G.\dtu\nh.nc',[sel.data(:,1) sel.data(:,2)]);

dist_conf=gmt('mapproject  -fg -Gn+a+i+uk',sel);
data_conf=[dist_conf.data(:,5),dist_conf.data(:,3)-mss.data(:,3)]; % 好的数据
data_mss=[dist_conf.data(:,5),mss.data(:,3)]; % 好的数据
data_ssh=[dist_conf.data(:,5),dist_conf.data(:,3)]; % 好的数据



% filter1D
data_conf_sample1d=gmt('sample1d  -Fn -T0.005',data_conf);% 5m

dist_filter1d=gmt('filter1d -FG0.03 -T0.005',data_conf);
dist_filter1d_mss=gmt('filter1d -FG0.03 -T0.005',data_mss);
dist_filter1d_ssh=gmt('filter1d -FG0.03 -T0.005',data_ssh);

dist_filter1d2=gmt('filter1d -FG0.03 -T0.005',data_conf_sample1d);
dist_filter1d_2km=gmt('filter1d -FB2 -T2',data_conf);

% check mss
figure ('name','mss check')
plot(data_mss(:,1),data_mss(:,2));hold on
plot(dist_filter1d_mss.data(:,1),dist_filter1d_mss.data(:,2),'-o')


figure('name','sla')
plot(dist_conf.data(:,5),dist_conf.data(:,3)-mss.data(:,3),'-o');hold on
plot(data_conf_sample1d.data(:,1),data_conf_sample1d.data(:,2),'-o')
plot(dist_filter1d.data(:,1),dist_filter1d.data(:,2),'-o')
plot(dist_filter1d_2km.data(:,1),dist_filter1d_2km.data(:,2),'-o')

% PSD
input=[dist_filter1d2.data(:,1) dist_filter1d2.data(:,2)];
S = dat2spec(input,fix(length(input)),'cov');

[pxx,f] = plomb(dist_filter1d.data(:,2),dist_filter1d.data(:,1));
% mss
[pxx_mss,f_mss] = plomb(dist_filter1d_mss.data(:,2),dist_filter1d_mss.data(:,1));
% [pxx_mss,f_mss] = plomb(data_mss(:,2),data_mss(:,1));
[pxx_ssh,f_ssh] = plomb(dist_filter1d_ssh.data(:,2),dist_filter1d_ssh.data(:,1));

[pxx2,f2] = plomb(dist_filter1d2.data(:,2),dist_filter1d2.data(:,1));
[pxx3,f3] = plomb(dist_filter1d_2km.data(:,2),dist_filter1d_2km.data(:,1));

% 
% fs=1/0.005;%km
% [pxx3,f3]=pwelch(dist_filter1d2.data(:,2),fix(length(dist_filter1d2.data(:,2))/2),[],[],fs,'onesided');

pxx_filter1d=gmt('filter1d -FG0.05 -E ',[f,pxx]);
pxx_filter1d2=gmt('filter1d -FG0.05 -E ',[f2,pxx2]);
pxx_filter1d3=gmt('filter1d -FG0.05 -E ',[S.w/2/pi,S.S*2*pi]);
pxx_filter1d_ssh=gmt('filter1d -FG0.05 -E ',[f_ssh,pxx_ssh]);

figure ('name','wafo and pwelch Ka wavenumber','Position', [0,0,400,600])
loglog(f,pxx_filter1d.data(:,2),'-');hold on
loglog(f2,pxx_filter1d2.data(:,2),'-');
loglog(f3,pxx3,'-');
loglog(S.w/2/pi,pxx_filter1d3.data(:,2),'-');
loglog(f_mss,pxx_mss);
loglog(f_ssh,pxx_filter1d_ssh.data(:,2));

legend('无插值','插值','2km_filter','wafo方法','mss','ssh')

% pxx=pxx_filter1d.data(:,2);
% pxx=pxx;
return