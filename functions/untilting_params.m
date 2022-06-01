function [a, b] = untilting_params(stock_images,Image)
% Remove the tilt of the measure due to a not perfect position of the
% object digitalised.
% Input :
%   - stock_images : a big 3D matrix i.x.y containing all the images in grayscale.
%     i is the number of images, x and y the size
%   - Image : a map of depth based on the blur measure

% Caractérisation du code
caract_images = size(stock_images);
size_images = [caract_images(2) caract_images(3)];


% Regression linéaire 3D pour supprimer le tilt
x = ones(size_images(1),3);
y = ones(size_images(2),3);

x(:,2) = linspace(1,size_images(1),size_images(1)).';
x(:,3) = linspace(1,size_images(1),size_images(1)).^2.';

y(:,2) = linspace(1,size_images(2),size_images(2)).';
y(:,2) = linspace(1,size_images(2),size_images(2)).^2.';

zx = ones(size_images(1),1);
zy = ones(size_images(2),1);
for i = 1:size_images(1)
    zx(i)= nanmean(Image(i,:));
end
for i = 1:size_images(2)
    zy(i)= nanmean(Image(:,i));
end
a = x\zx;
b = y\zy;
end

