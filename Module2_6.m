%% Module 2 - 2 - color jpeg with methods from module2_1
% third most important
close all;
clear;
clc;

%% loading the image and parameters
Iorig = imread("goya.jpeg");

% N_B : number of blocks -> def write : N_B = 8
N_B = 8;
% q_type: 1 = book's matrix / else = ones matrix -> def write : q_type = 1
q_type = 2;
% q_lvl_thr : quantization threshold level -> q_lvl_thr = 60 / def write : mean = 57.6250
q_lvl_thr = 57.6250;

%% computation & result
I_ycbcr = Iorig; % line needed for ycbcr/rgb demonstration

I_ycbcr = rgb2ycbcr(Iorig); % ! -> comment for rgb demonstration
I_re(:,:,1) = JPEG1(I_ycbcr(:,:,1), N_B, q_type, q_lvl_thr);
I_re(:,:,2) = JPEG1(I_ycbcr(:,:,2), N_B, q_type, q_lvl_thr);
I_re(:,:,3) = JPEG1(I_ycbcr(:,:,3), N_B, q_type, q_lvl_thr);
I_re = ycbcr2rgb(I_re); % ! -> comment for rgb demonstration

figure;
imshowpair(Iorig, I_re, 'montage');

%% entropy
Ent_orig = 0;
Ent_re = 0;
for p = 1:3
    Iorig_hist = Iorig(:, :,  p);
    [Norig, ~] = histcounts(Iorig_hist, 2^8);
    Porig = Norig / sum(Norig);
    Porig = Porig(Porig > 0);
    Ent_orig = Ent_orig - sum(Porig .* log2(Porig));
    
    I_re_hist = im2uint8(I_re(:, :, p));
    [N_re, ~] = histcounts(I_re_hist, 2^8);
    P_re = N_re / sum(N_re);
    P_re = P_re(P_re > 0);
    Ent_re = Ent_re - sum(P_re .* log2(P_re));
end
Ent_orig
Ent_re

%% computation & result, v. 2
% keeping the compression ratio constant for the Y channel, increase the
% compression of the two chrominance channels and observe the results.

I_ycbcr2 = Iorig; % line needed for ycbcr/rgb demonstration

I_ycbcr2 = rgb2ycbcr(Iorig); % ! -> comment for rgb demonstration
N_B = 8;    q_type = 2; q_lvl_thr = 30;
I_re2(:,:,1) = JPEG1(I_ycbcr2(:,:,1), N_B, q_type, q_lvl_thr);
N_B = 8;    q_type = 2; q_lvl_thr = 90;
I_re2(:,:,2) = JPEG1(I_ycbcr2(:,:,2), N_B, q_type, q_lvl_thr);
N_B = 8;    q_type = 2; q_lvl_thr = 150;
I_re2(:,:,3) = JPEG1(I_ycbcr2(:,:,3), N_B, q_type, q_lvl_thr);
I_re2 = ycbcr2rgb(I_re2); % ! -> comment for rgb demonstration

figure;
imshowpair(Iorig, I_re2, 'montage');

%% function
function I_re = JPEG1(Iorig, N_B, q_type, q_lvl_thr)
    % image data to workable type
    I = im2double(Iorig);
    I = I * (2^8);
    I = I - (2^7);
    
    % sectioning the image into nxn blocks
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
    
    % performing DCT2 on Blocks
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
    
    % quantizing each block with matrices
    % books normalization matrix which is 8x8
    norm_matrix_book = [16,11,10,16,24,40,51,61; ...
        12,12,14,19,26,58,60,55; ...
        14,13,16,24,40,57,69,56; ...
        14,17,22,29,51,87,80,62; ...
        18,22,37,56,68,109,103,77; ...
        24,35,55,64,81,104,113,92; ...
        49,64,78,87,103,121,120,101; ...
        72,92,95,98,112,100,103,99];
    
    if(q_type == 1)
        q_mat = norm_matrix_book;
    else
        q_mat = q_lvl_thr * ones(N_B, N_B);
    end
    
    I_B_dct = reshape(I_B_rs_dct, 1, []);
    I_B_rs_dct_qnt = cell(1, length(I_B_dct));
    b = 1;
    for B = I_B_dct
        B = cell2mat(B);
        B = round(B./q_mat).*q_mat;
        I_B_rs_dct_qnt{1, b} = B;
    
        b = b + 1;
    end
    
    I_B_dct = reshape(I_B_rs_dct, size(I_B, 1), size(I_B, 2));
    I_B_rs_dct_qnt = reshape(I_B_rs_dct_qnt, size(I_B, 1), size(I_B, 2));
    
    % performing iDCT2 on Blocks
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
    
    % image data to workable type and deblocking
    I_re = cell2mat(I_B_rs_dct_qnt_idct);
    
    I_re = I_re + (2^7);
    I_re = I_re / (2^8);
end