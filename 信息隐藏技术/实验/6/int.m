function NumEmbedding()
    baseImage = imread("lady.bmp");  % 载体图像
    numberToHide = 2113997;          % 要嵌入的数字信息（学号）
    imshow(baseImage,[])
    EmbeddedImage = EmbedNumber(baseImage, numberToHide);
    extractedNumber = ExtractNumber(EmbeddedImage);
    fprintf('Extracted number: %d\n', extractedNumber);
end

function EmbeddedImage = EmbedNumber(baseImg, num)
    [rowBase, colBase] = size(baseImg);
    EmbeddedImage = uint8(zeros(size(baseImg)));
    
    for i = 1:rowBase
        for j = 1:colBase
            if i == 1 && j <= 22  % 假定学号的二进制长度不超过22位
                bitToEmbed = bitget(num, j);
                EmbeddedImage(i,j) = bitset(baseImg(i,j), 1, bitToEmbed);
            else
                EmbeddedImage(i,j) = baseImg(i,j);
            end
        end
    end
    
    imwrite(EmbeddedImage, 'lsb_num_embedded.bmp', 'bmp');
    figure;
    imshow(EmbeddedImage,[]);
    title("Embedded Image");
end

function extractedNum = ExtractNumber(EmbeddedImg)
    extractedNum = 0;
    for j = 1:22  % 读取前22位，假定学号的二进制长度为22位
        bitExtracted = bitget(EmbeddedImg(1,j), 1);
        extractedNum = bitset(extractedNum, j, bitExtracted);
    end
end
