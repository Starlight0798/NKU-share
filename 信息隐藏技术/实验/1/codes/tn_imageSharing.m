% main() is the main function of the t&n_imageSharing program.
function main
    clear;
    close all;

    height = 256;
    width = 256;
    blocks = 4;
    polynomial_degree = 8;
    selected_users = [1, 3, 5, 8];
    modulo_base = 257;

    subWidth  = width / blocks ^ (0.5);
    subHeight = height / blocks ^ (0.5);

    img_path = input("Please use the absolute path to input the image to be processed: ", 's');
    % img_path = "/Users/lxmliu2002/Desktop/matlab/lab1/pic/lena.bin";

    original_img = fopen(img_path, 'rb');
    liner_img = fread(original_img, 'uint8');
    original_img = uint8(reshape(liner_img, height, width)');
    figure;
    imshow(original_img);
    title('original\_img');
    imwrite(original_img, './pic/t&n/original_img.bmp');

    prepared_img = reshape(liner_img, [], blocks);
    shadow_img = img_shadow(prepared_img, polynomial_degree, modulo_base);
    show_shadow_imgs(shadow_img, subWidth, subHeight);
    required_shadow_img = img_required_shadow(shadow_img, selected_users);

    merged_img = img_merge(required_shadow_img, selected_users, height, width, modulo_base);
    figure;
    imshow(uint8(merged_img));
    title('merged\_img');
    imwrite(uint8(merged_img), './pic/t&n/merged_img.bmp')
end

% img_shadow: Generates a shadow image using secret image sharing scheme.
%
%   Inputs:
%   - prepared_img: The prepared image to generate the shadow image from.
%   - polynomial_degree: The degree of the polynomial used in the scheme.
%   - modulo_base: The base value used for modulo operation.
%
%   Outputs:
%   - shadow_img: The generated shadow image.
%
function shadow_img = img_shadow(prepared_img, polynomial_degree, modulo_base)
    % Convert the image size to int32
    imageSize = int32(size(prepared_img));
    
    % Convert the prepared image, polynomial degree, and modulo base to int32
    prepared_img = int32(prepared_img);
    polynomial_degree = int32(polynomial_degree);
    modulo_base = int32(modulo_base);
    
    % Initialize the shadow image matrix
    shadow_img = int32(zeros(imageSize(1), polynomial_degree)); 
    
    % Generate the shadow image
    for i = 1 : polynomial_degree
        for j = 1 : imageSize(2)
            shadow_img(:, i) = shadow_img(:, i) + mod(prepared_img(:, j) * i ^ (j - 1), modulo_base);
        end
    end
    
    % Apply modulo operation to the shadow image
    shadow_img = mod(shadow_img, modulo_base);
end

% show_shadow_imgs - Displays and saves shadow images.
%
% Inputs:
% - shadow_img: A matrix representing the shadow images. Each column of the matrix represents a shadow image.
% - subWidth: The width of each sub-image in the shadow images.
% - subHeight: The height of each sub-image in the shadow images.
%
function show_shadow_imgs(shadow_img, subWidth, subHeight)
    imageSize = size(shadow_img);
    for i = 1 : imageSize(2)
        figure;
        imshow(uint8(reshape(shadow_img(:, i), subWidth, subHeight)));
        title(['shadow\_img ' num2str(i)]);
        imwrite(uint8(reshape(shadow_img(:, i), subWidth, subHeight)), ['./pic/t&n/shadow_img_' num2str(i) '.bmp']);
    end
end


% img_required_shadow - Extracts the required shadow images from the given shadow image matrix based on the selected users.
%
% Inputs:
%   - shadow_img: A matrix representing the shadow image, where each column represents a user's shadow image.
%   - selected_users: A vector containing the indices of the selected users.
%
% Output:
%   - required_shadow_img: A matrix containing the required shadow images, where each column represents a selected user's shadow image.
%
function required_shadow_img = img_required_shadow(shadow_img, selected_users)
    selectedUsersCount = length(selected_users);
    for i = 1 : selectedUsersCount
        required_shadow_img(:, i) = shadow_img(:, selected_users(i));  
    end
end


% img_merge - Merge multiple shadow images to reconstruct the original image.
%
% Inputs:
%   - required_shadow_img: A matrix representing the required shadow images. Each row represents a shadow image.
%   - selected_users: A vector representing the selected users. Each element represents a user.
%   - height: The height of the original image.
%   - width: The width of the original image.
%   - modulo_base: The modulo base used for arithmetic operations.
%
% Outputs:
%   - merge_img: The reconstructed original image.
%
function merge_img = img_merge(required_shadow_img, selected_users, height, width, modulo_base)
    imageSize = size(required_shadow_img);
    xx = ones(imageSize(2), imageSize(2));
    for i = 1 : imageSize(2)
        xx(:, i) = xx(:, i) .* (selected_users.^(i - 1))';
    end
    for i = 1 : imageSize(1)
        if(mod(i, 100) == 0)
            fprintf('%d of %d\n', i / 100, floor(imageSize(1) / 100));
        end
        merge_img(i, :) = get_mod(inv(sym(xx)) * required_shadow_img(i, :)', modulo_base)';
    end
    merge_img = reshape(merge_img(:), height, width)';
end


% get_mod - Computes the modulo of a rational number with respect to a given base.
%
% Inputs:
%   - b: The rational number to compute the modulo for.
%   - modulo_base: The base with respect to which the modulo is computed.
%
% Outputs:
%   - re_b: The modulo of the rational number b with respect to modulo_base.
%
function re_b = get_mod(b, modulo_base)
    [n, d] = numden(b);
    n = double(n);
    d = double(d);
    re_b = mod(n .* power_mod(d, -1, modulo_base), modulo_base);
end

% power_mod - Computes the modular exponentiation of a number.
% 
% Inputs:
%   a - Base number.
%   z - Exponent.
%   n - Modulus.
%
% Outputs:
%   y - Result of the modular exponentiation.
%
function y = power_mod(a, z, n)
    [ax, ay] = size(a);
    a = mod(a, n);
    if (z < 0)
        z = - z;
        for j = 1 : ax
            for k = 1 : ay
                a(j, k) = inv_mod_n(a(j, k), n);
            end
        end   
    end

    for j = 1 : ax
        for k = 1 : ay
            x = 1;
            a1 = a(j, k);
            z1 = z;
            while (z1 ~= 0)
                while (mod(z1, 2) == 0)
                    z1 = (z1 / 2);
                    a1 = mod((a1 * a1), n);
                end
                z1 = z1 - 1;
                x = x * a1;
                x = mod(x, n);
            end
            y(j, k) = x;  
        end
    end
end


% inv_mod_n calculates the modular inverse of a number modulo n.
%
% Inputs:
%   - b: The number for which the modular inverse is to be calculated.
%   - n: The modulus.
%
% Outputs:
%   - y: The modular inverse of b modulo n. If no inverse exists, y is an empty array.
%
function y = inv_mod_n(b, n)
    n0 = n;
    b0 = b;
    t0 = 0;
    t = 1;

    q = floor(n0 / b0);
    r = n0 - q * b0;
    while r > 0
        temp = t0 - q * t;
        if (temp >= 0)
            temp = mod(temp, n);
        end
        if (temp < 0)
            temp = n - ( mod(- temp, n));
        end
        t0 = t;
        t = temp;
        n0 = b0;
        b0 = r;
        q = floor(n0 / b0);
        r = n0 - q * b0;
    end

    if b0 ~= 1
        y = [];
        disp('No inverse');
    else
        y = mod(t, n);
    end   
end
