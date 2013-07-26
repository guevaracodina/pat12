%% script_single_wavelength
clc;
pathName = 'D:\Edgar\Data\PAT_Phantom\Single700';
fileName = '2013-07-24_Single700-2013-07-24-17-10-44_1.raw.pamode';
resPathName = 'D:\Edgar\Data\PAT_Phantom_Res\Single700\';
[rawData, param] = pat_VsiOpenRawPa_singleWL_multi(fullfile(pathName, fileName));

%% 
StartFrame = 1;
EndFrame = 90;
DisplayMapLow = 0; %dB
DisplayMapHigh = 100; %dB

load('RedMap.mat');
figure; set(gcf,'color','w')
for i = StartFrame:EndFrame
    ImageData = 20*log10(squeeze(rawData(:,:,1,i)));
    imagesc(param.WidthAxis, param.DepthAxis, ImageData, [DisplayMapLow DisplayMapHigh]);
    colormap(redmap)
    axis equal
    axis tight
    xlabel('(mm)')
    ylabel('(mm)')
    title(sprintf('Frame %d',i))
    pause(0.2)
end

%% Save NIfTI
% fileName = '2013-07-24_Single700-2013-07-24-17-10-44_1.raw.HbT';
% pat_raw2nifti(fileName);


%% Load ROIs at single wavelength
load('D:\Edgar\Data\PAT_Phantom_Res\Single700\ROI\ROI.mat')

%% Show log scale image at single wavelength
vol = spm_vol('D:\Edgar\Data\PAT_Phantom_Res\Single700\2013-07-24_Single700-2013-07-24-17-10-44_1.raw.HbT.nii');
I = spm_read_vols(vol);
figure; imagesc(PAT.PAparam.PaWidth, PAT.PAparam.PaDepth, log(squeeze(I(:,:,1,1))) );
figure; imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, log(squeeze(I(:,:,1,1))) );
colormap(hot(256))
axis image

%% Plot ROI timecourse at single wavelength
figure; set(gcf,'color','w')
errorbar(ROI{1}{1}, ROIsem{1}{1},'r-','LineWidth',2)
hold on
errorbar(ROI{2}{1}, ROIsem{2}{1},'b-','LineWidth',2)
set(gca,'FontSize',12)
xlabel('Frames','FontSize',12)
ylabel('PA signal [a.u.]','FontSize',12)
legend({'nano Au' 'H_2O'},'FontSize',12,'Location','NorthWest')
axis tight

%% Show log scale image at multiple wavelengths
close all
load('D:\Edgar\Data\PAT_Phantom_Res\NanoStepper680_720\PAT.mat')
vol = spm_vol('D:\Edgar\Data\PAT_Phantom_Res\NanoStepper680_720\2013-07-24_NanoStepper680_720-2013-07-24-14-07-50_1.raw.HbT.nii');
I = spm_read_vols(vol);
figure; set(gcf,'color','w')
colormap(hot(256))

subplot(122)
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, log(squeeze(I(:,:,1,5))));
axis image
set(gca,'FontSize',12)
xlabel('[mm]','FontSize',12)
ylabel('[mm]','FontSize',12)

vol = spm_vol('D:\Edgar\Data\PAT_Phantom_Res\NanoStepper680_720\2013-07-24_NanoStepper680_720-2013-07-24-14-07-50_1.raw.bmode.nii');
I = spm_read_vols(vol);
figure; set(gcf,'color','w')
colormap(gray(256))
subplot(121)
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze(I(:,:,1,5)) );
axis image
set(gca,'FontSize',12)
xlabel('[mm]','FontSize',12)
ylabel('[mm]','FontSize',12)

vol = spm_vol('D:\Edgar\Data\PAT_Phantom_Res\NanoStepper680_720\anatomical_ROI_01_1.nii');
I = spm_read_vols(vol);
subplot(122)
imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, I);
axis image
set(gca,'FontSize',12)
xlabel('[mm]','FontSize',12)
ylabel('[mm]','FontSize',12)


%% Load ROIs at multiple wavelengths
clear
load('D:\Edgar\Data\PAT_Phantom_Res\NanoStepper680_720\ROI.mat')
ROIa = ROI{1}{1}';
load('D:\Edgar\Data\PAT_Phantom_Res\NanoStepper730_770\ROI.mat')
ROIb = ROI{1}{1}';
clear ROI ROIsem ROIstd
ROI680 = ROIa(1:5:end);
ROI680 = ROI680(3:end);     % Remove first 2 datapoints (outliers)
ROI690 = ROIa(2:5:end);
ROI690 = ROI690(3:end);     % Remove first 2 datapoints (outliers)
ROI700 = ROIa(3:5:end);
ROI700 = ROI700(3:end);     % Remove first 2 datapoints (outliers)
ROI710 = ROIa(4:5:end);
ROI710 = ROI710(3:end);     % Remove first 2 datapoints (outliers)
ROI720 = ROIa(5:5:end);
ROI720 = ROI720(3:end);     % Remove first 2 datapoints (outliers)
ROI730 = ROIb(1:5:end);
ROI740 = ROIb(2:5:end);
ROI750 = ROIb(3:5:end);
ROI760 = ROIb(4:5:end);
ROI770 = ROIb(5:5:end);
ROImeans = [mean(ROI680) mean(ROI690) mean(ROI700) mean(ROI710) mean(ROI720)...
    mean(ROI730) mean(ROI740) mean(ROI750) mean(ROI760) mean(ROI770)];
ROIstds = [std(ROI680) std(ROI690) std(ROI700) std(ROI710) std(ROI720)...
    std(ROI730) std(ROI740) std(ROI750) std(ROI760) std(ROI770)];
figure; set(gcf,'color','w')
pat_barwitherr(ROIstds, ROImeans)
colormap([0.8 0.8 0.8]);
set(gca,'FontSize',12)
set(gca,'xTickLabel',num2cell(680:10:770))
xlabel('\lambda[nm]','FontSize',12)
ylabel('PA signal[a.u.]','FontSize',12)
axis tight
% EOF
