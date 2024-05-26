function ImageEmbedding()
    hostImage = imread("lady.bmp"); % 载体图像
    secretImage = imread("hide.bmp"); % 要隐藏的图像
    imshow(hostImage,[])
    imshow(secretImage,[]);
    embeddedImage = Embed(hostImage, secretImage);
    extractedImage = Retrieve(embeddedImage);
end

function embeddedImage = Embed(host, secret)
    [rows, cols] = size(host);
    embeddedImage = uint8(zeros(size(host)));
    
    for i = 1:rows
        for j = 1:cols
            embeddedImage(i,j) = bitset(host(i,j),1,secret(i,j));
        end
    end
    
    imwrite(embeddedImage, 'lsb_embedded.bmp', 'bmp');
    figure;
    imshow(embeddedImage,[]);
    title("Embedded Image");
end

function extractedImage = Retrieve(embedded)
    [rowE, colE] = size(embedded);
    extractedImage = uint8(zeros(size(embedded)));

    for i = 1:rowE
        for j = 1:colE
            extractedImage(i,j) = bitget(embedded(i,j),1);
        end
    end

    figure;
    imshow(extractedImage,[]);
    title("Extracted Image");
end
