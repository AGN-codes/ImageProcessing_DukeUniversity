%% module 3 - 1 - Implementing a histogram equalization function
close all;
clear;
clc;

%% loading the image
I = imread('pout.tif');

%% histogram equalization implementation
I_vec =  reshape(I, 1, []);
I_count = zeros(1, 256);
for i = 0:255
    I_count(i+1) = sum(I_vec == i);
end
I_prob = I_count / sum(I_count);

T = zeros(1, 256);
T(1) = I_prob(1);
for i = 2:256
    T(i) = T(i-1) + I_prob(i);
end
T = 255 * T;
T = round(T);

I_eq = zeros(1, length(I_vec));
for i = 1:length(I_vec)
    I_eq(i) = T(I_vec(i));
end
I_eq = reshape(I_eq, size(I, 1), size(I, 2));
I_eq = I_eq / 255;

%% results
figure('Name', 'orig - my implementation');
imshowpair(I,I_eq,'montage');
%title('orig - my implementation');

%% results exploration (vs matlab implementation) 
[matI, matT] = histeq(I);
matI = im2double(matI);

figure('Name', 'my implementation - MATLAB histeq');
imshowpair(I_eq,matI,'montage');
%title('my implementation - MATLAB histeq');

% figure('Name', 'MATLAB histeq - difference between my histeq and MATLAB');
% imshowpair(matI,matI-I_eq+0.5,'montage');
% %title('MATLAB histeq - difference between my histeq and MATLAB');
% 
% figure;
% imhist(matI);
% title('MATLAB histeq histogram');
% 
% figure;
% imhist(I_eq);
% title('my implementations histogram');