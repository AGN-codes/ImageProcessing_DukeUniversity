%% module 3 - 4 - Consider an image and add to it random noise.
% Repeat this N times, for different values of N, and add the resulting
% images. What do you observe?
close all;
clear;
clc;

%% loading the image and turning it into double
I = imread('peppers.png');
I = im2double(I);

%% noise parameters
var_noise = 1;
noise_scale = 1e3;

%% adding noise
J = imnoise(I,'gaussian', 0, var_noise/noise_scale);
K = J;
for i = 1:10
    K = imnoise(K,'gaussian', 0, var_noise/noise_scale);
end
L = K;
for i = 1:1000
    L = imnoise(L,'gaussian', 0, var_noise/noise_scale);
end

%% results
figure;
imshow([I,J;K,L]);

figure;
imhist(I);
figure;
imhist(J);
figure;
imhist(K);
figure;
imhist(L);