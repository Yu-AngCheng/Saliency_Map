%% Reduce an image applying Gaussian/Oriented Gabor Pyramid.
% 一般的操作是，构建高斯核，对原图像卷积，卷完后，偶数行删光
% special版本意味着不同于二维高斯核，采用一维，分别对行列进行卷积
function IResult=pyramid_reduce_special(I,varargin)
filter = [1,5,10,10,5,1,1]; 
filter = filter/sum(filter);
dim = size(I);
IResult=sepConv2PreserveEnergy(filter,filter,I);
idx_row=1:2:dim(1);idx_column=1:2:dim(2);
IResult=IResult(idx_row,idx_column);
end




