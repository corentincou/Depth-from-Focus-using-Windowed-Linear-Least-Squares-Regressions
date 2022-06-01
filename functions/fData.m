function stock_flou = fData(stock_images, size_filter)
%Determine the blur measure for all the pixels of all images
% Input :
%   - stock_images : a big 3D matrix i.x.y containing all the images in grayscale.
%     i is the number of images, x and y the size
%   - estimator : the blur estimator used: choice between, GRAE, GRAT,
%     LAPE, LAPM, SFRQ, (TENG, WAVS, WAVR).
% Caractérisation du code
caract_images = size(stock_images);
number_of_images = caract_images(1);
size_images = [caract_images(2) caract_images(3)];

% Création de stock de données de flou
stock_flou = ones(number_of_images,size_images(1),size_images(2),1);

%  Calcul du flou
parfor i = 1:number_of_images
    Image = squeeze(stock_images(i,:,:));
    stock_flou(i,:,:,1) = fmeasure(Image, 'RDFE'); 
end

% % Normalisation des images
% parfor j = 1:size_images_y
%     for i = 1:size_images_x
%         norme = sum(stock_flou(:,i,j,1));
%         maximum = max(max(stock_flou(:,i,j,1)));
%         stock_flou(:,i,j,1) = maximum*stock_flou(:,i,j,1)/norme.^2;
%     end
% end

% Filtre spatial
if size_filter > 0
    h = fspecial('gaussian',2*size_filter+1,size_filter/4);
    parfor i = 1:number_of_images
        stock_flou(i,:,:,1) = imfilter(squeeze(stock_flou(i,:,:,1)), h); 
    end
end

end

