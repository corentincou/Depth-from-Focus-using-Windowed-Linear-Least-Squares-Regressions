function image_2d(Image)
% Returns the 2D colormap of depth of the image 
figure
imagesc(Image)
colormap copper
colorbar
axis equal;

imwrite(rescale(Image), 'depthmap_matlab.jpg')
end

