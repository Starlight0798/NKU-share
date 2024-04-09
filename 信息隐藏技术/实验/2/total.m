%%
clc;
clear variables;
close all;
% 再次读取音频文件进行DWT分析
[signal, samplingRate] = audioread('voice.wav'); 
% FFT分析
signalFFT = fft(signal); 
subplot(6,1,1); 
plot(abs(fftshift(signalFFT)));
title('FFT Spectrum'); 
% DWT变换
[dwtApprox, dwtDetail] = dwt(signal(:,1), 'db4'); 
% IDWT重构信号
reconstructedSignal = idwt(dwtApprox, dwtDetail, 'db4', length(signal(:,1))); 
% 绘制DWT分析结果
subplot(6,1,2); plot(signal(:,1)); title('Original Signal');
subplot(6,1,3); plot(dwtDetail); title('DWT Details');
subplot(6,1,4); plot(dwtApprox); title('DWT Approximations');
subplot(6,1,5); plot(reconstructedSignal); title('Reconstructed Signal');

% DCT变换
dctResult = dct(signal); 
subplot(6,1,6); plot(dctResult);
title('DCT of the Signal');