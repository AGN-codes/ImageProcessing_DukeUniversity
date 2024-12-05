%% Module 2 - 1 - grayscale jpeg with m biggest dct coefficients
% second most important
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
I = I - (2^7);

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

%% performing DCT2 on Blocks
% for validating the shape
% temp = cell2mat(I_B(1,2));
% temp_dct = dct2(temp);

I_B_rs = reshape(I_B, 1, []);
I_B_rs_dct = cell(1, length(I_B_rs));
b = 1;
for B = I_B_rs
    B = cell2mat(B);
    B_dct = dct2(B);
    I_B_rs_dct{1, b} = B_dct;

    b = b + 1;
end

I_B_dct = reshape(I_B_rs_dct, size(I_B, 1), size(I_B, 2));

%% quantizing each block according to m biggest dct coefficients
N_LC = 8; % m largest coefficients

block_DCT_largest_coef = zeros(N_B);

I_B_dct = reshape(I_B_rs_dct, 1, []);
I_B_rs_dct_qnt = cell(1, length(I_B_dct));
b = 1;
for B = I_B_dct
    B = cell2mat(B);
    B = reshape(B, 1, []);
    % B(1) = 0; % no bias!
    [BSort, BIdx] = maxk(B, N_LC,'ComparisonMethod','abs');
    BSel = zeros(1,length(B));
    BSel(BIdx) = 1;
    B = BSel .* B;
    B = reshape(B, N_B, N_B);
    I_B_rs_dct_qnt{1, b} = B;

    block_DCT_largest_coef = block_DCT_largest_coef + (B ~= 0);

    b = b + 1;
end

I_B_dct = reshape(I_B_rs_dct, size(I_B, 1), size(I_B, 2));
I_B_rs_dct_qnt = reshape(I_B_rs_dct_qnt, size(I_B, 1), size(I_B, 2));

%% performing iDCT2 on Blocks
I_B_rs_dct_qnt = reshape(I_B_rs_dct_qnt, 1, []);
I_B_rs_dct_qnt_idct = cell(1, length(I_B_rs_dct_qnt));

b = 1;
for B = I_B_rs_dct_qnt
    B = cell2mat(B);
    B = idct2(B);
    I_B_rs_dct_qnt_idct{1, b} = B;

    b = b + 1;
end

I_B_rs_dct_qnt = reshape(I_B_rs_dct_qnt, size(I_B, 1), size(I_B, 2));
I_B_rs_dct_qnt_idct = reshape(I_B_rs_dct_qnt_idct, size(I_B, 1), size(I_B, 2));

%% image data to workable type and deblocking
I_re = cell2mat(I_B_rs_dct_qnt_idct);

I_re = I_re + (2^7);
I_re = I_re / (2^8);

%% results
figure;
imshowpair(Iorig, I_re, 'montage');
figure;
imhist(Iorig);
figure;
imhist(I_re);
figure;
heatmap(block_DCT_largest_coef);

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