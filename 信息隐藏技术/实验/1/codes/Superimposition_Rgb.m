% main() is the main function of the Superimposition_Rgb program.
function main()

    clc;
    clear all;
    close all;

    enc_img_path = input("Please use the absolute path to input the image to be encrypted: ", 's');
    % enc_img_path = "F:\Matlab_projects\lab1\pic\mario.jpeg";
    enc_img = imread(enc_img_path);
    disp("The size of the enc_img is: ");
    disp(size(enc_img));
    figure;
    imshow(enc_img);
    title("enc\_img");
    imwrite(enc_img, './pic/Superimposition_Rgb/enc_img.jpeg');

    original_img1_path = input("Please use the absolute path to input the image1 to be saved: ", 's');
    % original_img1_path = "F:\Matlab_projects\lab1\pic\bird.jpeg";
    original_img1 = imread(original_img1_path);
    disp("The size of the original_img1 is: ");
    disp(size(original_img1));
    figure;
    imshow(original_img1);
    title("original\_img1");
    imwrite(original_img1, './pic/Superimposition_Rgb/original_img1.jpeg');

    original_img2_path = input("Please use the absolute path to input the image2 to be saved: ", 's');
    % original_img2_path = "F:\Matlab_projects\lab1\pic\emoji.jpeg";
    original_img2 = imread(original_img2_path);
    disp("The size of the original_img2 is: ");
    disp(size(original_img2));
    figure;
    imshow(original_img2);
    title("original\_img2");
    imwrite(original_img2, './pic/Superimposition_Rgb/original_img2.jpeg');

    enc_img_size = size(enc_img);
    disp("The size of the enc_img is: ");
    disp(enc_img_size);

    x = enc_img_size(1);
    y = enc_img_size(2);
    z = enc_img_size(3);
    disp("The first size of the enc_img is: ");
    disp(x);
    disp("The second size of the enc_img is: ");
    disp(y);
    disp("The third size of the enc_img is: ");
    disp(z);

    halftone_enc_img = 255 * ones(enc_img_size);
    halftone_original_img1 = 255 * ones(enc_img_size);
    halftone_original_img2 = 255 * ones(enc_img_size);
    disp("The size of the halftone_enc_img is: ");
    disp(size(halftone_enc_img));
    disp("The size of the halftone_original_img1 is: ");
    disp(size(halftone_original_img1));
    disp("The size of the halftone_original_img2 is: ");
    disp(size(halftone_original_img2));

    img1 = 255 * ones(2 * x, 2 * y, z);
    img2 = 255 * ones(2 * x, 2 * y, z);
    disp("The size of the img1 is: ");
    disp(size(img1));
    disp("The size of the img2 is: ");
    disp(size(img2));

    merged_img = 255 * ones(2 * x, 2 * y, z);
    disp("The size of the merged_img is: ");
    disp(size(merged_img));

    for i = 1 : 3
        halftone_enc_img(:, :, i) = img_halftone(enc_img(:, :, i));
        halftone_original_img1(:, :, i) = img_halftone(original_img1(:, :, i));
        halftone_original_img2(:, :, i) = img_halftone(original_img2(:, :, i));

        [img1(:, :, i), img2(:, :, i)] = img_divide(halftone_enc_img(:, :, i), halftone_original_img1(:, :, i), halftone_original_img2(:, :, i));

        merged_img(:, :, i) = img_merge(img1(:, :, i), img2(:, :, i));
    end

    disp("The size of the halftone_enc_img is: ");
    disp(size(halftone_enc_img));
    figure;
    imshow(halftone_enc_img);
    title("halftone\_enc\_img");
    imwrite(halftone_enc_img, './pic/Superimposition_Rgb/halftone_enc_img.bmp');

    disp("The size of the halftone_original_img1 is: ");
    disp(size(halftone_original_img1));
    figure;
    imshow(halftone_original_img1);
    title("halftone\_original\_img1");
    imwrite(halftone_original_img1, './pic/Superimposition_Rgb/halftone_original_img1.bmp');

    disp("The size of the halftone_original_img2 is: ");
    disp(size(halftone_original_img2));
    figure;
    imshow(halftone_original_img2);
    title("halftone\_original\_img2");
    imwrite(halftone_original_img2, './pic/Superimposition_Rgb/halftone_original_img2.bmp');

    disp("The size of the img1 is: ");
    disp(size(img1));
    figure;
    imshow(img1);
    title("img1");
    imwrite(img1, './pic/Superimposition_Rgb/img1.bmp');

    disp("The size of the img2 is: ");
    disp(size(img2));
    figure;
    imshow(img2);
    title("img2");
    imwrite(img2, './pic/Superimposition_Rgb/img2.bmp');

    disp("The size of the merged_img is: ");
    disp(size(merged_img));
    figure;
    imshow(merged_img);
    title("merged\_img");
    imwrite(merged_img, './pic/Superimposition_Rgb/merged_img.bmp');
