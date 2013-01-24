function varargout = pat_spatial_LPF(mode, K, data2D)
% Gaussian spatial LPF - based on NIRS_SPM function spm_filter_HPF_LPF_WMDL
% SYNTAX:
% varargout = ioi_spatial_LPF(mode, K, data2D)
% INPUTS:
% mode      'set' - Prepares the filter kernel
%           'lpf' - Performs the actual filtering of data2D
% K         Structure with the following fields
%           K.k1 = Number of pixels along x
%           K.k2 = Number of pixels along y
%           K.radius = radius of the gaussian distribution, the kernel will have
%           a size of 2*radius + 1 pixels
% data2D    2-D image to be low-pass filtered
% OUTPUTS:
%           Updated K structure if mode is 'set' or
%           Filtered 2-D image if mode is 'lpf'
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

switch mode
    case 'set'        
        %FWHM = 2*K.radius;
        sigma   = K.radius/2;
        try
            % First we try to use the Image Processing toolbox function fspecial
            % to create a rotationally symmetric gaussian kernel
            K.filterKernel = fspecial('gaussian',2*[K.radius K.radius]+1, sigma);
        catch
            % If no toolbox is present, then we prepare the filter as usual
            sigma   = K.radius/2;
            h       = round(4*sigma);
            h       = exp(-(-h:h).^2/(2*sigma^2));
            n       = length(h);
            d       = (1:n) - (n + 1)/2;
            if      n == 1, h = 1; end
            
            k = K.k1;
            L = spdiags(ones(k,1)*h, d, k,k);
            K.K1 = spdiags(1./sum(L')',0,k,k)*L;
            k = K.k2;
            L = spdiags(ones(k,1)*h, d, k,k);
            K.K2 = spdiags(1./sum(L')',0,k,k)*L;
            K.Ks1 = K.K1*K.K1';
            K.Ks2 = K.K2*K.K2';
        end
        varargout{1} = K;
    case 'lpf'
        try
            % First we try to use the Image Processing toolbox function
            % imfilter, it runs 3 times faster (3ms vs. 9 ms, for a 248x270
            % pixels image)
            varargout{1} = imfilter(data2D, K.filterKernel, 'replicate');
        catch
            % If no toolbox is present, then we filter the image as usual
            varargout{1} =  K.Ks1 * data2D * K.Ks2';
        end
    otherwise
        % Do nothing...
end
end

% EOF
