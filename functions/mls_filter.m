function new_image = mls_filter(finalImage, fiab_imag, size_filter)
% Return the filtred image using the MLS filter
% Input :
%   - finalImage : depthmap we want to filter. 
%   - fiab_imag : Map of confidence 
%   - size_filter : size of the filter (size of the surface we'll fit with
%   the real surface

% Caracterisation du filtrage
size_x = size(finalImage, 1);
size_y = size(finalImage, 2);

tic
new_image = finalImage*0;

% Poids, finalement fixé à 1
% w = zeros(2*size_filter+1, 2*size_filter+1);
% for k = 1:2*size_filter+1
%     for l = 1:2*size_filter+1
%         w(k,l) = sqrt((k-size_filter-1).^2 + (l-size_filter-1).^2);
%     end
% end
% w = reshape(w, [], 1);
%Weight = exp(-w.^2./(2*size_filter+1));
w = zeros(2*size_filter+1, 2*size_filter+1);
w = reshape(w, [], 1);
Weight = w*0 + 1;

% Regression linéaire de surface
x = -size_filter:size_filter;
[Y, X] = meshgrid(x,x);
X = reshape(X, [], 1);
Y = reshape(Y, [], 1);

D = zeros((2*size_filter+1).^2,6);
D(:,1) = 1;
D(:,2) = X;
D(:,3) = Y;
D(:,4) = D(:,2).^2;
D(:,5) = D(:,3).^2;
D(:,6) = D(:,2).*D(:,3);

limit = prctile(reshape(fiab_imag, [], 1), 90);

for i = size_filter+1:size_x-size_filter
    for j = size_filter+1:size_y-size_filter
        y = finalImage(i-size_filter:i+size_filter, j-size_filter:j+size_filter);
        y =reshape(y, [], 1);
        W = Weight.*reshape(fiab_imag(i-size_filter:i+size_filter, j-size_filter:j+size_filter), [], 1);
        params = (D'*diag(W)*D)\D'*diag(W)*y;
        [a, MSGID] = lastwarn();
        warning('off', MSGID);
        new_image(i,j) = params(1);
    end
end
toc
end

