%% module 4 - 1
close all;
clear;
clc;

%% loading the image
Iorig = imread('lenna.tif');
Iorig = im2double(Iorig);

%%
% Add Gaussian and salt-and-pepper noise with different parameters to an
% image of your choice. Evaluate what levels of noise you consider still
% acceptable for visual inspection of the image.

snp = 9/100; % percentage of salt and pepper noise
% gaussian noise parameters
var_noise = 10;
noise_scale = 1e3;
% adding noise to the images
Ign = imnoise(Iorig,'gaussian', 0, var_noise/noise_scale);
Isnp = imnoise(Ign, 'salt & pepper',snp);
% results
figure;
imshow(cat(2,Iorig,Isnp));
% the levels of acceptable noise depends on the image

%% 
% Apply a median filter to the images you obtained above. Change the window
% size of the filter and evaluate its relationship with the noise levels.

med_size = [5 5]; % median filter size
Imed = medfilt2(Isnp,med_size);
figure;
imshow(cat(2,Iorig,Isnp,Imed));