%% script_realignment_video
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\PAT.mat')
HbT_vol = spm_vol('F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\2012-11-09-16-18-31_RS_CTL3_12_11_09-2012-11-09-10-07-10_1.raw.bmode.nii');
HbT = spm_read_vols(HbT_vol);
HbT_vol_R = spm_vol('F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\align2012-11-09-16-18-31_RS_CTL3_12_11_09-2012-11-09-10-07-10_1.raw.bmode.nii');
HbT_R = spm_read_vols(HbT_vol_R);

%%
close all; clc
h = figure; set(gcf,'color','w')
colormap(jet);
minVal = min(min(min(HbT)));
maxVal = max(max(max(HbT)));
nFrames = size(HbT,4);
% Prepare the new video file.
fName = 'F:\Edgar\Data\PAT_Results\video\US.avi';
aviobj = avifile(fName);
aviobj.KeyFramePerSec = 10;
aviobj.compression = 'none';
set(gcf,'Renderer','zbuffer');
for iFrames=1:nFrames
    subplot(121); 
    imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze(HbT(:,:,1,iFrames)), [minVal maxVal]);
    axis image; title(sprintf('original (%d/%d)',iFrames,nFrames))
    if iFrames == 1
        set(gca,'nextplot','replacechildren');
    end
    
    subplot(122);
    imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze(HbT_R(:,:,1,iFrames)), [minVal maxVal]);
    axis image; title('realigned')
    if iFrames == 1
        set(gca,'nextplot','replacechildren');
    end

    % write each frame to the file.
    frame = getframe(h);
    aviobj = addframe(aviobj, frame);
end
aviobj = close(aviobj);
fprintf('Video saved as %s\n', fName);