end


% img_halftone(gray_img): This function performs halftoning on a grayscale image using error diffusion.
%
% Input:
% - gray_img: The input grayscale image.
%
% Output:
% - img: The halftoned image.
%
function img = img_halftone(gray_img)
    img_size = size(gray_img);
    disp("The size of the gray_img is: ");
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

    for m = 1 : x
        for n = 1 : y
            if gray_img(m, n) > 127
                out = 255;
            else
                out = 0;
            end

            error = gray_img(m, n) - out;

            if n > 1 && n < 255 && m < 255
                gray_img(m, n + 1) = gray_img(m, n + 1) + error * 7 / 16.0;  % 右方
                gray_img(m + 1, n) = gray_img(m + 1, n) + error * 5 / 16.0;  % 下方
                gray_img(m + 1, n - 1) = gray_img(m + 1, n - 1) + error * 3 / 16.0;  % 左下方
                gray_img(m + 1, n + 1) = gray_img(m + 1, n + 1) + error * 1 / 16.0;  % 右下方
                gray_img(m, n) = out;
            else
                gray_img(m, n) = out;
            end
        end
    end

    img = gray_img;

end



% img_divide: Divide three input image into two images, img1 and img2, by applying a specific pattern.
%
% Inputs:
%   enc_img - the encrypted input image to be divided
%   original_img1 - the first partition input image to be divided
%   original_img2 - the second partition input image to be divided
%
% Outputs:
%   img1 - the first divided image
%   img2 - the second divided image
%
function [img1, img2] = img_divide(enc_img, original_img1, original_img2)

    img_size = size(enc_img);
    disp("The size of the enc_img is: ");
    disp(img_size);

    x = img_size(1);
    y = img_size(2);
    disp("The first size of the enc_img is: ");
    disp(x);
    disp("The second size of the enc_img is: ");
    disp(y);

    img1 = 255 * ones(2 * x, 2 * y);
    img2 = 255 * ones(2 * x, 2 * y);
    disp("The size of the img1 is: ");
    disp(size(img1));
    disp("The size of the img2 is: ");
    disp(size(img2));

    for i = 1 : x
        for j = 1 : y
            new_img_row = 2 * (i - 1) + 1;
            new_img_col = 2 * (j - 1) + 1;
            key = randi(4);
            
            switch key
                % 前面已经对 img1 和 img2 赋值为全白，初值为 1，故而只需要调整其对应位置的像素值为 0 即可
                case 1
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑  黑  黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    end
                    
                case 2
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    end
                    
                case 3
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑 黑 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    end
                    
                case 4
                    if enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 黑 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 黑 黑 白
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 黑 白 黑
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) == 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 黑 白 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) == 0  % 白 黑 黑
                        img1(new_img_row, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) == 0 && original_img2(i, j) ~= 0  % 白 黑 白
                        img1(new_img_row, new_img_col + 1) = 0;
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) ~= 0  % 白 白 白
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col + 1) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
                    elseif enc_img(i, j) ~= 0 && original_img1(i, j) ~= 0 && original_img2(i, j) == 0  % 白 白 黑
                        img1(new_img_row + 1, new_img_col) = 0;
                        img1(new_img_row + 1, new_img_col + 1) = 0;
                        
                        img2(new_img_row, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col) = 0;
                        img2(new_img_row + 1, new_img_col + 1) = 0;
                        
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