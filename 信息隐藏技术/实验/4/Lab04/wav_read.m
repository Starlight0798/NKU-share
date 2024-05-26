function [header, data, bits_per_sample] = wav_read(file_path)
%WAV_READ Read the `Data` Field of Data Chunk of wav Format File
%   file_path: path to wav file
%   header: all data before the `Data` Field of Data Chunk
%   data: the `Data` Field of Data Chunk
%   bits_per_sample: Bits Per Sample

fid = fopen(file_path, "r"); % Open the wav file

header = fread(fid, 44, 'uint8'); % Header

fseek(fid, 34, 'bof'); % Shift the file pointer to `BitsPerSample` field
bits_per_sample = fread(fid, 1, 'uint16'); % BitsPerSample (2Bytes, Little-Endian)

fseek(fid, 44, 'bof'); % Shift the file pointer to `Data` field of Data Chunk
data = fread(fid, ['uint', num2str(bits_per_sample)]); % `Data` field of Data Chunk

fclose(fid); % Close file

end
