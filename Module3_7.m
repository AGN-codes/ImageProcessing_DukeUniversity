%% module 3 - 3 - Implementing non-local means 2 x denoising (symmetric padding)
% grayscale -  pixelwise implementation - function
close all;
clear;
clc;

%% loading the image and turning it into double
I = imread('lenna.tif');
%I = rgb2ycbcr(I); I = I(:,:,1); % uncomment for color pictures
I = im2double(I);

%% adding gaussian noise to the picture
% variance of the noise, between 0 and 100
var_noise = 16;
noise_scale = 1e3;
Ign = I;
Ign = imnoise(I,'gaussian', 0, var_noise/noise_scale);

%% denoising the picture
Inew = NLMD(Ign, var_noise, noise_scale);
Inew = NLMD(Inew, 1, noise_scale);

%% results
[Imat,~] = imnlmfilt(Ign);

figure;
imshowpair(I, Imat, 'montage');
figure;
imshow(cat(2,I,Inew,Ign));

%% denoising function
function Inew = NLMD(Ign, var_noise, noise_scale)
    % % patch (f) and research (r) size according to noise variance (sigma)
    if var_noise >= 0 && var_noise <= 15
        res_block = 21;
        comp_patch = 3;
        h_weight = 0.4 * var_noise;
    elseif var_noise > 15 && var_noise <= 30
        res_block = 21;
        comp_patch = 5;
        h_weight = 0.4 * var_noise;
    elseif var_noise > 30 && var_noise <= 45
        res_block = 35;
        comp_patch = 7;
        h_weight = 0.35 * var_noise;
    elseif var_noise > 45 && var_noise <= 75
        res_block = 35;
        comp_patch = 9;
        h_weight = 0.35 * var_noise;
    elseif var_noise > 75 && var_noise <= 100
        res_block = 35;
        comp_patch = 11;
        h_weight = 0.30 * var_noise;
    end
    
    var_noise = var_noise / noise_scale;
    h_weight = h_weight / noise_scale;
    
    % % padding the image
    pad_size = (res_block + comp_patch - 2) / 2;
    % filtered Isp will be stored here
    Inew = zeros(size(Ign,1), size(Ign,2));
    % padded image
    Ipad = Ign;
    % padding the up and down parts
    for r = 1:pad_size
        Ipad = cat(1, Ign(r,:), Ipad, Ign(end-r+1,:));
    end
    % padding the left and righ parts
    for c = 1:pad_size
        Ipad = cat(2, Ipad(:,2*c-1), Ipad, Ipad(:,end-2*c));
    end
    
    % % implementing the non-local means denoising
    % for-loop for each pixel of the image in the padded matrix (Ipad)
    for row = (1:size(Ign,1)) + pad_size
     for col = (1:size(Ign,2)) + pad_size
         % weight matrix for each pixel of research block
         weight_mat = zeros(res_block);
    
         % research for-loop for each pixel of the image in the padded matrix
         for rrow = -((res_block-1)/2):((res_block-1)/2)
             for rcol = -((res_block-1)/2):((res_block-1)/2)
                 % square of distance sum for each pixel of the comp patch
                 d2_comp = 0;
    
                 % research for-loop for each pixel of the comp patch / f
                 for frow = -((comp_patch-1)/2):((comp_patch-1)/2)
                    for fcol = -((comp_patch-1)/2):((comp_patch-1)/2)
                        % distance sum calculation
                        d2_comp = d2_comp + ((Ipad(row+frow, col+fcol) - ...
                            Ipad(row+rrow+frow, col+rcol+fcol))^2);
                    end
                 end
                 d2_comp = d2_comp / (comp_patch ^ 2);
                 weight_mat(rrow+((res_block-1)/2)+1, ...
                     rcol+((res_block-1)/2)+1) = ...
                     exp(-max(d2_comp-(2*(var_noise)))/(h_weight));
                 % i changed var_noise^2 & h_weight^2 to var_noise and h_weight
             end
         end
    
        weight_mat(((res_block-1)/2)+1, ((res_block-1)/2)+1) = 0;
        weight_mat(((res_block-1)/2)+1, ((res_block-1)/2)+1) = ...
            max(weight_mat, [], 'all');
    
        weight_total = sum(weight_mat, 'all');
    
        pixel_new = sum(Ipad(row-((res_block-1)/2):row+((res_block-1)/2), ...
            col-((res_block-1)/2):col+((res_block-1)/2)).* weight_mat, 'all');
    
        pixel_new = pixel_new / weight_total;
    
        Inew(row-pad_size, col-pad_size) = pixel_new;
     end
    end
end