%% module 4 - 3
% Blur an image applying local averaging (select different block sizes and
% use both overlapping and not overlapping blocks). Apply to it non-local
% means. Observe if it helps to make the image better. Could you design a
% restoration algorithm, for blurry images, that uses the same concepts as
% non-local-means?
close all;
clear;
clc;

%% loading the image
Iorig = im2double(imread('lenna.tif'));

%% blurring the image
% blur the image
h_gaus = fspecial('gaussian', [10 10], 10);
Ibl = imfilter(Iorig, h_gaus, 'conv', 'symmetric');
% results
figure;
imshow(cat(2, Iorig, Ibl));

%% denoising the picture
Inew = NLMD(Ibl, 0, 1e3);
Inew = NLMD(Inew, 0, 1e3);

%% results
[Imat,~] = imnlmfilt(Ibl);
[Imatnon,~] = imnlmfilt(Iorig);

figure;
imshow(cat(2,Iorig,Ibl,Inew));
figure;
imshow(cat(2,Iorig,Ibl,Imat));
figure;
imshow(cat(2,Iorig,Imatnon));

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