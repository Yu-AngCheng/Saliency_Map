%% Reduce an image applying Gaussian/Oriented Gabor Pyramid.
% 一般的操作是，构建高斯核，对原图像卷积，卷完后，偶数行删光
function IResult=pyramid_reduce(I,varargin)
%计算核
Wt2=[1,4,6,4,1;
    4,16,24,16,4;
    6,24,36,24,6;
    4,16,24,16,4;
    1,4,6,4,1]/256;
dim = size(I);
IResult=imfilter(I,Wt2,'same',mean(I(:)));
idx_row=1:2:dim(1);idx_column=1:2:dim(2);
IResult=IResult(idx_row,idx_column);
end




