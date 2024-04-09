% Clear Memory and Command window
clc;
clear all;
close all;
b=imread("lady.jpg");%读入图像，像素值在b中
a=im2bw(b);
nbcol=size(a,1);

[ca1,ch1,cv1,cd1]=dwt2(a,'db4');
cod_ca1=wcodemat(ca1,nbcol);
cod_ch1=wcodemat(ch1,nbcol);
cod_cv1=wcodemat(cv1,nbcol);
cod_cd1=wcodemat(cd1,nbcol);

image([cod_ca1,cod_ch1;cod_cv1,cod_cd1]);
