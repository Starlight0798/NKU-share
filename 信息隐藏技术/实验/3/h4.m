% Clear Memory and Command window
clc;
clear all;
close all;
b=imread("lady.jpg");%读入图像，像素值在b中
b=rgb2gray(b);%转换为灰度图像

figure(1);
imshow(b);
title('(a)原图像');

I=im2bw(b);
figure(2);
c=dct2(I);%进行离散余弦变换
imshow(c);
title('(b)DCT变换系数');

figure(3);
mesh(c);%画网格曲面图
title('(c)DCT变换系数（立体视图）');
