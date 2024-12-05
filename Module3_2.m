%% module 3 - 2 - Implementing a 3x3 median filter (symmetric padding)
close all;
clear;
clc;

%% loading the image
I = imread('lenna.tif');

%% adding salt and pepper noise to the image
Isp = imnoise(I,'salt & pepper', 0.1);

%% median filter implementation
Imed = zeros(size(Isp,1), size(Isp,2), 'uint8'); % filtered Isp will be stored here
Ipad = cat(1, Isp([3 2 1], :), Isp, Isp([end,end-1,end-2], :));
Ipad = cat(2, Ipad(:, [3 2 1]), Ipad, Ipad(:, [end,end-1,end-2]));

for r = (1:size(Isp,1))+3
    for c = (1:size(Isp,2))+3
        mask3x3 = Ipad(r-1:r+1, c-1:c+1);
        mask3x3 = reshape(mask3x3, 1, []);
        mask3x3 = sort(mask3x3);
        Imed(r-3,c-3) = mask3x3(1,5);
    end
end

%% results
figure("Name", 'orig - noise');
imshowpair(I, Isp, 'montage');

Imed_matlab = medfilt2(Isp, 'symmetric');
figure("Name", 'my median filter vs matlabs');
imshowpair(Imed, Imed_matlab, 'montage');
