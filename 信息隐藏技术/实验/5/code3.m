img = imread("lady.png");
img = rgb2gray(img);    %转换为灰度图像
k = 7;      % n 的值
[a,b]=size(img);
for n=1:k
    for i=1:a
        for j=1:b
            img(i,j)=bitset(img(i,j),n,0);
        end
    end
end
figure;
imshow(img,[]);
title(['去除前',num2str(k),'个位平面']);