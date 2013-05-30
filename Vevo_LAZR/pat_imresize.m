function imageOut = pat_imresize(imageIn, nx, ny)
% Alternative to imresize, works if Image Processing Toolbox is not installed.
% Resizes image imageIn to be nx-by-ny using bicubic interpolation.  Before
% performing the interpolation, imageIn is blurred with a Gaussian in each
% dimension to prevent aliasing.
% SYNTAX
% imageOut = pat_imresize(imageIn, nx, ny)
% imageOut = pat_imresize(imageIn, [nx ny])
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Handle the argument that describes the size of the result
if (length(nx) == 1)
    % Do nothing
elseif (length(nx) == 2)
    ny = nx(2);
    nx = nx(1);
else
    error('pat12:pat_imresize: second argument mest be a scalar or a 2-vector');
end
% Round dimensions
nx = round(nx);
ny = round(ny);

try
    imageOut = imresize(imageIn,[nx ny]);
catch 
    [height width] = size(imageIn);
    
    % determine the size of the Gaussian blur kernel
    sigma1 = 0.5 * height / nx;
    sigma2 = 0.5 * width / ny;
    k1 = ceil(3 * sigma1);
    k2 = ceil(3 * sigma2);
    
    % construct the (separable) kernel
    d1 = linspace(-k1,k1,2*k1+1).^2 / sigma1^2;
    d2 = linspace(-k2,k2,2*k2+1).^2 / sigma2^2;
    h1 = exp(-d1)';
    h2 = exp(-d2);
    h1 = h1 / sum(h1);
    h2 = h2 / sum(h2);
    
    % allocate space for the resized image
    imageOut = zeros(nx,ny);
    
    % pad the image by duplicating the boundary
    temp = [repmat(imageIn(1,1),k1,k2)   repmat(imageIn(1,:),k1,1)   repmat(imageIn(1,end),k1,k2);
        repmat(imageIn(:,1),1,k2)    imageIn(:,:)                repmat(imageIn(:,end),1,k2);
        repmat(imageIn(end,1),k1,k2) repmat(imageIn(end,:),k1,1) repmat(imageIn(end,end),k1,k2)];
    % Test if logical
    if islogical(temp)
        ISLOGIC = true;
        temp = double(temp);
    else
        ISLOGIC = false;
    end
    % blur this image with the kernel
    temp = conv2(temp,h1,'full');
    temp = conv2(temp,h2,'full');
    
    % perform the bilinear interpolation
    x = linspace(2*k2+0.5, width+2*k2+0.5, 2*ny+1);
    y = linspace(2*k1+0.5, height+2*k1+0.5, 2*nx+1);
    [x y] = meshgrid(x(2:2:end-1),y(2:2:end-1));
    imageOut = interp2(temp,x,y,'cubic');
    
    if ISLOGIC
        % Return logical matrix
        imageOut = logical(imageOut);
    end
end

% EOF

