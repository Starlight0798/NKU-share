function SteganographyDemo()
    carrierImage = imread('lady.bmp');
    watermarkImage = imread('hide.bmp');

    disp(['Carrier image dimensions: ', mat2str(size(carrierImage))]);
    disp(['Carrier image type: ', class(carrierImage)]);
    disp(['Watermark image dimensions: ', mat2str(size(watermarkImage))]);
    disp(['Watermark image type: ', class(watermarkImage)]);
    
    subplot(2, 2, 1);
    imshow(carrierImage); title('Original Image');

    subplot(2, 2, 2); 
    imshow(watermarkImage); title('Watermark Image');

    [height, width] = size(watermarkImage);

    carrierImage = EmbedWatermark(carrierImage, height, width, watermarkImage);
    subplot(2, 2, 3); 
    imshow(carrierImage, []); title('Steganographed Image');

    extractedImage = ExtractWatermark();
    subplot(2, 2, 4);
    imshow(extractedImage, []); title('Extracted Watermark');
end

function parity = calculateParity(imageMatrix, row, col)
    pixelData = zeros(1, 4);
    pixelData(1) = bitget(imageMatrix(2*row-1, 2*col-1), 1); 
    pixelData(2) = bitget(imageMatrix(2*row-1, 2*col), 1); 
    pixelData(3) = bitget(imageMatrix(2*row, 2*col-1), 1); 
    pixelData(4) = bitget(imageMatrix(2*row, 2*col), 1); 
    parity = mod(sum(pixelData), 2); 
end 

function modifiedImage = EmbedWatermark(carrier, rows, cols, watermark)
    for row = 1:rows 
        for col = 1:cols 
            if calculateParity(carrier, row, col) ~= watermark(row, col)
                pixel = int8(rand() * 3);
                switch pixel
                    case 0
                        carrier(2*row-1, 2*col-1) = bitset(carrier(2*row-1, 2*col-1), 1, ~bitget(carrier(2*row-1, 2*col-1), 1));
                    case 1
                        carrier(2*row-1, 2*col) = bitset(carrier(2*row-1, 2*col), 1, ~bitget(carrier(2*row-1, 2*col), 1));
                    case 2
                        carrier(2*row, 2*col-1) = bitset(carrier(2*row, 2*col-1), 1, ~bitget(carrier(2*row, 2*col-1), 1));
                    case 3
                        carrier(2*row, 2*col) = bitset(carrier(2*row, 2*col), 1, ~bitget(carrier(2*row, 2*col), 1));
                end
            end
        end
    end
    imwrite(carrier, 'watermarkedImage.bmp');
    modifiedImage = carrier;
end

function output = ExtractWatermark()
    watermarkedImage = imread('watermarkedImage.bmp');
    [height, width] = size(watermarkedImage);
    watermark = zeros(height/2, width/2);
    for row = 1:height/2
        for col = 1: width/2
            watermark(row, col) = calculateParity(watermarkedImage, row, col);
        end
    end
    output = watermark;
end
