function [depth, confidence, lapvalues, residu] = method_triangle(stock_flou, i, j, radius_z, supersampling, option)
% This method determines the depth for each pixel using a linear fitting,
% after passing the curve to the log. System of sliding windows.
% Input :
%   - stock_flou : a big 3D matrix i,x,y containing all the values of blur 
%     per pixel in each images.
%   - number_of_images is the size of the images slack
%   - i, j positions of the pixel in the image to look for
%   - if option == "Print" or option==  "residu", compute the lapvalues and residu

% Param�tres
best_params     = ones(1,3);
best_depth      = 0;
best_confidence = 0;
best_k = 0;
%radius_z = 8;
debug_plot = false;
A = zeros(3,3);

% Normalisation de la courbe de flou en z au log sur le pixel (i,j)
y0 = stock_flou(:,i,j);

%y0 = y0 + mean(y0);
norme = sum(y0);
y0 = 100/norme*stock_flou(:,i,j);

% take log
y = log(y0);
% and clamp too small values:
y = max(y,-4*max(y));
number_of_images = length(y);

% precompute inverse matrix for the regular case,
% i.e., for k_inf = 1, k_sup = 2*win_radius

% average blur magnitude to skip windows centered around low values
% (purpose = speedup)
avg_blur_value = log((mean(y0.^4)).^(1/4));
if debug_plot
    fig=figure();
    plot(((1:size(yinit))-1)*supersampling+1,yinit,'g.');hold on;
    plot(1:size(y),y0,'b');
end

% Apply sliding windows.
% Keep fit with higest maxima.
for k = 2:number_of_images-2
    if y(k)>avg_blur_value || y(k+1)>avg_blur_value
        k_inf = max(1,k+1-radius_z);
        k_sup = min(number_of_images,k+radius_z);
        len_a = k-k_inf+1;
        len_b = k_sup-k;
        % Version without a weight function:
%             A(1,1) = len_a;
%             A(2,2) = len_b;
%             K = [(k_inf:k)' ; -(k+1:k_sup)'];
%             A(3,1) = sum(K(1:len_a));     A(1,3) = A(3,1);
%             A(3,2) = sum(K(len_a+1:end)); A(2,3) = A(3,2);
%             A(3,3) = K'*K;
%             B = [sum(y(k_inf:k)) ; sum(y(k+1:k_sup)) ; K'*y(k_inf:k_sup)];
%             params = A\B;

        % With a weight function:
        D = zeros(len_a+len_b,3);
        D(1:len_a,1) = 1;
        D(len_a+1:end,2) = 1;
        D(:,3) = [(k_inf:k)' ; -(k+1:k_sup)'];
        params = (D'*D)\D'*y(k_inf:k_sup);

%         % Least Square
        current_depth = (params(2)-params(1))/(2*params(3));
        current_confidence = params(1)+params(3)*current_depth;
        if  best_confidence < current_confidence && current_depth >= k-1.5*supersampling && current_depth <= k+2.5*supersampling && params(3)>0
            best_depth = current_depth;
            best_confidence = current_confidence;
            best_params = params;
            best_k = k;
        end
    end
end

%best_params

% Compute confidence = maximal value after normalization
confidence = best_confidence;

depth = best_depth;

depth = (depth+supersampling-1)/supersampling;
best_params(1) = best_params(1)+ best_params(3)*(1-supersampling);
best_params(2) = best_params(2)- best_params(3)*(1-supersampling);
best_params(3) = best_params(3) * supersampling;


if option == "Print" || option == "residu"

    % extract actual Laplacian distribution
    xdata1 = 1:floor(depth);
    xdata2 = floor(depth)+1:size(stock_flou,1);
    ypred1 = exp(best_params(1)+best_params(3)*xdata1);
    ypred2 = exp(best_params(2)-best_params(3)*xdata2);
    lapvalues = horzcat(ypred1, ypred2)';

    % compute residual
    residu = 0;%mean(abs(y0 - lapvalues));
else
    lapvalues = 0;
    residu = 0;
end

end
