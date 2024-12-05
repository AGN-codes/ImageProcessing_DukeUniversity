%% module 3 - 7 - single frame video denoising - grayscale
% run each section manually (or not; autorun is implemented)
close all;
clear;
clc;

%% noise parameters
var_noise = 16;
noise_scale = 1e3;

%% color video to gray rawFrames
vid = VideoReader('xylophone.mp4');
vid.CurrentTime = 0;
rawFrames = zeros(vid.NumFrames, vid.Height, vid.Width);
t = 1;
while vid.hasFrame()
    thisFrame = rgb2gray(im2double(vid.readFrame()));
    thisFrame = thisFrame - min(thisFrame, [], 'all'); % you can comment this line
    rawFrames(t,:,:) = thisFrame;
    t  = t + 1;
end

%% play rawFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(rawFrames(t,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% adding noise to single frames of rawFrames
noiseFrames = zeros(vid.NumFrames, vid.Height, vid.Width);
for t = 1:vid.NumFrames
    noiseFrames(t,:,:) = ...
    imnoise(squeeze(rawFrames(t,:,:)),'gaussian', 0, var_noise/noise_scale);
end

%% play noiseFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(noiseFrames(t,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% play rawFrames & noiseFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    thisFrame = cat(2, squeeze(rawFrames(t,:,:)), ...
        squeeze(noiseFrames(t,:,:)));
    imshow(thisFrame, 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% non-local means on seperate frames of noiseFrames
singleFrames = zeros(vid.NumFrames, vid.Height, vid.Width);
for t = 1:vid.NumFrames
    thisFrame = squeeze(noiseFrames(t,:,:));
    thisFrame = NLMD(thisFrame, var_noise, noise_scale);
    thisFrame = NLMD(thisFrame, 1, noise_scale);
    singleFrames(t,:,:) = thisFrame;
end

%% play singleFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(singleFrames(t,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% play rawFrames & noiseFrames & singleFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    thisFrame = cat(2, squeeze(rawFrames(t,:,:)), ...
        squeeze(noiseFrames(t,:,:)), squeeze(singleFrames(t,:,:)));
    imshow(thisFrame, 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

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