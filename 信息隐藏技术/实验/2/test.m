%%
% 初始化：清除内存，关闭所有图形窗口，并清空命令窗口
clc;
clear variables; % 使用clear variables代替clear all以清除工作空间变量
close all;
% 读取音频文件
[signal, ~] = audioread('voice.wav'); 
% 绘制时域信号
figure; % 绘图指令，确保图形在新窗口中打开
plot(signal);
title('Time Domain Signal'); 

