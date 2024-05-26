img = imread("lady.png");
img = rgb2gray(img);    %转换为灰度图像
k = 8;      %要显示的位平面
[m,n]=size(img);
c=zeros(m,n);
for i=1:m
    for j=1:n
        c(i,j)=bitget(img(i,j),k);
    end
end
figure;
imshow(c,[]);
title(['第',num2str(k),'个位平面']);