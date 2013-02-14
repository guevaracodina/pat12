function [nifti_filename affine_mat_filename param] = pat_raw2nifti_bmode(fileName, output_dir)
% Converts RAW PA-Mode files from data export on the Vevo 2100 to NIfTI files in
% order to be able to use SPM later, possibly for realignment/unwarping.
% SYNTAX
% [nifti_filename affine_mat_filename] = pat_raw2nifti_bmode(fileName, output_dir)
% INPUTS
% fileName          Full file name to open (with extension .bmode)
% output_dir        Directory where the NIfTI files will be saved
% OUTPUTS
% nifti_filename        Cell with HbT and SO2 filenames
% affine_mat_filename   Cell with HbT and SO2 affine matrices filenames
% param                 
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% read RAW PA-mode images, Dimensions: [nDepth nWidth 1 nFrames]
[rawDataBmode, param] = pat_VsiOpenRawBmode_multi(fileName);
% Number of frames
nFrames = size(rawDataBmode,4);
% Creating nifti file names
[~, name, ~] = fileparts(fileName);
fnameBmode = fullfile(output_dir,[name,'.bmode.nii']);
% NIfTI file name
nifti_filename{1} = fnameBmode;
% Affine matrix file name
affine_mat_filename{1} = regexprep(fnameBmode,'.nii','.mat');

% Single frame dimensions: [nDepth nWidth 1]
dim = [param.BmodeNumSamples param.BmodeNumLines 1];
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
matTranslation(2,4) = -param.BmodeDepthOffset;
% Final Affine transformation matrix: 
mat = matTranslation * matScaling * matRotation;

fprintf('Creating NIfTI volume from %s...\n',fileName);
% Initialize progress bar
spm_progress_bar('Init', nFrames, sprintf('Write %d B-mode frames to NIfTI\n',nFrames), 'Frames');
pat_text_waitbar(0, sprintf('Write %d B-mode frames to NIfTI\n',nFrames));
% Creates NIfTI volume frame by frame
for iFrames = 1:nFrames
    hdrBmode = pat_create_vol(fnameBmode, dim, dt, pinfo, mat, iFrames,...
        squeeze(rawDataBmode(:,:,1,iFrames)));
    % Update progress bar
    spm_progress_bar('Set', iFrames);
    pat_text_waitbar(iFrames/nFrames, sprintf('Processing frame %d from %d', iFrames, nFrames));
end
% Clear progress bar
spm_progress_bar('Clear');
pat_text_waitbar('Clear');
fprintf('%d frames saved to NIfTI volume!\nOutput file: %s\n',nFrames,nifti_filename{1});

% EOF
