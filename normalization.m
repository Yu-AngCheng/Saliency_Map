function output = normalization(input,varargin)
% 先全部规整到[0,1]，随后取所有的局部最大值mi并平均得m，并求得整体最大值M,整张图片最后乘以(M-m)^2
% 所有图片规整到resize大小,如果有的话
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

