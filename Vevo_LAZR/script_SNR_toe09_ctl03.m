%% load data to compute SNR for HbT, SO2
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\GLMfcPAT\PAT.mat')
HbT = spm_read_vols(volHbT);
HbTimg = squeeze(HbT(:,:,1,1));
volSO2 = spm_vol(fullfile('F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03','2012-11-09-16-18-31_RS_CTL3_12_11_09-2012-11-09-10-07-10_1.raw.SO2.nolpf.nii'));
SO2 = spm_read_vols(volSO2);
SO2img = squeeze(SO2(:,:,1,1));

%% SNR computation
h = figure(48);  set(gcf, 'color', 'w')
subplot(121);
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, HbTimg)
colormap(gray)
xlabel('[mm]','FontSize',12); ylabel('[mm]','FontSize',12); 
axis image
% Rectangular ROI
title('Choose signal ROI')
roiPos = round(wait(imrect));
% ROI coordinates
y1 = roiPos(2);
y2 = roiPos(2) + roiPos(4);
x1 = roiPos(1);
x2 = roiPos(1) + roiPos(3);
% ROI signal
HbTsignal = HbTimg(y1:y2,x1:x2);
HbTsignal = mean(HbTsignal(:));
title('Choose background ROI')
roiPos = round(wait(imrect));
% ROI coordinates
y1 = roiPos(2);
y2 = roiPos(2) + roiPos(4);
x1 = roiPos(1);
x2 = roiPos(1) + roiPos(3);
% ROI signal
HbTnoise = HbTimg(y1:y2,x1:x2);
HbTnoise = std(HbTnoise(:));
title(sprintf('SNR(HbT) = %0.2f dB',20*log10(HbTsignal / HbTnoise)),'FontSize',12); 
fprintf('SNR(HbT) = %f dB\n',20*log10(HbTsignal / HbTnoise));

subplot(122);
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, SO2img)
colormap(gray)
xlabel('[mm]','FontSize',12); ylabel('[mm]','FontSize',12); 
set(gca,'FontSize',12)

axis image
% Rectangular ROI
title('Choose signal ROI')
roiPos = round(wait(imrect));
% ROI coordinates
y1 = roiPos(2);
y2 = roiPos(2) + roiPos(4);
x1 = roiPos(1);
x2 = roiPos(1) + roiPos(3);
% ROI signal
SO2signal = SO2img(y1:y2,x1:x2);
SO2signal = mean(SO2signal(:));
title('Choose background ROI')
roiPos = round(wait(imrect));
% ROI coordinates
y1 = roiPos(2);
y2 = roiPos(2) + roiPos(4);
x1 = roiPos(1);
x2 = roiPos(1) + roiPos(3);
% ROI signal
SO2noise = SO2img(y1:y2,x1:x2);
SO2noise = std(SO2noise(:));
title(sprintf('SNR(SO_2) = %0.2f dB',20*log10(SO2signal / SO2noise)),'FontSize',12); 
fprintf('SNR(SO2) = %f dB\n',20*log10(SO2signal / SO2noise));

% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 6 3])
set(h, 'PaperPosition', [0.1 0.1 6 3])

%% Print images
% Save as PNG
print(h, '-dpng', fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures\SNR', 'PAT_SNR'), '-r300');
% Save as a figure
saveas(h, fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures\SNR', 'PAT_SNR'), 'fig');

%% Compare to OIS
uiopen('D:\Edgar\Data\IOS_Carotid_Res\12_10_18,NC09\S01\12_10_18,NC09_anat_S01.fig',1);
h = gcf;
set(h,'color','w')
OISimg = getimage(h);
colormap gray
axis image

%% Rectangular ROI (OIS)
title('Choose signal ROI')
roiPos = round(wait(imrect));
% ROI coordinates
y1 = roiPos(2);
y2 = roiPos(2) + roiPos(4);
x1 = roiPos(1);
x2 = roiPos(1) + roiPos(3);
% ROI signal
OISsignal = OISimg(y1:y2,x1:x2);
OISsignal = mean(OISsignal(:));
title('Choose background ROI')
roiPos = round(wait(imrect));
% ROI coordinates
y1 = roiPos(2);
y2 = roiPos(2) + roiPos(4);
x1 = roiPos(1);
x2 = roiPos(1) + roiPos(3);
% ROI signal
OISnoise = OISimg(y1:y2,x1:x2);
OISnoise = std(OISnoise(:));
title('')
fprintf('SNR(OIS) = %f dB\n',20*log10(OISsignal / OISnoise));

%% SNR map
HbTmean = mean(squeeze(HbT(:,:,1,:)),3);
HbTstd = std(squeeze(HbT(:,:,1,:)), 0, 3);
HbTSNR = 20*log10(HbTmean ./ HbTstd);

SO2mean = mean(squeeze(SO2(:,:,1,:)),3);
SO2std = std(squeeze(SO2(:,:,1,:)), 0, 3);
SO2SNR = 20*log10(SO2mean ./ SO2std);

h = figure;  set(gcf, 'color', 'w')
subplot(121)
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, HbTSNR)
colormap(gray); colorbar
xlabel('[mm]','FontSize',12); ylabel('[mm]','FontSize',12); 
title('HbT','FontSize',12);
axis image

subplot(122)
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, SO2SNR)
colormap(gray); colorbar
xlabel('[mm]','FontSize',12); ylabel('[mm]','FontSize',12); 
title('SO_2','FontSize',12);
axis image

% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 6 3])
set(h, 'PaperPosition', [0.1 0.1 6 3])

%% Print images
% Save as PNG
print(h, '-dpng', fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures\SNR', 'PAT_SNR_map'), '-r300');
% Save as a figure
saveas(h, fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures\SNR', 'PAT_SNR_map'), 'fig');
% EOF
