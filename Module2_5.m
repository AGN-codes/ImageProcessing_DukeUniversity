%% Module 2 - 1 - grayscale jpeg, no transform, just quantization
close all;
clear;
clc;

%% loading the image
Iorig = imread("lenna.tif");

% for scaling down the data
% Iorig = Iorig(1:16, 1:16);

%% image data to workable type
I = im2double(Iorig);
I = I * (2^8);

%% sectioning the image into nxn blocks
N_B = 8; % number of blocks
I_nrow = size(I, 1);
I_ncol = size(I, 2);

I_rowNB = floor(I_nrow/N_B);
I_8row = N_B * ones(1, I_rowNB);
if I_nrow - I_rowNB * N_B ~= 0
    I_8row = [I_8row, I_nrow - I_rowNB * N_B];
end

I_colNB = floor(I_ncol/N_B);
I_8col = N_B * ones(1, I_colNB);
if I_ncol - I_colNB * N_B ~= 0
    I_8col = [I_8col, I_ncol - I_colNB * N_B];
end

I_B = mat2cell(I, I_8row, I_8col);

if I_nrow - I_rowNB * N_B ~= 0
    I_B = I_B(1:end-1, :);
end
if I_ncol - I_colNB * N_B ~= 0
    I_B = I_B(:, 1:end-1);
end

%% quantizing each block with matrices
% books normalization matrix which is 8x8
norm_matrix_book = [16,11,10,16,24,40,51,61; ...
    12,12,14,19,26,58,60,55; ...
    14,13,16,24,40,57,69,56; ...
    14,17,22,29,51,87,80,62; ...
    18,22,37,56,68,109,103,77; ...
    24,35,55,64,81,104,113,92; ...
    49,64,78,87,103,121,120,101; ...
    72,92,95,98,112,100,103,99]; % mean = 57.6250

q_lvl_thr = 10; % quantization threshold level

q_mat = q_lvl_thr * ones(N_B, N_B);
%q_mat = norm_matrix_book;

I_B_rs = reshape(I_B, 1, []);
I_B_qnt = cell(1, length(I_B_rs));
b = 1;
for B = I_B_rs
    B = cell2mat(B);
    B = round(B./q_mat).*q_mat;
    I_B_qnt{1, b} = B;

    b = b + 1;
end

I_B_qnt = reshape(I_B_qnt, size(I_B, 1), size(I_B, 2));

%% image data to workable type and deblocking
I_re = cell2mat(I_B_qnt);
I_re = I_re / (2^8);

%% results
figure;
imshowpair(Iorig, I_re, 'montage');
figure;
imhist(Iorig);
figure;
imhist(I_re);
figure;
imshow(imresize(norm_matrix_book/(2^8), 100, 'method', "nearest"));

%% entropy
Iorig_hist = Iorig;
[Norig, ~] = histcounts(Iorig_hist, 2^8);
Porig = Norig / sum(Norig);
Porig = Porig(Porig > 0);
Ent_orig = - sum(Porig .* log2(Porig))

I_re_hist = im2uint8(I_re);
[N_re, ~] = histcounts(I_re_hist, 2^8);
P_re = N_re / sum(N_re);
P_re = P_re(P_re > 0);
Ent_re = - sum(P_re .* log2(P_re))