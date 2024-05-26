% Audio File (Wav Format) Steganography uisng LSB
% Insert Image into Audio
clear;
clc;
close all;

% Read data from cover.wav
[header, cover, bits_per_sample] = wav_read("audio/cover.wav");

% Read payload image
payload = imread("images/MisakaMikoto.png"); % Payload (Hidden Data)
payload = im2gray(payload); % Convert RGB to Gray
payload = imbinarize(payload); % Binarization

[n_row, n_col] = size(payload);
payload_len = n_row * n_col; % length of payload
assert(payload_len <= length(cover), "Payload Length should NOT be greater than cover medium!");


% Covert payload matix to sequence (NOTE: MATLAB squeeze matrix in col by default)
payload_seq = payload(:); % Squeeze into column vector


% Insert into LSB
audio_with_img = cover;
audio_with_img(1:payload_len) = bitset(cover(1:payload_len), 1, payload_seq);

% Save as wav file
fid = fopen("audio/audio_with_img.wav", "w");
fwrite(fid, header, 'uint8'); % Write Header
fwrite(fid, audio_with_img, ['uint', num2str(bits_per_sample)]); % Write Data
fclose(fid);


% Extract from LSB
[header, audio_with_img, bits_per_sample] = wav_read("audio/audio_with_img.wav");
img = bitget(audio_with_img, 1);

% Reshape sequence to matrix
img = img(1:payload_len);
img = reshape(img, n_row, n_col);


% Display Results
[cover_y, Fs_cover] = audioread("audio/cover.wav");
cover_x = (0:length(cover_y)-1) / Fs_cover;
[audio_with_img_y, Fs_audio_with_img] = audioread("audio/audio_with_img.wav");
audio_with_img_x = (0:length(audio_with_img_y)-1) / Fs_audio_with_img;

figure(1);
subplot(2, 1, 1);
plot(cover_x, cover_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Cover Medium");

subplot(2, 1, 2);
plot(audio_with_img_x, audio_with_img_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Audio with Image");

figure(2);
subplot(1, 2, 1);
imshow(payload);
title("Payload Image");
subplot(1, 2, 2);
imshow(img);
title("Extracted Image");


% Display Results in Detail
figure(3);
axis_set = [0.5, 1, -0.15, 0.15];

subplot(2, 1, 1);
plot(cover_x, cover_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Cover Medium");

subplot(2, 1, 2);
plot(audio_with_img_x, audio_with_img_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Audio with Image");
