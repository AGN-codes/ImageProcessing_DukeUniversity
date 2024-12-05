%% module 3 - 5 - Implementing the basic color edge detector
close all;
clear;
clc;

%% loading the image
I = imread('WomanLyingonBed.jpg');
%I = imread('peppers.png');
I = imread('goya.jpeg');

%% implemetation 1
% basic edge detector based on rgb vector lenght
% I = ones(500, 500, 3) / 2; % all channels are equal
J = im2double(I);
K = sqrt((J(:,:,1).^2)+(J(:,:,2).^2)+(J(:,:,3).^2))/sqrt(3);

h = fspecial('laplacian', 0.5);
L = imfilter(K, h);

M = L - min(L, [], "all");
M = M / max(M, [], "all");

N = histeq(M);

% SL = L < mean(L, "all");
% L(SL)=0;
% SM = M < mean(M, "all");
% M(SM)=0;

figure;
imshowpair(I, L, 'montage');
figure;
imshowpair(M, N, 'montage');

P = N;
P(N < 0.9) = 0;

figure;
imshowpair(I, P, 'montage');

diff2 = sum(abs(M(:,:,1)-L(:,:)), "all");
diff2_rel = diff2 / (size(I,1)*size(I,2));

% difference between rgb vector length and luminance of YCbCr
maxK = max(K, [], "all");

P = rgb2ycbcr(J);
diff = sum(abs(P(:,:,1)-K(:,:)), "all");
diff_rel = diff / (size(I,1)*size(I,2));

%% implementation 2
% difference is done in the rgb space, then this difference is converted to
% black and white / luma/y of ycbcr
J = im2double(I);

h = fspecial('laplacian', 0.5);
L = imfilter(J, h);
L = L - min(L, [], "all");
L = L / max(L, [], "all");

M = rgb2ycbcr(L);
M = M(:,:,1);

N = histeq(M);

% SL = L > mean(L, "all");
% L(SL)=0;
% SM = M < mean(M, "all");
% M(SM)=0;

figure;
imshowpair(I,L,'montage');
figure;
imshowpair(I, N, 'montage');

P = N;
P(N < 0.9) = 0;

figure;
imshowpair(I, P, 'montage');

%% implementation 3
% difference done on luma of ycbcr
J = im2double(I);
K = rgb2ycbcr(J);
L = K(:,:,1);

h = fspecial('laplacian', 0.5);
M = imfilter(L, h);
M = M - min(M, [], "all");
M = M / max(M, [], "all");

N = histeq(M);

figure;
imshowpair(I, L, 'montage');
figure;
imshowpair(M, N, 'montage');

P = N;
P(N < 0.9) = 0;

figure;
imshowpair(I, P, 'montage');

%% implementation 3 + downsize
% difference done on luma of ycbcr
% with a touch of downsize
J = im2double(I);
K = rgb2ycbcr(J);
L = K(:,:,1);

fun = @(block_struct) avg_fun(block_struct.data);
L = blockproc(L, [2 2], fun); % downsize ratio

h = fspecial('laplacian', 0.5);
M = imfilter(L, h);
M = M - min(M, [], "all");
M = M / max(M, [], "all");

N = histeq(M);

figure;
imshowpair(I, L, 'montage');
figure;
imshowpair(M, N, 'montage');

P = N;
P(N < 0.9) = 0;

figure;
imshowpair(I, P, 'montage');

%% implementation 4
% difference of each rgb channel is normalized
% and then turned into luma component
J = im2double(I);

h = fspecial('laplacian', 0.5);
L = imfilter(J, h);

L = L - min(L, [], [1 2]);
L = L ./ max(L, [], [1 2]);

M = rgb2ycbcr(L);
M = M(:,:,1);

N = histeq(M);

P = N;
P(N < 0.9) = 0;

figure;
imshowpair(I,L,'montage');
figure;
imshowpair(M, N, 'montage');
figure;
imshowpair(I, P, 'montage');

%% func dec
function avg = avg_fun(x)
    avg = sum(x(:))/numel(x); 
end
