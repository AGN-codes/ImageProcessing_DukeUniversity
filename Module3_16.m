%% module 3 - 7 - multiple frame video denoising - color
% denoising implemented as a function
close all;
clear;
clc;

%% noise parameters
var_noise = 10;
noise_scale = 1e3;

%% color video to rawFrames
vid = VideoReader('xylophone.mp4');
vid.CurrentTime = 0;
rawFrames = zeros(vid.NumFrames, vid.Height, vid.Width, 3);
t = 1;
while vid.hasFrame()
    rawFrames(t,:,:,:) = im2double(vid.readFrame());
    t  = t + 1;
end

%% play rawFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(rawFrames(t,:,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% adding noise to single frames of rawFrames
noiseFrames = zeros(vid.NumFrames, vid.Height, vid.Width, 3);
for t = 1:vid.NumFrames
    noiseFrames(t,:,:,:) = ...
        imnoise(squeeze(rawFrames(t,:,:,:)),'gaussian', 0, var_noise/noise_scale);
end

%% play noiseFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(noiseFrames(t,:,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% play rawFrames & noiseFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    thisFrame = cat(2, squeeze(rawFrames(t,:,:,:)), ...
        squeeze(noiseFrames(t,:,:,:)));
    imshow(thisFrame, 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% video denosing parameters (for shortening the video)
% number of frames to denoise
noOfFrames = vid.NumFrames;
noOfFrames = 30;
% the temporal dimention size for denoising 
tempAx = 3;
% selecting the number of frames  of the noiseFrames to denoise
Ign = noiseFrames(1:noOfFrames,:,:,:);

%% video denoising
Inew = VNLMD(Ign, var_noise, noise_scale, noOfFrames, tempAx);
Inew2 = VNLMD(Inew, 1, noise_scale, noOfFrames - tempAx, tempAx);

%% play Inew2 (denoised frames)
figure;
ax = axes;
for t = 1:size(Inew2, 1)
    imshow(squeeze(Inew2(t,:,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% play rawFrames & noiseFrames & Inew & Inew2
figure;
ax = axes;
for t = 1:size(Inew2, 1)
    thisFrame = cat(2, squeeze(rawFrames(t,:,:,:)), ...
        squeeze(noiseFrames(t,:,:,:)),  ...
        squeeze(Inew(t,:,:,:)), ...
        squeeze(Inew2(t,:,:,:)));
    imshow(thisFrame, 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% some snapsots
figure;
imshow(cat(2,squeeze(rawFrames(1,:,:)),squeeze(rawFrames(2,:,:)),squeeze(rawFrames(3,:,:)),squeeze(rawFrames(4,:,:))));
figure;
imshow(cat(2,squeeze(noiseFrames(1,:,:)),squeeze(noiseFrames(2,:,:)),squeeze(noiseFrames(3,:,:)),squeeze(noiseFrames(4,:,:))));
figure;
imshow(cat(2,squeeze(Inew(1,:,:)),squeeze(Inew(2,:,:)),squeeze(Inew(3,:,:)),squeeze(Inew(4,:,:))));
figure;
imshow(cat(2,squeeze(Inew2(1,:,:)),squeeze(Inew2(2,:,:)),squeeze(Inew2(3,:,:)),squeeze(Inew2(4,:,:))));

%% 
function Inew = VNLMD(Ign, var_noise, noise_scale, noOfFrames, tempAx)
% %% computing res_block, comp_patch, and h_weight values
% function Inew = NLMD(Ign, var_noise, noise_scale)
% patch (f) and research (r) size according to noise variance (sigma)
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

% %% padding the images
pad_size = (res_block + comp_patch - 2) / 2;
% filtered Isp will be stored here
Inew = zeros(size(Ign,1)-tempAx, size(Ign,2), size(Ign,3), 3);
% padded image
Ipad = Ign;
% padding the up and down parts
for r = 1:pad_size
    Ipad = cat(2, Ign(:,r,:,:), Ipad, Ign(:,end-r+1,:,:));
end
% padding the left and righ parts
for c = 1:pad_size
    Ipad = cat(3, Ipad(:,:,2*c-1,:), Ipad, Ipad(:,:,end-2*c,:));
end

% %% implementing the non-local means denoising
% for-loop for each pixel of the image in the padded matrix (Ipad)
for time = 1:(noOfFrames-tempAx)
    for row = (1:size(Ign,2)) + pad_size
        for col = (1:size(Ign,3)) + pad_size
            % weight matrix for each pixel of research block
            weight_mat = zeros(tempAx, res_block, res_block);

            % research for-loop for each frame
            for d3 = time:(time+tempAx-1)
                % square of distance sum for each pixel of the comp patch
                d2_comp = 0;

                % research for-loop for each pixel of the image in the padded matrix
                for rrow = -((res_block-1)/2):((res_block-1)/2)
                    for rcol = -((res_block-1)/2):((res_block-1)/2)

                        % research for-loop for each pixel of the comp patch / f
                        for frow = -((comp_patch-1)/2):((comp_patch-1)/2)
                            for fcol = -((comp_patch-1)/2):((comp_patch-1)/2)
                                % distance sum calculation
                                d2_comp = d2_comp + ((Ipad(time, row+frow, col+fcol, 1) - ...
                                    Ipad(d3, row+rrow+frow, col+rcol+fcol, 1))^2);
                                d2_comp = d2_comp + ((Ipad(time, row+frow, col+fcol, 2) - ...
                                    Ipad(d3, row+rrow+frow, col+rcol+fcol, 2))^2);
                                d2_comp = d2_comp + ((Ipad(time, row+frow, col+fcol, 3) - ...
                                    Ipad(d3, row+rrow+frow, col+rcol+fcol, 3))^2);
                            end
                        end
                        d2_comp = d2_comp / (3 * (comp_patch ^ 2));
                        weight_mat(d3-time+1, rrow+((res_block-1)/2)+1, ...
                            rcol+((res_block-1)/2)+1) = ...
                            exp(-max(d2_comp-(2*(var_noise)))/(h_weight));
                        % i changed var_noise^2 & h_weight^2 to var_noise and h_weight
                    end
                end
            end

            weight_mat(1, ((res_block-1)/2)+1, ((res_block-1)/2)+1) = 0;
            weight_mat(1, ((res_block-1)/2)+1, ((res_block-1)/2)+1) = ...
                max(weight_mat, [], 'all');

            weight_total = sum(weight_mat, 'all');

            pixel_new = sum(Ipad(time:(time+tempAx-1), row-((res_block-1)/2):row+((res_block-1)/2), ...
                col-((res_block-1)/2):col+((res_block-1)/2), 1) .* weight_mat, 'all');

            pixel_new = pixel_new / weight_total;

            Inew(time, row-pad_size, col-pad_size, 1) = pixel_new;

            pixel_new = sum(Ipad(time:(time+tempAx-1), row-((res_block-1)/2):row+((res_block-1)/2), ...
                col-((res_block-1)/2):col+((res_block-1)/2), 2) .* weight_mat, 'all');

            pixel_new = pixel_new / weight_total;

            Inew(time, row-pad_size, col-pad_size, 2) = pixel_new;

            pixel_new = sum(Ipad(time:(time+tempAx-1), row-((res_block-1)/2):row+((res_block-1)/2), ...
                col-((res_block-1)/2):col+((res_block-1)/2), 3) .* weight_mat, 'all');

            pixel_new = pixel_new / weight_total;

            Inew(time, row-pad_size, col-pad_size, 3) = pixel_new;
        end
    end
end
end