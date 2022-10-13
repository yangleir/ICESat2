function [Pxx_1,fxx_1]=read_alt12_l3a(FILE_NAME,ex,tra)
% Input: FILE_NAME: 文件名；ex：坐标范围；tra：轨道类型，gt1l/gt1r/gt2l/...

%
%  This example code illustrates how to access and visualize an
%  NSIDC ICESat-2 ATL12 L3A version 4 HDF5 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r ATL12_20190330212241_00250301_004_02_h5
% 
%
% Tested under: MATLAB R2020a
% Last updated: 2021-05-06

% Open the HDF5 File.
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
% Open the datasets.

LATFIELD_NAME=strcat(tra,'/ssh_segments/latitude');
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME=strcat(tra,'/ssh_segments/longitude');
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME=strcat(tra,'/ssh_segments/heights/h');
data_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name_data = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);
% 
% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','on');

% Put title.
var_name = sprintf('%s', long_name_data);
tstring = {FILE_NAME;var_name};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

% Plot world map coast line.
coast = load('coast.mat');
plotm(coast.lat, coast.long, 'k');
tightmap;

% Plot world map coast line.
scatterm(latitude, lon, 1, data);
h = colorbar();
units_str = sprintf('%s', char(units_data));
set (get(h, 'title'), 'string', units_str, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

% saveas(f, [FILE_NAME '.m.png']);

input=[lon,latitude, data];

extent=ex; %

order=strcat('select -R',extent);
sel=gmt(order,input);
% sel=gmt('select  -R112/116/15.0/21 ',input);
% gmt('gmt2kml  -Gred+f -Fs >  ./tmp/mypoints.kml',sel);
dist=gmt('mapproject  -fg -Gn+a+i+uk',sel);

% track 
mss=gmt('grdtrack  -G.\dtu\nh.nc',[sel.data(:,1) sel.data(:,2)]);

data2=[dist.data(:,5),dist.data(:,3)-mss.data(:,3)];
data3=gmt('sample1d  -Fn -T6.0 ',data2);

fs=1/6;%km
len = fix(length(data3.data));
win=hamming(len);
[Pxx_1,fxx_1] = pwelch (data3.data(:,2),win,[],len,fs,'onesided');
[pxx,f] = plomb (data2(:,2),data2(:,1));
[pxx_mss,f_mss] = plomb (mss.data(:,3),data2(:,1));

figure ('name','wavenumber by pwelch and plomb method')
loglog(fxx_1,Pxx_1);hold on
loglog(f,pxx)
loglog(f_mss,pxx_mss)
legend('pwelch 均匀数据','plomb 不均匀数据','mss')

figure('name','ALT12 ssh')
plot(data2(:,1),data2(:,2),'-o')

return