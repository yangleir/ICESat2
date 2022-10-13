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
%����Ĳ���Ӧ��������ǰ�ļ����ļ�������������
function [IDX, isnoise]=DBSCAN(X,epsilon,MinPts)    %DBSCAN���ຯ��
 
    C=0;                       %ͳ�ƴ����������ʼ��Ϊ0
    
    n=size(X,1);               %�Ѿ���X����������ֵ��n����һ����n����
    IDX=zeros(n,1);            %����һ��n��1�еľ���
    
    D=pdist2(X,X);             %����(X,X)���еľ���
    
    visited=false(n,1);        %����һά�ı�����飬ȫ����ʼ��Ϊfalse������δ������
    isnoise=false(n,1);        %����һά���쳣�����飬ȫ����ʼ��Ϊfalse������õ㲻���쳣��
    
    for i=1:n                  %����1~n�����еĵ�
        if ~visited(i)         %δ�����ʣ���ִ�����д���
            visited(i)=true;   %���Ϊtrue���Ѿ�����
            
            Neighbors=RegionQuery(i);     %��ѯ��Χ���о���С�ڵ���epsilon�ĸ���
            if numel(Neighbors)<MinPts    %���С��MinPts
                % X(i,:) is NOISE        
                isnoise(i)=true;          %�õ����쳣��
            else              %�������MinPts,�Ҿ������epsilon
                C=C+1;        %�õ������µĴ������ĵ�,�������+1
                ExpandCluster(i,Neighbors,C);    %������µĴ������ģ�ִ������ĺ���
            end
            
        end
    
    end                    %ѭ����n���㣬����ѭ��
    
    function ExpandCluster(i,Neighbors,C)    %�жϸõ���Χ�ĵ��Ƿ�ֱ���ܶȿɴ�
        IDX(i)=C;                            %����i��C�����¼��IDX(i)��
        
        k = 1;                             
        while true                           %һֱѭ��
            j = Neighbors(k);                %�ҵ�����С��epsilon�ĵ�һ��ֱ���ܶȿɴ��
            
            if ~visited(j)                   %���û�б�����
                visited(j)=true;             %���Ϊ�ѷ���
                Neighbors2=RegionQuery(j);   %��ѯ��Χ���о���С��epsilon�ĸ���
                if numel(Neighbors2)>=MinPts %�����Χ��ĸ������ڵ���Minpts������õ�ֱ���ܶȿɴ�
                    Neighbors=[Neighbors Neighbors2];   %#ok  %���õ������ͬһ�����൱��
                end
            end                              %�˳�ѭ��
            if IDX(j)==0                     %�����û�γ��κδ���
                IDX(j)=C;                    %����j�������¼��IDX(j)��
            end                              %�˳�ѭ��
            
            k = k + 1;                       %k+1,����������һ��ֱ���ܶȿɴ�ĵ�
            if k > numel(Neighbors)          %����Ѿ�����������ֱ���ܶȿɴ�ĵ㣬���˳�ѭ��
                break;
            end
        end
    end                                      %�˳�ѭ��
    
    function Neighbors=RegionQuery(i)        %�ú���������ѯ��Χ���о���С�ڵ���epsilon�ĸ���
        Neighbors=find(D(i,:)<=epsilon);
    end
 
end