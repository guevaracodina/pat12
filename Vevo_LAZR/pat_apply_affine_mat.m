function hdr = pat_apply_affine_mat(sourceFile, targetFile, varargin)
% Gets the affine matrix of source file and applies it to target file.
% SYNTAX
% pat_apply_affine_mat(sourceFile, targetFile, copyFile)
% INPUTS
% sourceFile    Reference image. Can be 2D or 4D if target file is also 4-D.
% targetFile    Target image (image to be transformed). Must have same size as the
%               sourceFile.
% [copyFile]    If provided, applies the transformation to a copy of target
%               file, else overwrites target file
% OUTPUTn
% hdr       - Header with image volume information.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% Optional inputs handling
% ------------------------------------------------------------------------------
% only want true optional input at most
numvarargs              = length(varargin);
if numvarargs > 1
    error('pat12:pat_apply_affine_mat:TooManyInputs', ...
        'Requires at most 1 optional inputs');
end
% set defaults for optional inputs
optargs                 = {targetFile};
% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs)   = varargin;
% Place optional args in memorable variable names
[copyTarget]            = optargs{:};
% ------------------------------------------------------------------------------

% Read images
volSource= spm_vol(sourceFile);
imSource = spm_read_vols(volSource);
volTarget= spm_vol(targetFile);
imTarget = spm_read_vols(volTarget);

if size(imSource,1) ~= size(imTarget,1) || size(imSource,2) ~= size(imTarget,2),
    error('pat12:pat_apply_affine_mat:sizeMismatch', 'Images need to be the same size')
end

if numel(size(imTarget)) == 2 && numel(size(imSource)) == 2
    % Apply 2-D processing
    nFrames = 1;
    fprintf('Source size: [%d %d], Target Size: [%d %d]\n',size(imSource), size(imTarget));
elseif numel(size(imTarget)) == 4 && numel(size(imSource)) == 4
    if size(imSource, 4) == size(imTarget, 4)
        % Apply 4-D processing
        nFrames = size(imTarget, 4);
        fprintf('Source size: [%d %d %d %d], Target Size: [%d %d %d %d]\n',size(imSource), size(imTarget));
    else
        error('pat12:pat_apply_affine_mat:framesMismatch', 'Both images are 4-D, but different time frames')
    end
elseif numel(size(imTarget)) == 4 && numel(size(imSource)) == 2
    % Apply 4-D processing
    nFrames = size(imTarget, 4);
    fprintf('Source size: [%d %d], Target Size: [%d %d %d %d]\n',size(imSource), size(imTarget));
elseif numel(size(imTarget)) == 2 && numel(size(imSource)) == 4
    % Apply 2-D processing (take info from the source first frame)
    nFrames = 1;
    fprintf('Source size: [%d %d %d %d], Target Size: [%d %d]\n',size(imSource), size(imTarget));
else
    error('pat12:pat_apply_affine_mat:dimsError', 'Dimensions mismatch')
end

if volSource(1).dt(1) ~= volTarget(1).dt(1)
    % PA-mode data type
    % targetDt = [spm_type('uint16') spm_platform('bigend')];
    % Modify data type (B-mode is uint8, while PA is uint16)
    fprintf('Target data type (%s) is different from source data type (%s).\n', spm_type(volTarget(1).dt(1)), spm_type(volSource(1).dt(1)))
    for iFrames = 1:size(imTarget,4)
        volSource(iFrames).dt = volTarget(iFrames).dt;
    end
end
for iFrames = 1:size(imTarget,4)
    volSource(iFrames).fname = copyTarget;
end
% Save new image
hdr = pat_create_vol_4D(copyTarget, volSource, imTarget);
   
% EOF
