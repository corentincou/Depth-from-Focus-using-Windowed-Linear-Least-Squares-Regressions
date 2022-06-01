function FM = fmeasure(Image, Measure)
%This function measures the relative degree of focus of 
%an image. It may be invoked as:
%
%   FM = fmeasure(IMAGE, METHOD, ROI)
%
%Where 
%   IMAGE,  is a grayscale image and FM is the computed
%           focus value.
%   METHOD, is the focus measure algorithm as a string.
%           see 'operators.txt' for a list of focus 
%           measure methods. 
%   ROI,    Image ROI as a rectangle [xo yo width heigth].
%           if an empty argument is passed, the whole
%           image is processed.
%
%  Said Pertuz
%  Jan/2016

FM = [];

switch upper(Measure)
    
    case 'SAKU' % Composite measure from Sakurikar paper
        Ix = Image*0;
        Iy = Image*0;
        Ixy = Image*0;
        Iyx = Image*0;
        Iy(2:end-1,2:end-1) = (Image(1:end-2,2:end-1)-Image(2:end-1,2:end-1)).^2 +...
            (Image(3:end,2:end-1)-Image(2:end-1,2:end-1)).^2;
        Ix(2:end-1,2:end-1) = (Image(2:end-1,1:end-2)-Image(2:end-1,2:end-1)).^2 + ...
            (Image(2:end-1,3:end)-Image(2:end-1,2:end-1)).^2;
        Ixy(2:end-1,2:end-1) = (Image(1:end-2,1:end-2)-Image(2:end-1,2:end-1)).^2 + ...
            (Image(3:end,3:end)-Image(2:end-1,2:end-1)).^2;
        Iyx(2:end-1,2:end-1) = (Image(3:end,1:end-2)-Image(2:end-1,2:end-1)).^2 + ...
            (Image(1:end-2,3:end)-Image(2:end-1,2:end-1)).^2;
        MIS8 = Ix + Iy + Ixy + Iyx;
        
        Ix = Image;
        Iy = Image;
        Iy(1:end-1,:) = diff(Image, 1, 1);
        Ix(:,1:end-1) = diff(Image, 1, 2);
        LAP1 = Ix.^2 + Iy.^2;
        
        M = [-1 2 -1];        
        Lx = imfilter(Image, M, 'replicate', 'conv');
        Ly = imfilter(Image, M', 'replicate', 'conv');
        LAP2 = abs(Lx) + abs(Ly);
        
        HFN = maxhessiannorm(Image);
        
        STA3 = std2(Image);
        
        FM = 0.156*MIS8 + 0.131*LAP1 + 0.127*LAP2 + 0.108*HFN + 0.101*STA3;
    
    case 'GRAE' % Energy of gradient (Subbarao92a) /!\ Top !!
        Ix = Image;
        Iy = Image;
        Iy(1:end-1,:) = diff(Image, 1, 1);
        Ix(:,1:end-1) = diff(Image, 1, 2);
        FM = Ix.^2 + Iy.^2;
        %FM = medfilt2(FM, [size_filter size_filter]);
        
   case 'TOGE' % Total gradient energy
        Ix = Image*0;
        Iy = Image*0;
        Iy(2:end-1,:) = (Image(1:end-2,:)-Image(2:end-1,:)).^2 + (Image(3:end,:)-Image(2:end-1,:)).^2;
        Ix(:,2:end-1) = (Image(:,1:end-2)-Image(:,2:end-1)).^2 + (Image(:,3:end)-Image(:,2:end-1)).^2;
        FM = Ix + Iy;
        
    case 'GRAT' % Thresholded gradient (Snatos97)
        Th = 0; %Threshold
        Ix = Image;
        Iy = Image;
        Iy(1:end-1,:) = diff(Image, 1, 1);
        Ix(:,1:end-1) = diff(Image, 1, 2);
        FM = max(abs(Ix), abs(Iy));
        FM(FM<Th)=0;
           
    case 'LAPE' % Energy of laplacian (Subbarao92a)
        M = [-1 2 -1];        
        Lx = imfilter(Image, M, 'replicate', 'conv');
        Ly = imfilter(Image, M', 'replicate', 'conv');
        FM = abs(Lx).^2 + abs(Ly).^2;
        %h = fspecial('gaussian', 25, size_filter/2)
        %FM = imfilter(FM, h);
        %FM = medfilt2(FM, [size_filter size_filter]);
                
    case 'LAPM' % Modified Laplacian (Nayar89)
        M = [-1 2 -1];        
        Lx = imfilter(Image, M, 'replicate', 'conv');
        Ly = imfilter(Image, M', 'replicate', 'conv');
        FM = abs(Lx) + abs(Ly);
        
    case 'RDFE' % Ring difference filter
        RDF = [0 1 1 1 0
               1 0 0 0 1
               1 0 -12 0 1
               1 0 0 0 1
               0 1 1 1 0];
        FM = imfilter(Image, RDF, 'replicate', 'conv');
        FM = FM.^2;
        %FM = medfilt2(FM, [size_filter size_filter]);
        
    case 'RSFF' % Ring spatial frenquencies filter
        I1 = Image*0;
        I2 = Image*0;
        I3 = Image*0;
        I4 = Image*0;
        I5 = Image*0;
        t = @(x) abs(x); p = 2;
        %t = @(x) x.^2; p = 1;
        I1(3:end-2,3:end-2) = ...
            t(Image(2:end-3,1:end-4)-Image(3:end-2,3:end-2)) +...
            t(Image(3:end-2,1:end-4)-Image(3:end-2,3:end-2)) + ...
            t(Image(4:end-1,1:end-4)-Image(3:end-2,3:end-2));
        I2(3:end-2,3:end-2) = ...
            t(Image(1:end-4,2:end-3)-Image(3:end-2,3:end-2)) +...
            t(Image(5:end,2:end-3)-Image(3:end-2,3:end-2));
        I3(3:end-2,3:end-2) = ...
            t(Image(1:end-4,3:end-2)-Image(3:end-2,3:end-2)) +...
            t(Image(5:end,3:end-2)-Image(3:end-2,3:end-2));
        I4(3:end-2,3:end-2) = ...
            t(Image(1:end-4,4:end-1)-Image(3:end-2,3:end-2)) +...
            t(Image(5:end,4:end-1)-Image(3:end-2,3:end-2));
        I5(3:end-2,3:end-2) = ...
            t(Image(2:end-3,5:end)-Image(3:end-2,3:end-2)) +...
            t(Image(3:end-2,5:end)-Image(3:end-2,3:end-2)) +...
            t(Image(4:end-1,5:end)-Image(3:end-2,3:end-2));
        FM = (I1 + I2 + I3 + I4 + I5).^p;
    
    case 'RGRA' % Ring gradient
        %t = @(x) abs(x); p = 2;
        t = @(x) x.^2; p = 1;
        FM = Image*0;
        FM(2:end-1,2:end-1) = ...
            t(Image(1:end-2,1:end-2)-Image(3:end-0,3:end-0)) +...
            t(Image(2:end-1,1:end-2)-Image(2:end-1,3:end-0)) + ...
            t(Image(3:end-0,1:end-2)-Image(1:end-2,3:end-0)) + ...
            t(Image(1:end-2,2:end-1)-Image(3:end-0,2:end-1));
        FM = FM.^p;
        
    case 'ERDF' % Ring difference filter
        RDF = [0 0 0 1 1 1 1 1 0 0 0
                0 0 1 1 1 1 1 1 1 0 0
                0 1 1 0 0 0 0 0 1 1 0
                1 1 0 0 0 0 0 0 0 1 1
                1 1 0 0 0 0 0 0 0 1 1
                1 1 0 0 0 -52 0 0 0 1 1
                1 1 0 0 0 0 0 0 0 1 1
                1 1 0 0 0 0 0 0 0 1 1
                0 1 1 0 0 0 0 0 1 1 0
                0 0 1 1 1 1 1 1 1 0 0
                0 0 0 1 1 1 1 1 0 0 0];
        %FM = imfilter(Image, RDF, 'replicate', 'conv');
        FM = FM.^2;

    case 'SFRQ' % Spatial frequency (Eskicioglu95)
        Ix = Image*0;
        Iy = Image*0;
        Ixy = Image*0;
        Iyx = Image*0;
        Iy(2:end-1,2:end-1) = (Image(1:end-2,2:end-1)-Image(2:end-1,2:end-1)).^2 +...
            (Image(3:end,2:end-1)-Image(2:end-1,2:end-1)).^2;
        Ix(2:end-1,2:end-1) = (Image(2:end-1,1:end-2)-Image(2:end-1,2:end-1)).^2 + ...
            (Image(2:end-1,3:end)-Image(2:end-1,2:end-1)).^2;
        Ixy(2:end-1,2:end-1) = (Image(1:end-2,1:end-2)-Image(2:end-1,2:end-1)).^2 + ...
            (Image(3:end,3:end)-Image(2:end-1,2:end-1)).^2;
        Iyx(2:end-1,2:end-1) = (Image(3:end,1:end-2)-Image(2:end-1,2:end-1)).^2 + ...
            (Image(1:end-2,3:end)-Image(2:end-1,2:end-1)).^2;
        FM = Ix + Iy + Ixy + Iyx;
        %FM = medfilt2(FM, [size_filter size_filter]);
        
    case 'TENG'% Tenengrad (Krotkov86)
        Sx = fspecial('sobel');
        Gx = imfilter(double(Image), Sx, 'replicate', 'conv');
        Gy = imfilter(double(Image), Sx', 'replicate', 'conv');
        FM = Gx.^2 + Gy.^2;
        %FM = medfilt2(FM, [size_filter size_filter]);
        
    case 'WAVS' %Sum of Wavelet coeffs (Yang2003)
        [C,S] = wavedec2(Image, 1, 'db6');
        H = wrcoef2('h', C, S, 'db6', 1);   
        V = wrcoef2('v', C, S, 'db6', 1);   
        D = wrcoef2('d', C, S, 'db6', 1);   
        FM = H.^2 + V.^2 + D.^2;
        
    case 'WAVR'
        [C,S] = wavedec2(Image, 3, 'db6');
        H = abs(wrcoef2('h', C, S, 'db6', 1));   
        V = abs(wrcoef2('v', C, S, 'db6', 1));   
        D = abs(wrcoef2('d', C, S, 'db6', 1)); 
        A1 = abs(wrcoef2('a', C, S, 'db6', 1));
        A2 = abs(wrcoef2('a', C, S, 'db6', 2));
        A3 = abs(wrcoef2('a', C, S, 'db6', 3));
        A = A1 + A2 + A3;
        WH = H.^2 + V.^2 + D.^2;
        WH = WH;
        WL = mean2(A);
        FM = WH/WL;
        
    case 'STDE'
        size_filter = 5;
        FM = stdfilt(Image, true(2*size_filter + 1)).^2;
        size_filter = 0;
        
    case 'HOLD'     % NUL
        Ix = Image;
        Iy = Image;
        Iy(2:end-1,:) = (log(abs(Image(1:end-2,:)-Image(2:end-1,:)))/log(2)).^2;
        Ix(:,2:end-1) = (log(abs(Image(:,1:end-2)-Image(:,2:end-1)))/log(2)).^2;
        FM = Ix + Iy;
   
    case 'CWTE'
        [C,S] = wavedec2(Image, 1, 'fk22');
        H = wrcoef2('h', C, S, 'fk22', 1);   
        V = wrcoef2('v', C, S, 'fk22', 1);   
        D = wrcoef2('d', C, S, 'fk22', 1);   
        FM = H.^2 + V.^2 + D.^2;
        
    case 'DOGE'
        I = Image;
        I_blur = imgaussfilt(I,3);
        FM = (I - I_blur).^2;
        %h = fspecial('average',size_filter);
        %FM = imfilter(FM, h);
    
    case 'COCE'
        size_filter = 5;
        a = size_filter;
        b = size_filter + 8;
        I = Image;
        Ia = imgaussfilt(I, a);
        Ib = imgaussfilt(I, b);
        rMax = abs((I - Ia)./(Ia - Ib));
        FM = (a*b)./((b - a).*rMax + b);
        FM = 1 ./ FM;
        %h = fspecial('average',size_filter);
        %FM = imfilter(FM, h);
        
    otherwise
        error('Unknown measure %s',upper(Measure))
end

end
%************************************************************************
function fm = AcMomentum(Image)
[M, N] = size(Image);
Hist = imhist(Image)/(M*N);
Hist = abs((0:255)-mean2(Image))'.*Hist;
fm = sum(Hist);
end
%******************************************************************
function fm = DctRatio(M)
MT = dct2(M).^2;
fm = (sum(MT(:))-MT(1,1))/MT(1,1);
end
%************************************************************************
function fm = ReRatio(M)
M = dct2(M);
fm = (M(1,2)^2+M(1,3)^2+M(2,1)^2+M(2,2)^2+M(3,1)^2)/(M(1,1)^2);
end
%******************************************************************
