function [finalImage, fiab_imag, stock_flou] = depthFromFocus(stock_images, dist, size_filter, radius_z)
% Return the depthmap, the confdence map, and the FM stack.
% Input :
%   - stock_images : a big 3D matrix i.x.y containing all the images in grayscale.
%     i is the number of images, x and y the size
%   - method : the method used to determine the depth for each pixel:
%     choice between Max, Mean, SimpleScalar, ContiScalar,
%     Likelyhood, TLS, Symm, Depth, and MeanMLS
%   - estimator : the blur estimator used: choice between GRAE, GRAT,
%     LAPE, LAPM, SFRQ, (TENG, WAVS, WAVR), RDFE, EGRA, ELAP.
%   - dist : the distance between each image taken
%   - size_filter : the size of the mean filter applied on the focus
%   measure
%   - image "Yes" if you want to show the depthmap



% Creation de stock de donnees de flou et determination de la profondeur optimale
tmp_size_filter = size_filter;
stock_flou = fData(stock_images, tmp_size_filter);

% Calcul de la profondeur
tic
[prof_focus,fiab_imag,slopex,slopey] = dfFocus(stock_flou, radius_z);    
toc


% Bias correction 
p = [-2.09194093, 3.13285466, -0.04985284, 0];
floor_map = floor(prof_focus);
titled_image_debiased = polyval(p,prof_focus - floor_map) + floor_map;


titled_image = -dist*titled_image_debiased;

% Treshold made by blurring
blurred_image = imgaussfilt(titled_image, 5);

finalImage = titled_image;
finalImage(finalImage > max(max(blurred_image))) = max(max(blurred_image));
finalImage(finalImage < min(min(blurred_image))) = min(min(blurred_image));

end

