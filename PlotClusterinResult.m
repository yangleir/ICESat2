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
%����ĳ�������Ӧ���Ǽ����ļ�����������Ľ���
function PlotClusterinResult(X, IDX)                %��ͼ����������
    k=max(IDX);                                     %�����IDXÿһ�е����Ԫ�ؼ����Ӧ������
 
    Colors=hsv(k);                                  %��ɫ����
 
    Legends = {};
    for i=0:k                                       %ѭ��ÿһ������
        Xi=X(IDX==i,:);                    
        if i~=0                                     
            Style = 'x';                            %��Ƿ���Ϊx
            MarkerSize = 8;                         %��ǳߴ�Ϊ8
            Color = Colors(i,:);                    %���е�ı���ɫ�ı�
            Legends{end+1} = ['Cluster #' num2str(i)]; 
        else
            Style = 'o';                            %��Ƿ���Ϊo
            MarkerSize = 6;                         %��ǳߴ�Ϊ6
            Color = [0 0 0];                        %���е�ı���ɫ�ı�
            if ~isempty(Xi)
                Legends{end+1} = 'Noise';           %���Ϊ�գ���Ϊ�쳣��
            end
        end
        if ~isempty(Xi)
            plot(Xi(:,1),Xi(:,2),Style,'MarkerSize',MarkerSize,'Color',Color);
        end
        hold on;
    end
    hold off;                                    %ʹ��ǰ�ἰͼ�β��ھ߱���ˢ�µ�����
    axis equal;                                  %������ĳ��ȵ�λ������
    grid on;                                     %�ڻ�ͼ��ʱ�����������
    legend(Legends);
    legend('Location', 'NorthEastOutside');      %legendĬ�ϵ�λ����NorthEast���������������
 
end                                              %����ѭ��