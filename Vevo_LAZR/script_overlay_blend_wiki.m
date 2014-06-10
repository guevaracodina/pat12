%% Load data
clear all; close all; clc
anatVol = spm_vol('D:\Edgar\Data\IOS_Carotid_Res\12_10_18,NC09\S01\12_10_18,NC09_anat_S01.nii');
brainVol = spm_vol('D:\Edgar\Data\IOS_Carotid_Res\12_10_18,NC09\S01\12_10_18,NC09_anat_brainmask.nii');
fcMapVol = spm_vol('D:\Edgar\Data\IOS_Carotid_Res\alignment\HbO\NC_R08C05\AVG_fcMap.img');
anatomical = spm_read_vols(anatVol);
fcMap = spm_read_vols(fcMapVol);
brainMask = spm_read_vols(brainVol);
fcMapRange = [-0.2733 0.9052];
alphaRange = [0.15 1];
fcColorMap = jet(256);
figIntensity = 1;
% Transpose
fcMap = fliplr(fcMap);
fcMap = fcMap';
brainMask = brainMask';
anatomical = anatomical';

%% Open figures
close all
figure; imagesc(brainMask); colormap(gray); colorbar
figure; imagesc(anatomical); colormap(gray); colorbar
figure; imagesc(fcMap, fcMapRange); colormap(fcColorMap); colorbar
figure;
[fcMapBlend h] = pat_overlay_blend(anatomical, fcMap, brainMask, fcMapRange,alphaRange, fcColorMap, figIntensity);

% EOF
