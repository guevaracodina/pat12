function [nifti_filename affine_mat_filename param] = pat_raw2nifti(fileName, output_dir)
% Converts RAW PA-Mode files from data export on the Vevo 2100 to NIfTI files in
% order to be able to use SPM later, possibly for realignment/unwarping.
% SYNTAX
% [nifti_filename affine_mat_filename] = pat_raw2nifti(fileName, output_dir)
% INPUTS
% fileName          Full file name to open (with extension .pamode)
% output_dir        Directory where the NIfTI files will be saved
% OUTPUTS
% nifti_filename        Cell with HbT and SO2 filenames
% affine_mat_filename   Cell with HbT and SO2 affine matrices filenames
% param                 PA-mode parameters
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% This code needs to be improved to accomodate for all the cases:
% <parameter name="Pa-Mode/Acquisition-Mode" value="Oxy-Hemo"/>
% <parameter name="Pa-Mode/Acquisition-Mode" value="Standard"/>
% <parameter name="Pa-Mode/Acquisition-Mode" value="NanoStepper"/>
% Currently it works only for HbT/sO2, for the other cases the data reading is
% ok, but the images are saved into a single file, with the wrong color index.
% Acquisition done at a single wavelength. //EGC
SINGLEWAVELENGTH = true;

if ~SINGLEWAVELENGTH
    % read RAW PA-mode Oxy-Hemo images, Dimensions: [nDepth nWidth 1 nFrames]
    [rawDataSO2, rawDataHbT, param] = pat_VsiOpenRawPa_multi(fileName);
else
    % Single-wavelength or nano-stepper images
    [rawDataHbT, param] = pat_VsiOpenRawPa_singleWL_multi(fileName);
    rawDataSO2 = rawDataHbT;
end
% Number of frames
nFrames = size(rawDataHbT,4);
% Creating nifti file names
[~, name, ~] = fileparts(fileName);
fnameHbT = fullfile(output_dir,[name,'.HbT.nii']);
fnameSO2 = fullfile(output_dir,[name,'.SO2.nii']);
% NIfTI file name
nifti_filename{1} = fnameHbT;
nifti_filename{2} = fnameSO2;
% Affine matrix file name
affine_mat_filename{1} = regexprep(fnameHbT,'.nii','.mat');
affine_mat_filename{2} = regexprep(fnameSO2,'.nii','.mat');
% Single frame dimensions: [nDepth nWidth 1]
dim = [param.PaNumSamples param.PaNumLines 1];
% Data type. Visualsonics Vevo LAZR exports HbT/SO2 data as ushort (16-bits)
% dt = [spm_type('float64') spm_platform('bigend')];
dt = [spm_type('uint16') spm_platform('bigend')];
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
mat = matTranslation * matScaling * matRotation;

fprintf('Creating NIfTI volume from %s...\n',fileName);
% Initialize progress bar
spm_progress_bar('Init', nFrames, sprintf('Write %d PA frames to NIfTI\n',nFrames), 'Frames');
pat_text_waitbar(0, sprintf('Write %d PA frames to NIfTI\n',nFrames))
% Creates NIfTI volume frame by frame
for iFrames = 1:nFrames
    hdrSO2 = pat_create_vol(fnameSO2, dim, dt, pinfo, mat, iFrames,...
        squeeze(rawDataSO2(:,:,1,iFrames)), 'SO2 created with pat12');
    hdrHbT = pat_create_vol(fnameHbT, dim, dt, pinfo, mat, iFrames,...
        squeeze(rawDataHbT(:,:,1,iFrames)), 'HbT created with pat12');
    % Update progress bar
    spm_progress_bar('Set', iFrames);
    pat_text_waitbar(iFrames/nFrames, sprintf('Processing frame %d from %d', iFrames, nFrames));
end
% Clear progress bar
spm_progress_bar('Clear');
pat_text_waitbar('Clear');
fprintf('%d frames saved to NIfTI volume!\nOutput dir1: %s\nOutput dir2: %s\n',nFrames,nifti_filename{1},nifti_filename{2});

% EOF
