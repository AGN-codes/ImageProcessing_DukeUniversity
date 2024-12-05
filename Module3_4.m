%% module 3 - 2 - Implementing an mxn median filter (symmetric padding)
close all;
clear;
clc;

%% loading the image
I = imread('lenna.tif');

%% adding salt and pepper noise to the image
Isp = imnoise(I,'salt & pepper', 0.09);

%% median filter implementation
% enter the filter size here
filt_m = 3; % should be odd / row
filt_n = 3; % should be odd / column
% filtered Isp will be stored here
Imed = zeros(size(Isp,1), size(Isp,2), 'uint8');
% padded image
Ipad = Isp;
% padding the up and down parts
for r = 1:filt_m
    Ipad = cat(1, Isp(r,:), Ipad, Isp(end-r+1,:));
end
% padding the left and righ parts
for c = 1:filt_n
    Ipad = cat(2, Ipad(:,2*c-1), Ipad, Ipad(:,end-2*c));
end
% getting the median from filter sized squares
for r = (1:size(Isp,1))+filt_m
    for c = (1:size(Isp,2))+filt_n
        maskfxf = Ipad(r-((filt_m-1)/2):r+((filt_m-1)/2), c-((filt_n-1)/2):c+((filt_n-1)/2));
        maskfxf = reshape(maskfxf, 1, []);
        maskfxf = sort(maskfxf);
        Imed(r-filt_m,c-filt_n) = maskfxf((filt_m*filt_n+1)/2);
    end
end

%% results
figure("Name", 'orig - noise');
imshowpair(I, Isp, 'montage');

Imed_matlab = medfilt2(Isp, [filt_m filt_n],'symmetric');
figure("Name", 'my median filter vs matlabs');
imshowpair(Imed, Imed_matlab, 'montage');