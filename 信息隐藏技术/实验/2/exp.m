% 初始化：清除内存，关闭图形窗口，并清空命令窗口
clc;
clear variables; % 使用clear variables替换clear all以提升代码质量
close all;
% 定义音频文件名称并读取音频数据
audioFilename = 'voice.wav'; 
[signalData, sampleRate] = audioread(audioFilename); 
plot(signalData);
title('Original Audio Signal'); % 添加标题
%%
clc;
clear variables;
close all;
% FFT分析
[signal, freq] = audioread('voice.wav'); 
signalFFT = fft(signal); 
plot(abs(fftshift(signalFFT)));
title('FFT Analysis Result'); 
%%
clc;
clear variables;
close all;
% DWT分析
[origSignal, origSampleRate] = audioread("voice.wav"); 
[approxComponents, detailComponents] = dwt(origSignal(:,1), 'db4'); 
reconstructedSignal = idwt(approxComponents, detailComponents, 'db4', length(origSignal(:,1))); 
% 绘制DWT分析结果
subplot(2, 2, 1); plot(origSignal(:, 1)); title('Original Waveform');
subplot(2, 2, 2); plot(detailComponents); title('Detail Component');
subplot(2, 2, 3); plot(approxComponents); title('Approximation Component');
subplot(2, 2, 4); plot(reconstructedSignal); title('Reconstructed Signal');
%%
clc;
clear variables;
close all;
% 使用wavedec和waverec进行DWT分解和重构
[signalDWT, signalRate] = audioread("voice.wav");
[coefficients, levels] = wavedec(signalDWT(:,1), 1, 'db4');
reconstructedDWT = waverec(coefficients, levels, 'db4');
% 绘图展示分解和重构结果
subplot(2, 2, 1); plot(signalDWT(:, 1)); title('Original Waveform');
subplot(2, 2, 2); plot(levels); title('Detail Component');
subplot(2, 2, 3); plot(coefficients); title('Approximation Component');
subplot(2, 2, 4); plot(reconstructedDWT); title('Reconstructed Signal');
%%
clc;
clear variables;
close all;
% 更深层次的DWT分解和重构
[deepDWTSignal, deepSampleRate] = audioread('voice.wav');
[deepCoefficients, deepLevels] = wavedec(deepDWTSignal(:,2), 3, 'db4');
% 提取各级分解的近似和细节成分
approx3 = appcoef(deepCoefficients, deepLevels, 'db4', 3);
detail3 = detcoef(deepCoefficients, deepLevels, 3);
detail2 = detcoef(deepCoefficients, deepLevels, 2);
detail1 = detcoef(deepCoefficients, deepLevels, 1);
reconstructedDeepDWT = waverec(deepCoefficients, deepLevels, 'db4');
% 绘图展示各级分解和重构结果
subplot(3, 2, 1); plot(deepDWTSignal(:, 2)); title('Original Channel 2 Signal');
subplot(3, 2, 2); plot(approx3); title('Level 3 Approximation Component');
subplot(3, 2, 3); plot(detail1); title('Level 1 Detail Component');
subplot(3, 2, 4); plot(detail2); title('Level 2 Detail Component');
subplot(3, 2, 5); plot(detail3); title('Level 3 Detail Component');
subplot(3, 2, 6); plot(reconstructedDeepDWT); title('Reconstructed Signal');
%%
clc;
clear variables;
close all;
% DCT分析
[signalDCT, rateDCT] = audioread('voice.wav');
dctSignal = dct(signalDCT(:, 1));
reconstructedDCT = idct(dctSignal);
% 绘制DCT分析
subplot(3, 1, 1); plot(signalDCT(:, 1)); title('Original Waveform');
subplot(3, 1, 2); plot(dctSignal); title('DCT Processed Signal');
subplot(3, 1, 3); plot(reconstructedDCT); title('Reconstructed Signal');