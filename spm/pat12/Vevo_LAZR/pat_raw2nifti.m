function pat_raw2nifti(fileName)
% Converts RAW PA-Mode files from data export on the Vevo 2100 to NIfTI files in
% order to be able to use SPM later, possibly for realignment/unwarping.
% SYNTAX
% pat_raw2nifti(fileName)
% INPUT
% fileName      Full file name to open (with extension .pamode)
% OUTPUT
% None
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% read RAW PA-mode images, Dimensions: [nDepth nWidth 1 nFrames]
[rawDataSO2, rawDataHbT, param] = pat_VsiOpenRawPa_multi(fileName);
% Number of frames
nFrames = size(rawDataHbT,4);
% Creating nifti file names
[pathstr, name, ~] = fileparts(fileName);
fnameSO2 = fullfile(pathstr,[name,'.SO2.nii']);
fnameHbT = fullfile(pathstr,[name,'.HbT.nii']);
% Single frame dimensions: [nDepth nWidth 1]
dim = [param.PaNumSamples param.PaNumLines 1];
% Data type
dt = [spm_type('float64') spm_platform('bigend')];
% Plane info
pinfo = ones(3,1);
% Affine transformation matrix: Scaling
matScaling = eye(4);
matScaling(1,1) = param.pixWidth;
matScaling(2,2) = param.pixDepth;
% Affine transformation matrix: Rotation
matRotation = eye(4);
matRotation(1,1) = 0;
matRotation(1,2) = 1;
matRotation(2,1) = -1;
matRotation(2,2) = 0;
% Affine transformation matrix: Translation
matTranslation = eye(4);
matTranslation(2,4) = -param.PaDepthOffset;
% Final Affine transformation matrix: 
mat = matScaling * matRotation * matTranslation;

fprintf('Creating NIfTI volume from %s...\n',fileName);
% Creates NIfTI volume frame by frame
for iFrames = 1:nFrames
    hdrSO2 = pat_create_vol(fnameSO2, dim, dt, pinfo, mat, iFrames,...
        squeeze(rawDataSO2(:,:,1,iFrames)));
    hdrHbT = pat_create_vol(fnameHbT, dim, dt, pinfo, mat, iFrames,...
        squeeze(rawDataHbT(:,:,1,iFrames)));
end
fprintf('%d frames saved to NIfTI volume!\n',nFrames);

% EOF
