% VsiShowRawPa.m
% Copyright VisualSonics 1999-2010
% A. Needles
% Revision: 1.0 Dec 3 2010
% A script to display RAW PA-Mode files from data export on the Vevo 2100
% and calls the functions "VsiOpenRawPa" and "VsiParseXml"


% clear all
close all

% Edit these parameters
% fileName = 'LZ250 pa mode full width RAW.raw';
fileName = 'D:\Edgar\Data\PAT_Data\2012-09-07-11-04-40.raw.pamode'; 
% fmode = '.pamode';
StartFrame = 648;
EndFrame = 648;
DisplayMapLow = 20; %dB
DisplayMapHigh = 100; %dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rawDataSO2, rawDataHbT, param] = pat_VsiOpenRawPa_multi(fileName);

%% Display PAT raw images
load('RedMap.mat');
figure; set(gcf,'color','w')
for i =1:size(rawDataSO2,4)
    ImageData = 20*log10(squeeze(rawDataSO2(:,:,1,i)));
    imagesc(param.WidthAxis, param.DepthAxis, ImageData);
    colormap(redmap)
    axis equal
    axis tight
    xlabel('(mm)')
    ylabel('(mm)')
    title(sprintf('Frame %d',i))
    pause(0.1)
end

%% Save NIfTI
fileName = 'D:\Edgar\Data\PAT_Data\2012-09-07-11-04-40.raw.pamode';
pat_raw2nifti(fileName);

%%
addpath(genpath('D:\Edgar\ssoct\Matlab'))
export_fig(fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT',...
    'Vevo_Export_Data_Matlab_correct'),'-png',gcf)
