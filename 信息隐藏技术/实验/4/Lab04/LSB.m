% Audio File (Wav Format) Steganography uisng LSB
clear;
clc;
close all;

% Read data from cover.wav
[header, cover, bits_per_sample] = wav_read("audio/cover.wav");

% Read data from payload.wav in bit
fid = fopen("audio/payload.wav", "r"); % Open file
payload = fread(fid, 'ubit1');
fclose(fid); % Close file

payload_len = length(payload); % length of payload
assert(payload_len <= length(cover), "Payload Length should NOT be greater than cover medium!");


% Insert into LSB
audio_with_info = cover;
audio_with_info(1:payload_len) = bitset(cover(1:payload_len), 1, payload);

% Save as wav file
fid = fopen("audio/audio_with_info.wav", "w");
fwrite(fid, header, 'uint8'); % Write Header
fwrite(fid, audio_with_info, ['uint', num2str(bits_per_sample)]); % Write Data
fclose(fid);


% Extract from LSB
[header, audio_with_info, bits_per_sample] = wav_read("audio/audio_with_info.wav");
info = bitget(audio_with_info, 1);

% Get the true size of info
info_len_bits = info(33:64);
info_len = uint32(0);
for i = 1:32
    info_len = bitset(info_len, i, info_len_bits(i));
end
info_len = info_len + 8; % Count in bytes (Add length of `ChunkID` and `ChunkSize`, 8 bytes in total)
info_len = info_len * 8; % Count in bits

fid = fopen("audio/info.wav", "w");
fwrite(fid, info(1:info_len), 'ubit1'); % Save info.wav
fclose(fid);


% Display Results
[cover_y, Fs_cover] = audioread("audio/cover.wav");
cover_x = (0:length(cover_y)-1) / Fs_cover;
[payload_y, Fs_payload] = audioread("audio/payload.wav");
payload_x = (0:length(payload_y)-1) / Fs_payload;
[audio_with_info_y, Fs_audio_with_info] = audioread("audio/audio_with_info.wav");
audio_with_info_x = (0:length(audio_with_info_y)-1) / Fs_audio_with_info;
[info_y, Fs_info] = audioread("audio/info.wav");
info_x = (0:length(info_y)-1) / Fs_info;

figure(1);
subplot(2, 2, 1);
plot(cover_x, cover_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Cover Medium");

subplot(2, 2, 2);
plot(payload_x, payload_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Payload Audio");

subplot(2, 2, 3);
plot(audio_with_info_x, audio_with_info_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Audio with Info");

subplot(2, 2, 4);
plot(info_x, info_y);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Extracted Audio");


% Display Results in Detail
figure(2);
axis_set = [0.5, 1, -1, 1];

subplot(2, 2, 1);
plot(cover_x, cover_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Cover Medium");

subplot(2, 2, 2);
plot(payload_x, payload_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Payload Audio");

subplot(2, 2, 3);
plot(audio_with_info_x, audio_with_info_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Audio with Info");

subplot(2, 2, 4);
plot(info_x, info_y);
axis(axis_set);
xlabel('Time / (s)'); ylabel('Amplitude');
title("Extracted Audio");
