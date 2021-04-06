function output = normalization_special(input,MAX,varargin)
% ��ȫ��������[0,max]�����ȡ���еľֲ����ֵmi��ƽ����m��������������ֵM,����ͼƬ������(M-m)^2
% ����ͼƬ������resize��С,����еĻ�
if nargin>=3
    resize=varargin{1};
end
input(input<0)=0;
if(MAX~=0)
    input=(input - min(input(:))) / (max(input(:)) - min(input(:))) * MAX;
end
M=MAX;
% �����и�threshold�����
threshold=M/10;
if(threshold==0)
    threshold=1;
end
idx=imregionalmax(input,4);idx(:,end)=0;idx(:,1)=0;idx(end,:)=0;idx(1,:)=0;
idxx=input>=threshold;
temp=input(idx&idxx);

m=mean(temp(:));
output=input*(M-m)^2;
if nargin>=3
output=imresize(output,resize,'nearest');
end
end

