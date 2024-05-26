%% decode
clc;
clear;
encodedImage = imread('encodedImage.bmp');

% Initialize the bits array
decodedBits = zeros(1, 24);

bitIndex = 1;
blockIndex = 1;

while bitIndex < 24
    blackPixels = CalculateBlack(encodedImage, blockIndex);
    switch blackPixels
        case 0
            blockIndex = blockIndex + 4;
        case 1
            decodedBits(bitIndex) = 1;
            bitIndex = bitIndex + 1;
            blockIndex = blockIndex + 4;
        case 3
            decodedBits(bitIndex) = 0;
            bitIndex = bitIndex + 1;
            blockIndex = blockIndex + 4;
        case 4
            blockIndex = blockIndex + 4;
    end
end

% Calculate the secret message from binary bits
decodedMessage = 0;

for idx = 1:24
    decodedMessage = decodedMessage + decodedBits(idx) * 2^(idx - 1);
end

fprintf("The hidden message is: %d\n", decodedMessage);
