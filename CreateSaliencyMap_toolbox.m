% only for toolbox edition
clear
%% load image
image=im2double(imread('Gabor-ocr.png'));
imagesize=size(image);
%% get feature(toolbox edition)
intensity=rgb2gray(image);% 注意，这并非仅仅是对RGB通道取平均
r=zeros(imagesize(1),imagesize(2));g=r;b=r;
idx=max(image,[],3)>=0.1;% 并非指intensity超过了max_intensity的1/10
temp=image(:,:,1);r(idx)=temp(idx);
temp=image(:,:,2);g(idx)=temp(idx);
temp=image(:,:,3);b(idx)=temp(idx);
% RGB的取法并非像paper上一样,但本质应该相同
R=r./max(image,[],3);R(isnan(R))=0;
G=g./max(image,[],3);G(isnan(G))=0;
B=b./max(image,[],3);B(isnan(B))=0;
Y=(min(r,g))./max(image,[],3);Y(isnan(Y))=0;
%% make pyramid(toolbox edition)
intensitypyramid=cell(1,9);intensitypyramid{1}=intensity;
for levels=2:9
    intensitypyramid{levels}=pyramid_reduce_special(intensitypyramid{levels-1});
end
colorpyramid=cell(2,9);colorpyramid{1,1}=R-G;colorpyramid{2,1}=B-Y;
for levels=2:9
    for specificcolor=1:2
        colorpyramid{specificcolor,levels}=pyramid_reduce_special(colorpyramid{specificcolor,levels-1});
    end
end
orientationpyramid=cell(4,9);
for orientation=0:45:135
    % 这种保能量的卷积被频繁使用但不知道为什么
    % 不是很懂为什么要做两个filter相加
    sz=9;center=ceil(sz/2);
    sigma=7/3;
    [x,y]=meshgrid(1:sz);
    x=x-center;y=y-center;
    Wt2=exp((-x.^2-y.^2)/(2*sigma*sigma));
    Period=7;
    cosine=cos((sind(orientation)*x+cosd(orientation)*y)*2*pi/Period);
    sine=cos((sind(orientation)*x+cosd(orientation)*y)*2*pi/Period+pi/2);
    % 这个标准化也很奇怪
    filter1=Wt2.*cosine;filter1=filter1-mean(filter1(:));
    filter1=filter1/sqrt(sum(filter1(:).^2));
    filter2=Wt2.*sine;filter2=filter2-mean(filter2(:));
    filter2=filter2/sqrt(sum(filter2(:).^2));
    for levels=1:9
        id=orientation/45+1;
%         orientationpyramid{id,levels}=...
%             abs(conv2PreserveEnergy(intensitypyramid{levels},filter1))+...
%             abs(conv2PreserveEnergy(intensitypyramid{levels},filter2));
        orientationpyramid{id,levels}=...
            abs(imfilter(intensitypyramid{levels},filter1,'same',mean(intensitypyramid{levels},'all')));
            abs(imfilter(intensitypyramid{levels},filter2,'same',mean(intensitypyramid{levels},'all')));
    end
end
%% center-surround difference(toolbox edition)
featuremap.Intensity=cell(1,6);
featuremap.Color=cell(2,6);
featuremap.Orientation=cell(4,6);
count=0;
% 这里是先放缩再相减
% 并且边界逐渐递减
for c=3:5
    for delta=3:4
        s=c+delta;
        count=count+1;
        featuremap.Intensity{count}=attenuateBorders(abs(imresize(intensitypyramid{c},size(intensitypyramid{5}),'nearest')-imresize(intensitypyramid{s},size(intensitypyramid{5}),'nearest')),1);
%         featuremap.Intensity{count}=abs(imresize(intensitypyramid{c},size(intensitypyramid{5}),'nearest')-imresize(intensitypyramid{s},size(intensitypyramid{5}),'nearest'));
        for idx=1:2
%             featuremap.Color{idx,count}=abs(imresize(colorpyramid{idx,c},size(colorpyramid{idx,5}),'nearest')-imresize(colorpyramid{idx,s},size(colorpyramid{idx,5}),'nearest'));
            featuremap.Color{idx,count}=attenuateBorders(abs(imresize(colorpyramid{idx,c},size(colorpyramid{idx,5}),'nearest')-imresize(colorpyramid{idx,s},size(colorpyramid{idx,5}),'nearest')),1);
        end
        for j=1:4
%             featuremap.Orientation{j,count}=abs(imresize(orientationpyramid{j,c},size(orientationpyramid{j,5}),'nearest')-imresize(orientationpyramid{j,s},size(orientationpyramid{j,5}),'nearest'));
            featuremap.Orientation{j,count}=attenuateBorders(abs(imresize(orientationpyramid{j,c},size(orientationpyramid{j,5}),'nearest')-imresize(orientationpyramid{j,s},size(orientationpyramid{j,5}),'nearest')),1);
        end
    end
end
%% combination and normalization(toolbox edition)
% 这标准化过于奇怪，包括normalization_special函数
destsize=size(intensitypyramid{5});
f=@(x) normalization_special(x,10,destsize);
featuremap.Intensity=cellfun(f,featuremap.Intensity,'UniformOutput',0);
featuremap.Color=cellfun(f,featuremap.Color,'UniformOutput',0);
featuremap.Orientation=cellfun(f,featuremap.Orientation,'UniformOutput',0);

Ibar=normalization_special(sum(cat(3,featuremap.Intensity{:}),3),0);
Cbar_temp=cell(1,2);
for i=1:2
    Cbar_temp{i}=normalization_special(sum(cat(3,featuremap.Color{i,:}),3),0);
end
Cbar=normalization_special(sum(cat(3,Cbar_temp{:}),3),0);
Obar_temp=cell(1,4);
for i=1:4
    Obar_temp{i}=normalization_special(sum(cat(3,featuremap.Orientation{i,:}),3),0);
end
Obar=normalization_special(sum(cat(3,Obar_temp{:}),3),0);
% 这里还要除也很奇怪
S=(Ibar+Cbar/2+Obar/4)/3;
S=normalization_special(S,2);
%%
h=figure;
subplot(2,2,1);imshow(Cbar,[]);title('Color');
subplot(2,2,2);imshow(Ibar,[]);title('Intensity');
subplot(2,2,3);imshow(Obar,[]);title('Orientation');
subplot(2,2,4);imshow(S,[]);title('saliency');
