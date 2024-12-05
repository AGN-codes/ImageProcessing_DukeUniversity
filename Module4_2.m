%% module 4 - 2
% Practice with Wiener filtering. Consider for example a Gaussian blurring
% (so you know exactly the H function) and play with different values of K
% for different types and levels of noise.
close all;
clear;
clc;

%% loading the image
Iorig = im2double(imread('lenna.tif'));

%% blurring the image and adding noise
% gaussian noise parameters
var_noise = 10 / 1e3;
% percentage of salt and pepper noise
snp = 0 / 100;
% blur the image
h_gaus = fspecial('gaussian', [10 10], 10);
h_gaus = fspecial('motion', 20, 0);
Ibl = imfilter(Iorig, h_gaus, 'conv', 'symmetric');
% adding gaussian noise
Ignbl = imnoise(Ibl,'gaussian', 0, var_noise);
Isnpgnbl = imnoise(Ignbl, 'salt & pepper',snp);
% results
figure;
imshow(cat(2, Iorig, Isnpgnbl));

%% denoising the image
% implementation from 'https://github.com/Sammed98/Wiener-Filter-Matlab'
wiener_K = 0.2;
% wiener_K = wiener_K_train(100, Iorig, var_noise); % bad results
% wiener_K = wiener_K_func(100, Iorig, var_noise, h_gaus); % horrific results
h_gaus_fft = fft2(h_gaus, size(Iorig, 1), size(Iorig, 2));
Isnpgnbl_fft = fft2(Isnpgnbl);
wiener_fft = conj(h_gaus_fft) ./ ((abs(h_gaus_fft).^2) + wiener_K);
Irest = abs(ifft2(Isnpgnbl_fft .* wiener_fft));
% matlab
wiener2_mn = [3 3];
Imat = wiener2(Isnpgnbl, wiener2_mn, var_noise);
% results
figure;
imshow(cat(2, Iorig, Isnpgnbl, Irest, Imat));

%% wiener_K training
function K_final = wiener_K_train(no_train, Iorig, var_noise)
    K_matrices = zeros(size(Iorig, 1), size(Iorig, 2), no_train);
    for i = 1:no_train
        n = imnoise(Iorig, 'gaussian', 0, var_noise) - Iorig;
        N = fft2(n);
        F = fft2(Iorig);
        K_matrices(:, :, i) = (abs(N).^2) ./ (abs(F).^2);
    end
    K_final = zeros(size(Iorig, 1), size(Iorig, 2));
    for i = 1:no_train
        K_final = K_final + K_matrices(:, :, i);
    end
    K_final = K_final / no_train;
end

function wiener_K = wiener_K_func(no_train, Iorig, var_noise, h_gaus)
    h_gaus_fft = fft2(h_gaus, size(Iorig, 1), size(Iorig, 2));
    wiener_K_sum = zeros(size(Iorig, 1), size(Iorig, 2));
    for i = 1:no_train
        Iorig_fft = fft2(imnoise(Iorig, 'gaussian', 0, var_noise));
        Iblur = imfilter(Iorig, h_gaus, 'conv', 'symmetric');
        Iblur = imnoise(Iblur, 'gaussian', 0, var_noise);
        Iblur_fft = fft2(Iblur);
        wiener_K = (conj(h_gaus_fft) .* Iblur_fft ./ Iorig_fft) - (abs(h_gaus_fft).^2);
        wiener_K_sum = wiener_K_sum + wiener_K;
    end
    wiener_K = wiener_K_sum / no_train;
end