img = imread("lady.png");
img = rgb2gray(img);    %转换为灰度图像
k = 7;      % n 的值
[a,b]=size(img);
x=zeros(a,b);
y=zeros(a,b);
z=zeros(a,b);
for n=1:k
    for i=1:a
        for j=1:b
            x(i,j)=bitget(img(i,j),n);
        end
    end
    for i=1:a
        for j=1:b
            y(i,j)=bitset(y(i,j),n,x(i,j));
        end
    end
end
for n=k+1:8
    for i=1:a
        for j=1:b
            x(i,j)=bitget(img(i,j),n);
        end
    end
    for i=1:a
        for j=1:b
            z(i,j)=bitset(z(i,j),n,x(i,j));
        end
    end
end
figure;
imshow(y,[]);
title(['第1-',num2str(k),'个位平面']);
figure;
imshow(z,[]);
title(['第',num2str(k+1),'-8 个位平面']);