%% module 3 - 6 - different types of equalization on videos
% run each section manually (or not; autorun is implemented)
close all;
clear;
clc;

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

%% histeq on single frames of rawFrames
histeqFrames = zeros(vid.NumFrames, vid.Height, vid.Width);
for t = 1:vid.NumFrames
    histeqFrames(t,:,:) = histeq(squeeze(rawFrames(t,:,:)));
end

%% play histeqFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(histeqFrames(t,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% play rawFrames & histeqFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    thisFrame = cat(2, squeeze(rawFrames(t,:,:)), ...
        squeeze(histeqFrames(t,:,:)));
    imshow(thisFrame, 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% histeq on all frames of rawFrames, all at once
thisFrame = reshape(rawFrames, vid.NumFrames * vid.Height, vid.Width);
thisFrame = histeq(thisFrame);
histallFrames = reshape(thisFrame, vid.NumFrames, vid.Height, vid.Width);

%% play histallFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    imshow(squeeze(histallFrames(t,:,:)), 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;

%% play rawFrames & histeqFrames & histallFrames
figure;
ax = axes;
for t = 1:vid.NumFrames
    thisFrame = cat(2, squeeze(rawFrames(t,:,:)), ...
        squeeze(histeqFrames(t,:,:)), squeeze(histallFrames(t,:,:)));
    imshow(thisFrame, 'Parent', ax);
    pause(1/vid.FrameRate);
end
close;