%% script_nano_test
clear; close all; clc
% Wavelengths
wl(1) = 680;
wl(2) = 750;
wl(3) = 800;
wl(4) = 901;
wl(5) = 970;
% Read PAT matrix
% load('F:\Edgar\Data\nanoPAT\PAT_Results\2013-12-03-13-34-41_TmDMSOIntralipid\PAT.mat')
% load('F:\Edgar\Data\nanoPAT\PAT_Results\2013-12-03-13-34-41_TmDMSOWater\PAT.mat')
load('F:\Edgar\Data\nanoPAT\PAT_Results\2013-12-03-13-34-41_TmWaterIntralipid\PAT.mat')
% load('F:\Edgar\Data\nanoPAT\PAT_Results\2013-12-03-13-34-41_TMWaterWater\PAT.mat')

%% Load data
vol = spm_vol(PAT.nifti_files{1});
PAT_images = spm_read_vols(vol);
vol = spm_vol(PAT.nifti_files{3});
bMode =  spm_read_vols(vol);
nWl = numel(wl);
for iWl = 1:nWl,
    PAT_nano{iWl} = PAT_images(:, :, 1, iWl:nWl:end);
    nFrames(iWl) = size(PAT_nano{iWl},4);
end
nFrames = min(nFrames);
for iWl = 1:nWl,
    PAT_nano{iWl} = PAT_nano{iWl}(:,:,:,1:nFrames);
    PAT_avg(:,:,iWl) = mean(PAT_nano{iWl},4);
end

%% ROI selection
% Wavelength index
iWl = 5;
% figure; imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze(20*log10(PAT_avg(:,:,iWl))), [20 70]);
% colormap(jet(256)); colorbar; axis image
figure; imagesc(PAT.bModeParam.WidthAxis, PAT.bModeParam.DepthAxis, squeeze(bMode(:,:,1,1)));
colormap(gray); axis image
% figure;
% [fcMapBlend h] = pat_overlay_blend(squeeze(bMode(:,:,1,1)), 20*log10(PAT_avg(:,:,iWl)), [], [20 70]);
% set(gca,'DataAspectRatio',[1 PAT.bModeParam.pixWidth/PAT.bModeParam.pixDepth 1]);
% Binary mask
title('Choose ROI over tube')
roiMask = roipoly;
title('Choose ROI over background')
roiMaskBgnd = roipoly;

%% ROI computation
for iWl = 1:nWl,
    currentImage = squeeze(PAT_nano{iWl});
    ROI(iWl, 1) = mean2(currentImage(repmat(roiMask,[1 1 nFrames])));
    ROI(iWl, 2) = std2(currentImage(repmat(roiMask,[1 1 nFrames])));
    ROIBgnd(iWl, 1) = mean2(currentImage(repmat(roiMaskBgnd,[1 1 nFrames])));
    ROIBgnd(iWl, 2) = std2(currentImage(repmat(roiMaskBgnd,[1 1 nFrames])));
    % Not necessary to loop over frames, just to confirm processing
%     for iFrames = 1:nFrames,
%         currentFrame = squeeze(currentImage(:,:,iFrames));
%         ROI2(iWl, 1, iFrames) = mean2(currentFrame(roiMask));
%         ROI2(iWl, 2, iFrames) = std2(currentFrame(roiMask));
%     end
%     ROI2mean = mean(ROI2,3);
end
%% ROI display (mean + std dev)
figure;
pat_barwitherr([ROI(:,2)  ROIBgnd(:,2)], [ROI(:,1) ROIBgnd(:,1)])
ylabel('PA amplitude (a.u.)', 'FontSize', 14)
xlabel('\lambda (nm)', 'FontSize', 14)
ylim([0 1800])
set(gca,'XTickLabel', cellfun(@(x) num2str(x), num2cell([wl; wl]), 'UniformOutput',false))
colormap([1 1 1;0 0 0;0.5 0.5 0.5]);
legend({'Tube' 'Background'}, 'FontSize', 14)

%% Animation
figure;
iWl = 4;
for iFrames = 1:nFrames
    imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze((PAT_nano{iWl}(:,:,iFrames))), [10 800]);
    colorbar
    title(sprintf('%d', iFrames))
    pause(0.1)
end

% EOF
