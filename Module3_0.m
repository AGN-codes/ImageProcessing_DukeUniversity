%% module 3 demos
close all;
clear;
clc;

%% Enhancement & Histogram modification
I = imread('tire.tif');
figure(1);
imshow(I);
figure(2);
imhist(I);
figure(3);
imshow(255-I);
figure(4);
imhist(255-I);

%% Enhancement & Histogram modification
I = imread('tire.tif');
figure(1);
imshow(I);
figure(2);
imhist(I);
figure(3);
histeq(I);
figure(4);
imhist(histeq(I));

%% masking with averaging
I = imread('Hubble_particale.tif');
h = fspecial('average', 15); % 1000 for fun
Ifil = imfilter(I, h); % , 'symmetric' for fun
figure;
imshowpair(I, Ifil, 'montage');
figure;
imhist(Ifil);
threshold = 0.25 * max(max(Ifil))
Ilogic = Ifil > threshold;
Imask = I;
Imask(~Ilogic) = 0; % mean(mean(Imask(Ilogic))); doesn't work good
figure;
imshowpair(Ilogic, Imask, 'montage');

%% Non-Local Means Denoising using imnlmfilt
I = imread('cameraman.tif');
figure;
imshow(I);
noisyImage = imnoise(I,'gaussian',0,0.0015);
[filteredImage,estDoS] = imnlmfilt(noisyImage);
figure;
montage({noisyImage,filteredImage});
title(['Estimated Degree of Smoothing, ', 'estDoS = ',num2str(estDoS)]);

%% median filter
I = imread('eight.tif');
J = imnoise(I,'salt & pepper', 0.09);
K = medfilt2(J, 'symmetric'); % 'zeros' is the default padding
figure;
imshowpair(I,J,'montage');
figure;
imshowpair(I,K,'montage');

%% median filter
I = imread('eight.tif');
J = imnoise(I,'salt & pepper', 0.09);
K = medfilt2(J);
figure;
imshow(I);
figure;
imshow(J);
figure;
imshow(K);
figure;
imshow(I-K);
figure;
imshow((I-K).^2);

%% Unsharp masking
I = imread('moon.tif');
J = imsharpen(I);
K = 0.5+I-J;
figure;
imshowpair(I,J,'montage');
figure;
imshowpair(K,K.^2,'montage');

%%
I = imread('moon.tif');
Isc = I;
Isym = I;
Irep = I;
h = fspecial('average', 3);
for i = 1:10000
    Isc = imfilter(Isc, h, 0);
    Isym = imfilter(Isym, h, 'symmetric');
    Irep = imfilter(Irep, h, 'replicate');
end

figure;
imshowpair(I,Isc,'montage');
figure;
imshowpair(Isym,Irep,'montage');