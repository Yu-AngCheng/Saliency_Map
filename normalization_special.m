function output = normalization_special(input,MAX,varargin)
% 先全部规整到[0,max]，随后取所有的局部最大值mi并平均得m，并求得整体最大值M,整张图片最后乘以(M-m)^2
% 所有图片规整到resize大小,如果有的话
if nargin>=3
    resize=varargin{1};
end
input(input<0)=0;
if(MAX~=0)
    input=(input - min(input(:))) / (max(input(:)) - min(input(:))) * MAX;
end
M=MAX;
% 这里有个threshold很奇怪
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

