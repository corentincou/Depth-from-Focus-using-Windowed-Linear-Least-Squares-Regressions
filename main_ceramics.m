clear all; close all; clc;

% =======================================================
% Input parameters (see README)
filename = (['D://data//example_ceramics_bdx6502//']); 
ROI = [2215, 1206 ; 4084, 2973]; % RoI studied for depth computation 
number_of_images = 39;
type_img = "jpg"; % Choose between 'tiff' and 'jpg'

distance = 30; % Distance between two images in a row
% =======================================================

% Show the all in focus image if it exists
if exist(([filename, 'restack.jpg']), 'file')
    I = imread([filename, 'restack.jpg']);
    I_gray = rgb2gray(I(ROI(1, 2):ROI(2, 2), ROI(1, 1):ROI(2, 1),:));
    image_2d(I_gray)
    colormap gray 
end


% Built the images stack for DfF algorithm 
stock_images = ones(number_of_images,ROI(2, 2)-ROI(1, 2)+1, ROI(2, 1)-ROI(1, 1)+1,1);
if type_img == "tiff"
parfor i = 1:number_of_images
    if i <10
        t = Tiff([filename, 'aligned_000',num2str(i),'.tif']);
        I = read(t);
    elseif i <100
        t = Tiff([filename, 'aligned_00',num2str(i),'.tif']);
        I = read(t);
    else
        t = Tiff([filename, 'aligned_0',num2str(i),'.tif']);
        I = read(t);
    end
    I(:,:,4) = [];
    I_gray = rgb2gray(I(crop_x:end - crop_x,crop_y:end - crop_y,:));
    stock_images(i+1,:,:,1) = I_gray;
end
else
parfor i = 1:number_of_images
    if i <10
        I = imread([filename, 'img_00',num2str(i),'.jpg']);
    elseif i <100
        I = imread([filename, 'img_0',num2str(i),'.jpg']);
    else
       I = imread([filename, 'img_',num2str(i),'.jpg']);
    end
    I_gray = rgb2gray(I(ROI(1, 2):ROI(2, 2), ROI(1, 1):ROI(2, 1),:));
    stock_images(i,:,:,1) = I_gray;
end
end


% Rough DfF for volume correction (make plaar the ceramics)
[finalImage, ~] = depthFromFocus(stock_images, distance, 200, 6);
modified_finalImage =  imgaussfilt(finalImage,15);

% Fitting for volume correction
caract_images = size(stock_images);
size_images = [caract_images(2) caract_images(3)];
x = linspace(1,size_images(1),size_images(1));
y = linspace(1,size_images(2),size_images(2));
[Y, X] = meshgrid(y,x);
x = reshape(X, [], 1);
y = reshape(Y, [], 1);
z = reshape(modified_finalImage , [], 1);
sf = fit([x, y],z,'poly22');
modified_finalImage = modified_finalImage -(sf.p10*X + sf.p01*Y + sf.p20*X.^2 + sf.p02*Y.^2 + sf.p11*X.*Y);
% Untilting
[a, b] = untilting_params(stock_images, modified_finalImage);


% Recalcul plus fin pour avoir résultat untilt
% Precise DfF to get the depthmap 
[finalImage, fiab_imag] = depthFromFocus(stock_images, distance, 13, 6);
finalImage = finalImage -(a(2)*X + b(2)*Y);
finalImage = finalImage -(sf.p10*X + sf.p01*Y + sf.p20*X.^2 + sf.p02*Y.^2 + sf.p11*X.*Y);

% Show the depthmap obtained
image_2d(finalImage)

% Export the depthmap for python analysis
mat2np(finalImage, [filename,'depthmap_python.pkl'], 'float64')
