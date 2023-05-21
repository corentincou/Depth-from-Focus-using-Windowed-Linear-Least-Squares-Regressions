function data_to_stl(Image, name, scale)
% Create a .stl file from the depth map.
% Input :
%   - Image : the depth map (2D image)
%   - scale : rescale factor for resizing 
%   - name : name of the file

%J = imresize(Image,[scale(1) scale(2)]);
J = Image;
x = 1:size(J, 1);
y = 1:size(J,2);

[X, Y] = meshgrid(x,y);

write_stl(name,X.'.*scale(1),Y.'.*scale(2),J.*scale(3))
end

