function [s] = rendu_3d(Image, Ratio, Filename, AllFocus, crop_x, crop_y)
% Return a 3D image of the digitalisation with the image to reproduce
% reality
figure
rendu = Tiff([Filename, AllFocus]);
iRendu = read(rendu);

iRendu = iRendu(crop_x+5:end-crop_x-5,crop_y+5:end-crop_y-5,:);
[rows, cols, ~] = size(Image);
iRendu = imresize(iRendu, [rows, cols]);

if size(iRendu,3) == 4
    iRendu(:,:,4) = [];
    
end
s = warp(Image(26:end-25, 26:end-25), iRendu);
        daspect(Ratio);
axis equal
end

