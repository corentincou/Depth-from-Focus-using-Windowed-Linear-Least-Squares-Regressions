function [s] = image_3d(Image, Ratio)
% Returns the 2D colormap of depth of the image 
figure
s = mesh(Image(5:end-5,5:end-5).')
colormap copper
daspect(Ratio);

axis equal
end

