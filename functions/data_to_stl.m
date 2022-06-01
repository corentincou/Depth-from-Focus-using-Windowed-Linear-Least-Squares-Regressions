function data_to_stl(Image, name, scale)
% Create a .stl file from the depth map.
% Input :
%   - Image : the depth map (2D image)
%   - scale : rescale factor for resizing 
%   - name : name of the file
J = imresize(Image,scale);
x = 1:size(J, 1);
y = 1:size(J,2);

[X, Y] = meshgrid(x,y);

write_stl(name,X.'/scale,Y.'/scale,J)
end

