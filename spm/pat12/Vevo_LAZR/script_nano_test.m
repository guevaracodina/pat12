%% script_nano_test
clear; close all; clc
% Wavelengths
wl(1,1) = 680;
% wl(2,1) = 700;
% Read PAT matrix (change as needed)
load('D:\Edgar\Data\PAT_results\20140401\AT_680nm\PAT.mat')
% Image display limits (colormap)
imMin = 20;
imMax = 70;
% If image was flipped L-R during acquisition
FLIPIMAGE = true;

%% Load data
vol = spm_vol(PAT.nifti_files{1});
PAT_images = spm_read_vols(vol);
if FLIPIMAGE
    for iFrames = 1:size(PAT_images,4)
        PAT_images(:,:,1,iFrames) = fliplr(squeeze(PAT_images(:,:,1,iFrames)));
    end
end
vol = spm_vol(PAT.nifti_files{3});
bMode =  spm_read_vols(vol);
bMode = mean(squeeze(bMode),3);
if FLIPIMAGE
    bMode = fliplr(bMode);
end
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
% Choose wavelength index (in case of multiple wavelengths)
iWl = 1;
h1 = figure; set(h1,'Color','w')
set(h1,'Name','Only PAT (colorbar)')
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze((PAT_avg(:,:,iWl))), [imMin imMax]);
colormap(jet(256)); colorbar; axis image
xlabel('Width(mm)'); ylabel('Depth{mm}')
h2 = figure;  set(h2,'Color','w')
set(h2,'Name','UltraSound')
imagesc(PAT.bModeParam.WidthAxis, PAT.bModeParam.DepthAxis, bMode);
colormap(gray); axis image
xlabel('Width(mm)'); ylabel('Depth{mm}')
h3 = figure; set(h3,'Color','k')
set(h3,'Name','PAT overlaid US')
[fcMapBlend h] = pat_overlay_blend(bMode, (PAT_avg(:,:,iWl)), [], [imMin imMax]);
set(gca,'DataAspectRatio',[1 PAT.bModeParam.pixWidth/PAT.bModeParam.pixDepth 1]);
% Binary mask
figure(h1)
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
end

%% ROI display (mean + std dev)
h4 = figure; set(h4,'Color','w')
set(h4,'Name','ROI measurements')
pat_barwitherr([ROI(:,2)  ROIBgnd(:,2)], [ROI(:,1) ROIBgnd(:,1)])
ylabel('PA amplitude (dB)', 'FontSize', 14)
xlabel('\lambda (nm)', 'FontSize', 14)
ylim([0 1.2*imMax])
set(gca,'XTickLabel', cellfun(@(x) num2str(x), num2cell([wl; wl]), 'UniformOutput',false))
colormap([1 1 1;0 0 0;0.5 0.5 0.5]);
legend({'Tube';'Background'}, 'FontSize', 14)

%% Animation
figure; set(gcf,'Color','w')
set(gcf,'Name','Animation')
for iFrames = 1:nFrames
    imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze((PAT_nano{iWl}(:,:,iFrames))), [imMin imMax]);
    colorbar
    title(sprintf('Frame: %d', iFrames))
    pause(0.05)
end

% EOF
