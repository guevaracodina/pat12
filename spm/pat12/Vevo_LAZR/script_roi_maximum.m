%% script_roi_maximum
load('F:\Edgar\Data\PAT_Results_20130517\OxySurge\DG_OS\ROI\PAT.mat')
% SO2
volPAmode = spm_vol(PAT.nifti_files{1,2});
im_PA = spm_read_vols(volPAmode);

%% Integrate signal along 4th dimension (time)
imInt = trapz(im_PA,4);
% Mask out non-brain voxels
volMask = spm_vol(PAT.fcPAT.mask.fname);
im_Mask = spm_read_vols(volMask);
imIntMask = nan(size(imInt));
imIntMask(im_Mask==1) = imInt(im_Mask==1);

%% DisplayPAT.PAparam.DepthAxis
threshold = 1.2e7;
thresholdMask = imIntMask >= threshold;
h = figure; imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, imIntMask .* thresholdMask);
axis image

%% Compute local maxima
imIntMask(isnan(imIntMask)) = 0;
BW = imregionalmax(imIntMask);

% EOF
