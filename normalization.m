function output = normalization(input,varargin)
% ��ȫ��������[0,1]�����ȡ���еľֲ����ֵmi��ƽ����m��������������ֵM,����ͼƬ������(M-m)^2
% ����ͼƬ������resize��С,����еĻ�
if nargin>=2
    resize=varargin{1};
end
input(input<0)=0;
if(max(input(:))~=min(input(:)))
    input=(input - min(input(:))) / (max(input(:)) - min(input(:)))*1;
else
    input=input-input;
end
M=1;
idx=imregionalmax(input,4);idx(:,end)=0;idx(:,1)=0;idx(end,:)=0;idx(1,:)=0;
temp=input(idx);
m=mean(temp(:));
output=input*(M-m)^2;
if nargin>=2
    output=imresize(output,resize,'nearest');
end
end

