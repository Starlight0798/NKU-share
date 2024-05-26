%% encode
clc;
clear;
inputImage = imread('./lady.bmp');
binaryImage = imbinarize(inputImage);
imwrite(binaryImage, 'processedImage.bmp', 'bmp');
subplot(1, 2, 1);
imshow(binaryImage, []);
title('Original Image');
hiddenMessage = 2113997;

for bitIndex = 1:24
    messageBits(bitIndex) = bitget(hiddenMessage, bitIndex);
end

pixelIndex = 1;
currentBit = 1;

while currentBit < 24

    if messageBits(currentBit) == 0

        blackPixels = CalculateBlack(binaryImage, pixelIndex);

        switch blackPixels
            case 0
                currentBit = currentBit - 1;
                pixelIndex = pixelIndex + 4;
            case 1
                count = 1;
                adjustIndex = pixelIndex;

                while count < 3
                    if binaryImage(adjustIndex) == 1
                        binaryImage(adjustIndex) = 0;
                        count = count + 1;
                        adjustIndex = adjustIndex + 1;
                    end
                end

                pixelIndex = pixelIndex + 4;
            case 2
                count = 2;
                adjustIndex = pixelIndex;

                while count < 3
                    if binaryImage(adjustIndex) == 1
                        binaryImage(adjustIndex) = 0;
                        count = count + 1;
                        adjustIndex = adjustIndex + 1;
                    end
                end

                pixelIndex = pixelIndex + 4;
            case 3
                pixelIndex = pixelIndex + 4;
            case 4
                count = 4;
                adjustIndex = pixelIndex;

                while count > 3
                    if binaryImage(adjustIndex) == 0
                        binaryImage(adjustIndex) = 1;
                        count = count - 1;
                        adjustIndex = adjustIndex + 1;
                    end
                end

                pixelIndex = pixelIndex + 4;
        end

    else
        blackCount = CalculateBlack(binaryImage, pixelIndex);

        switch blackCount
            case 0
                count = 4;
                adjustIndex = pixelIndex;

                while count > 3
                    if binaryImage(adjustIndex) == 1
                        binaryImage(adjustIndex) = 0;
                        count = count - 1;
                        adjustIndex = adjustIndex + 1;
                    end
                end

                pixelIndex = pixelIndex + 4;
            case 1
                pixelIndex = pixelIndex + 4;
            case 2
                count = 2;
                adjustIndex = pixelIndex;

                while count < 3
                    if binaryImage(adjustIndex) == 0
                        binaryImage(adjustIndex) = 1;
                        count = count + 1;
                        adjustIndex = adjustIndex + 1;
                    end
                end

                pixelIndex = pixelIndex + 4;
            case 3
                count = 1;
                adjustIndex = pixelIndex;

                while count < 3
                    if binaryImage(adjustIndex) == 0
                        binaryImage(adjustIndex) = 1;
                        count = count + 1;
                        adjustIndex = adjustIndex + 1;
                    end
                end

                pixelIndex = pixelIndex + 4;
            case 4
                currentBit = currentBit - 1;
                pixelIndex = pixelIndex + 4;
        end
    end

    currentBit = currentBit + 1;
end

imwrite(binaryImage, 'encodedImage.bmp', 'bmp');
subplot(1, 2, 2);
imshow(binaryImage, []);
title('Image with Watermark');
