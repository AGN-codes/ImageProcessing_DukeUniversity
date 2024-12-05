%% module 4 demos
close all;
clear;
clc;

%% types of noise - demo
RGB = imread('saturn.png');
I = rgb2gray(RGB);
I2G = imnoise(I,"gaussian", 0.02);
I2 = imnoise(I,"salt & pepper", 0.02);
I20 = imnoise(I,"salt & pepper", 0.2);

figure;
imshowpair(RGB, I, "montage");
figure;
imshow(cat(2,I2G,I2,I20));

%% wiener and box filters demo
RGB = imread('saturn.png');
I = rgb2gray(RGB);
J = imnoise(I,"gaussian", 0.005);
K = wiener2(J, [10 10]);
H = fspecial('disk', 10);
blurred = imfilter(J, H, 'replicate');

figure;
imshow(cat(2,I,J,blurred, K));
