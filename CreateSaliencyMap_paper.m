% for paper edition
% 整体上表现得比toolbox来的好，但是对于orientation还是特别差劲
clear
%% load image
image=im2double(imread('3.jpg'));
imagesize=size(image);
%% get feature(paper edition)
intensity=mean(image,3);
r=zeros(imagesize(1),imagesize(2));g=r;b=r;
idx=intensity>max(intensity(:))/10;
temp=image(:,:,1);r(idx)=temp(idx)./intensity(idx);r(isnan(r))=0;
temp=image(:,:,2);g(idx)=temp(idx)./intensity(idx);g(isnan(g))=0;
temp=image(:,:,3);b(idx)=temp(idx)./intensity(idx);b(isnan(b))=0;
R=r-(g+b)/2;R(R<0)=0;
G=g-(r+b)/2;G(G<0)=0;
B=b-(r+g)/2;B(B<0)=0;
Y=(r+g)/2-abs(r-g)/2-b;Y(Y<0)=0;
%% make pyramid(paper edition)
% 注意这里的颜色通道是分别处理的
intensitypyramid=cell(1,9);intensitypyramid{1}=intensity;
for levels=2:9
    intensitypyramid{levels}=pyramid_reduce(intensitypyramid{levels-1});
end
colorpyramid=cell(4,9);colorpyramid{1,1}=R;colorpyramid{2,1}=G;colorpyramid{3,1}=B;colorpyramid{4,1}=Y;
for levels=2:9
    for specificcolor=1:4
        colorpyramid{specificcolor,levels}=pyramid_reduce(colorpyramid{specificcolor,levels-1});
    end
end
Wt2=[1,4,6,4,1;
    4,16,24,16,4;
    6,24,36,24,6;
    4,16,24,16,4;
    1,4,6,4,1]/256;
orientationpyramid=cell(4,9);
for levels=1:9
    for orientation=0:45:315
        [x,y]=meshgrid(1:length(Wt2));
        center=ceil(length(Wt2)/2);x=x-center;y=y-center;
        Period=7;
        cosine=cos((sind(orientation)*x+cosd(orientation)*y)*2*pi/Period);
        sine=cos((sind(orientation)*x+cosd(orientation)*y)*2*pi/Period+pi/2);
        % 这个标准化也很奇怪，为什么要用两个算子也不得而知
        filter1=Wt2.*cosine;filter1=filter1-mean(filter1(:));
        filter1=filter1/sqrt(sum(filter1(:).^2));
        filter2=Wt2.*sine;filter2=filter2-mean(filter2(:));
        filter2=filter2/sqrt(sum(filter2(:).^2));
        orientationpyramid{orientation/45+1,levels}=...
            abs(imfilter(intensitypyramid{levels},filter1,'same',mean(intensitypyramid{levels},'all')));
            abs(imfilter(intensitypyramid{levels},filter2,'same',mean(intensitypyramid{levels},'all')));
    end
end
%% center-surround difference(paper edition)
% 直到这里颜色通道才合并
featuremap.Intensity=cell(1,6);
featuremap.Color=cell(2,6);
featuremap.Orientation=cell(8,6);
count=0;
for c=3:5
    for delta=3:4
        s=c+delta;
        count=count+1;
        % 这里是resize到finer scale而不是destination scale
        featuremap.Intensity{count}=abs(intensitypyramid{c}-imresize(intensitypyramid{s},size(intensitypyramid{c}),'nearest'));
        featuremap.Color{1,count}=abs(colorpyramid{1,c}-colorpyramid{2,c}-...
            imresize(colorpyramid{2,s}-colorpyramid{1,s},size(colorpyramid{1,c}),'nearest'));
        featuremap.Color{2,count}=abs(colorpyramid{3,c}-colorpyramid{4,c}-...
            imresize(colorpyramid{4,s}-colorpyramid{3,s},size(colorpyramid{3,c}),'nearest'));
        for i=1:8
            featuremap.Orientation{i,count}=abs(orientationpyramid{i,c}-imresize(orientationpyramid{i,s},size(orientationpyramid{i,c}),'nearest'));
        end
    end
end
%% combination and normalization(paper edition)
destsize=size(intensitypyramid{5});
f=@(x) normalization(x,destsize);
featuremap.Intensity=cellfun(f,featuremap.Intensity,'UniformOutput',0);
featuremap.Color=cellfun(f,featuremap.Color,'UniformOutput',0);
featuremap.Orientation=cellfun(f,featuremap.Orientation,'UniformOutput',0);

Ibar=normalization(sum(cat(3,featuremap.Intensity{:}),3));
Cbar_temp=cell(1,2);
for i=1:2
    Cbar_temp{i}=normalization(sum(cat(3,featuremap.Color{i,:}),3));
end
Cbar=normalization(sum(cat(3,Cbar_temp{:}),3));
Obar_temp=cell(1,4);
for i=1:8
    Obar_temp{i}=normalization(sum(cat(3,featuremap.Orientation{i,:}),3));
end
Obar=normalization(sum(cat(3,Obar_temp{:}),3));
S=normalization((Ibar+Cbar+Obar)/3);
%%
h=figure;
subplot(2,2,1);imshow(Cbar,[]);title('Color');
subplot(2,2,2);imshow(Ibar,[]);title('Intensity');
subplot(2,2,3);imshow(Obar,[]);title('Orientation');
subplot(2,2,4);imshow(S,[]);title('saliency');
