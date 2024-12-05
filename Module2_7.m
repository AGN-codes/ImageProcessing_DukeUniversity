%% Module 2 - 3 - Compute the histogram of a given image and of its prediction errors
% fourth most important
close all;
clear;
clc;

%% load image
I = imread('woman.tif');
I = im2double(I);

%% type no. 1
% Compute the histogram of a given image and of its prediction errors
% If the pixel being processed is at coordinate (0,0), consider
% predicting based on just the pixel at (-1,0)
Idiff = I(:, 2:end) - I(:, 1:end-1);

var(reshape(Idiff, 1, []))

Idiff = [I(:, 1), Idiff];

figure;
imshow(Idiff+0.5);

figure;
histogram(Idiff);
xlim([-1, 1]);
title('(-1,0)');

%% type no. 2
% Compute the histogram of a given image and of its prediction errors
% If the pixel being processed is at coordinate (0,0), consider
% predicting based on just the pixel at (0,1)
Idiff = I(2:end, :) - I(1:end-1, :);

var(reshape(Idiff, 1, []))

Idiff = [I(1, :); Idiff];

figure;
imshow(Idiff+0.5);

figure;
histogram(Idiff);
xlim([-1, 1]);
title('(0,1)');

%% type no. 3
% Compute the histogram of a given image and of its prediction errors
% If the pixel being processed is at coordinate (0,0), consider
% predicting based on the average of the pixels at (-1,0), (-1,1), and (0,1)
Idiff = I(1:end-1,1:end-1) + I(1:end-1, 2:end) + I(2:end, 1:end-1);
Idiff = Idiff/3;
Idiff = I(2:end, 2:end) -  Idiff;

var(reshape(Idiff, 1, []))

Idiff = [I(1, 2:end); Idiff];
Idiff = [I(:, 1), Idiff];

figure;
imshow(Idiff+0.5);

figure;
histogram(Idiff);
xlim([-1, 1]);
title('(-1,0), (-1,1), and (0,1)');