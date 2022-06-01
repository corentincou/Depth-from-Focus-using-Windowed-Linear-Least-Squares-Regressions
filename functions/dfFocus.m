function [prof_focus,fiab_imag,slopex,slopey] = dfFocus(stock_flou, radius_z)
% Return the depthmap, and a map of fiability
% Input :
%   - stock_flou : a big 3D matrix i.x.y containing all the values of blur 
%     per pixel in each images.
%   - methode is the method chosen to calculate the depth of each pixel
%   - fiability : if you prefer base your fiability on classical
%   "fiability" or on "residu"

% Caracterisation du code
caract_images = size(stock_flou);
number_of_images = caract_images(1);
size_images = [caract_images(2) caract_images(3)];
size_images_x = size_images(1);
size_images_y = size_images(2);

% Determination de la profondeur optimale
prof_focus = ones(size_images(1),size_images(2));
accu_focus = ones(size_images(1),size_images(2));
slopex = zeros(size_images(1),size_images(2));
slopey = zeros(size_images(1),size_images(2));

Z = linspace(1, number_of_images, number_of_images).';

parfor j = 1:size_images_y
    for i = 1:size_images_x
        maximum = 0;
        accu = 0;
        residu = 0;
        C = stock_flou(:,i,j);

        radius_zl = radius_z;

        [maximum, accu, ypred, residu] = method_triangle(C, 1, 1, radius_zl, 1, "residu");
        prof_focus(i,j) = maximum;
        
        accu_focus(i,j) = accu;

    end
end
fiab_imag = accu_focus;
end
