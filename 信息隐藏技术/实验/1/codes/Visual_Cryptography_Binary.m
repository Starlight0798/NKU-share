% main() is the main function of the visualCryp program.
function main()

    clc;
    clear all;
    close all;
    
    img_path = input("Please use the absolute path to input the image to be processed: ", 's');
    % img_path = "/Users/lxmliu2002/Desktop/matlab/lab1/pic/NKU70.bmp";

    original_img = imresize(imread(img_path), 0.25);
    disp("The size of the original image is: ");
    disp(size(original_img));
    figure;
    imshow(original_img);
    title('original\_img');
    imwrite(original_img, './pic/Visual_Cryptography_Binary/original_img.bmp');

    [img1, img2] = img_divide(original_img);
    disp("The size of the divided image is: ");
    disp(size(img1));
    disp("The size of the divided image is: ");
    disp(size(img2));
    figure;
    imshow(img1);
    title('img1');
    imwrite(img1, './pic/Visual_Cryptography_Binary/img1.bmp');
    figure;
    imshow(img2);
    title('img2');
    imwrite(img2, './pic/Visual_Cryptography_Binary/img2.bmp');

    merged_img = img_merge(img1, img2);
    disp("The size of the merged image is: ");
    disp(size(merged_img));
    figure;
    imshow(merged_img);
    title('merged\_img');
    imwrite(merged_img, './pic/Visual_Cryptography_Binary/merged_img.bmp');

    % Check if the size of original_img and merged_img are the same
    if isequal(2 * size(original_img), size(merged_img))
        disp('Congratulations');
    else
        error('The size of the original image and the merged image do not match');
    end
end



% img_divide: Divide an input image into two images, img1 and img2, by applying a specific pattern.
%
% Inputs:
%   img - the input image to be divided
%
% Outputs:
%   img1 - the first divided image
%   img2 - the second divided image
%
function [img1, img2] = img_divide(img)

    img_size = size(img);
    disp("The size of the input image is: ");
    disp(img_size);

    x = img_size(1); % x 为 img_size 的第一个参数
    y = img_size(2); % y 为 img_size 的第二个参数
    img1 = 255 * ones(2 * x, 2 * y); % 将 img1 初始化为全白图像
    img2 = 255 * ones(2 * x, 2 * y); % 将 img2 初始化为全白图像
    disp("The size of the img1 is: ");
    disp(size(img1));
    disp("The size of the img2 is: ");
    disp(size(img2));

    for i = 1 : x
        for j = 1 : y
            new_img_row = 2 * (i - 1) + 1;
            new_img_col = 2 * (j - 1) + 1;
            key = randi(3);

            switch key
                case 1
                    img2(new_img_row, new_img_col) = 0;
                    img2(new_img_row, new_img_col + 1) = 0;

                    if img(i, j) == 1 % original_img is white
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                    else % original_img is black
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                    end

                case 2
                    img2(new_img_row, new_img_col) = 0;
                    img2(new_img_row + 1, new_img_col + 1) = 0;

                    if img(i, j) == 1 % original_img is white
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                    else % original_img is black
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                    end

                case 3
                    img2(new_img_row, new_img_col) = 0;
                    img2(new_img_row + 1, new_img_col) = 0;

                    if img(i, j) == 1 % original_img is white
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                    else % original_img is black
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                    end

            end
        end
    end

end



% img_merge: Merge two images using bitwise AND operation.
%
% Input Arguments:
%   - img1: First input image.
%   - img2: Second input image.
%
% Output Argument:
%   - img: Merged image with the same size as img1 and img2.
%
function img = img_merge(img1, img2)
    img_size = size(img1); % 两张图像的尺寸一致，故而此处以 img1 的 size 作为 img 的 size
    disp("The size of the img1 is: ");
    disp(img_size);
    
    %%
    % 该方法无法准确赋值，故而使用后面的分别进行赋值
    % [x, y] = img_size; % x 为 size 的第一个参数，y 为 size 的第二个参数
    %%
    
    x = img_size(1); % x 为 img_size 的第一个参数
    y = img_size(2); % y 为 img_size 的第二个参数
    disp("The first size of the img1 is: ");
    disp(x);
    disp("The second size of the img1 is: ");
    disp(y);

    img = 255 * ones(x, y); % 将 img 初始化为全白图像
    disp("The size of the merged img is: ");
    disp(size(img));
    
    for i = 1 : x
        for j = 1 : y
            img(i, j) = img1(i, j) & img2(i, j);
        end
    end

    disp("The size of the merged img is: ");
    disp(size(img));

end

