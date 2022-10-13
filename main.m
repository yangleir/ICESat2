%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML110
% Project Title: Implementation of DBSCAN Clustering in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%
%����Ĵ�����Ӧ���Ǽ��س������ﲻ���������
clc;                    %���������е���˼
clear;                  %����洢�ռ�ı���,���������ĳ������в���Ӱ��
close all;              %�ر�����ͼ�δ���
 
%% Load Data            %����data.mat�����ļ�����ģ��
 
data=load('DBSCAN/mydata');    %���ݶ�ȡ
X=data.X;

figure('name','test')
plot(X(:,1),X(:,2),'o') 
 
%% Run DBSCAN Clustering Algorithm    %����Run����ģ��
 
epsilon=0.5;                          %�涨�����ؼ�������ȡֵ
MinPts=10;
IDX=DBSCAN(X,epsilon,MinPts);         %�����������
 
 
%% Plot Results                       %�����ͼ���ģ��
 
PlotClusterinResult(X, IDX);          %�������������ͼ��
title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);