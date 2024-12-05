%% Module 1
close all;
clear;
clc;

%% reducing the number of intensity levels
I1 = imread('cameraman.tif');
I1 = im2double(I1);

num_bits = 1;
% I1_256 = I1 * ((2^8) - 1);
value_levels = (2^num_bits) - 1;
I2 = round(I1 * value_levels)/value_levels;
figure;
imshowpair(I1, I2, 'montage');

%% reducing the number of intensity levels
I1 = imread('cameraman.tif');
I1 = im2double(I1);

value_lvl_num = 10;
I2 = floor(I1*value_lvl_num)/value_lvl_num;
figure;
imshowpair(I1, I2, 'montage');

%% perform a simple spatial nxn average of image pixels
% n = [3 10 20];
I1 = imread('woman.tif');

h3 = fspecial('average', 3);
h10 = fspecial('average', 10);
h20 = fspecial('average', 20);

I3 = imfilter(I1, h3, 'symmetric');
I10 = imfilter(I1, h10, 'replicate');
I20 = imfilter(I1, h20, 'circular');

figure;
imshowpair(I1, I3, 'montage');
figure;
imshowpair(I1, I10, 'montage');
figure;
imshowpair(I1, I20, 'montage');

%% Rotate the image by 45 and 90 degrees
I1 = imread('woman.tif');

I2 = imrotate(I1, 45);
I3 = imrotate(I1, 90);

figure;
imshowpair(I1, I2, 'montage');
figure;
imshowpair(I1, I3, 'montage');

%% reducing the image spatial resolution
% n = [3 5 7];
I1 = imread('pears.png');
I1 = im2gray(I1); % rgb2gray

fun = @(block_struct) avg_fun(block_struct.data);

I3 = blockproc(I1, [3 3], fun);
figure;
imshowpair(I1, I3, 'montage');

I5 = blockproc(I1, [5 5], fun);
figure;
imshowpair(I1, I5, 'montage');

I7 = blockproc(I1, [7 7], fun);
figure;
imshowpair(I1, I7, 'montage');

function avg = avg_fun(x)
    avg = sum(x(:))/numel(x); 
end