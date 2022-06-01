clear all; close all; clc;

% =======================================================
% Input parameters (see README)
filename = ('D://Depth From Focus//2019.07.08_002//'); 
crop_x = 1600; % Crop along x in each side
crop_y = 2500; % Crop along y in each side
number_of_images = 52; 

distance = 25; % Distance between two images in a row
size_filter = 15; 
radius_z = 10;
mls_filter_size = 5;
% =======================================================

% Built the images stack for DfF algorithm 
stock_images = ones(number_of_images,3744-2*crop_x+1,5616-2*crop_y+1,1);
parfor i = 2:number_of_images-1
    if i <10
        I = imread([filename, 'img_00',num2str(i),'.jpg']);
    elseif i <100
        I = imread([filename, 'img_0',num2str(i),'.jpg']);
    else
       I = imread([filename, 'img_',num2str(i),'.jpg']);
    end
    I_gray = rgb2gray(I(crop_x:end - crop_x,crop_y:end - crop_y,:));
    stock_images(i,:,:,1) = I_gray;
end

% DfF using Windowed Linear Least Squares Regressions
[finalImage, fiab_imag] = depthFromFocus(stock_images, distance, size_filter, radius_z);

% Post-processing using MLS filter
modifiedFinalImage =  mls_filter(finalImage, fiab_imag, mls_filter_size);
modifiedFinalImage = modifiedFinalImage(21:end-20, 21:end-20);

% Show the depthmap obtained
image_2d(modifiedFinalImage)

% Export to stl the 3D model
data_to_stl(modifiedFinalImage, 'model.stl', 1)

