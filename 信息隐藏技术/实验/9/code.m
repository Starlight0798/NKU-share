% DCT Domain Information Hiding and Extraction
clc;
clear all;
close all;

% Load images
img = imread('./lady.bmp');
watermark = imread('./hide1.bmp');

% Preprocess images
img = imresize(img, [256, 256]);
watermark = imresize(imbinarize(rgb2gray(watermark)), [64, 64]);

% Convert to double precision
img = double(img) / 256;
watermark = double(~watermark); % Inverted binary image

% Constants
blockSize = 4;
numBlocks = 256 / blockSize;

% Prepare containers for the new image and extraction vector
new_image = zeros(256);
extracted_watermark = zeros(64);

% Embed watermark
for i = 1 : numBlocks
    for j = 1 : numBlocks
        x = (i - 1) * blockSize + 1;
        y = (j - 1) * blockSize + 1;
        block = img(x:x+blockSize-1, y:y+blockSize-1);
        dct_block = dct2(block);

        % Modulate the DC component based on watermark
        modulation = (watermark(i, j) == 0) * -0.01 + (watermark(i, j) == 1) * 0.01;
        dct_block(1, 1) = dct_block(1, 1) * (1 + modulation) + modulation;
        
        % Inverse DCT to get the stego block
        new_image(x: x + blockSize - 1, y : y + blockSize - 1) = idct2(dct_block);
    end
end

% Extract watermark
for i = 1 : numBlocks
    for j = 1 : numBlocks
        x = (i - 1) * blockSize + 1;
        y = (j - 1) * blockSize + 1;
        extracted_watermark(i, j) = new_image(x, y) > img(x, y);
    end
end

% Display results
subplot(231); imshow(img, []); title('Original Image');
subplot(232); imshow(watermark, []); title('Watermark Image');
subplot(233); imshow(imcomplement(watermark), []); title('Inverted Watermark');
subplot(234); imshow(new_image, []); title('Image with Embedded Watermark');
subplot(235); imshow(extracted_watermark, []); title('Extracted Watermark');
subplot(236); imshow(imcomplement(extracted_watermark), []); title('Inverted Extracted Watermark');
