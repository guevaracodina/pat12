% VsiShowRawPa.m
% Copyright VisualSonics 1999-2010
% A. Needles
% Revision: 1.0 Dec 3 2010
% A script to display RAW PA-Mode files from data export on the Vevo 2100
% and calls the functions "VsiOpenRawPa" and "VsiParseXml"


% clear all
close all

% Edit these parameters
% fbase = 'LZ250 pa mode full width RAW.raw';
fbase = 'D:\Edgar\Data\PAT_Data\2012-09-07-10-40-07.raw'; 
fmode = '.pamode';
StartFrame = 1;
EndFrame = 6;
DisplayMapLow = 20; %dB
DisplayMapHigh = 100; %dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('RedMap.mat');
nRows = 2;
figure;
for iframe = StartFrame:EndFrame
% for iframe = StartFrame:2:EndFrame
    
    [Rawdata, WidthAxis, DepthAxis] = VsiOpenRawPa(fbase, fmode, iframe);
	
    ImageData = 20*log10(Rawdata);
    
%     imagesc(WidthAxis, DepthAxis, ImageData, [DisplayMapLow DisplayMapHigh]);
    subplot(ceil((EndFrame-StartFrame)/nRows),nRows, iframe)
    imagesc(WidthAxis, DepthAxis, Rawdata);
	colormap(redmap)
% 	colorbar
	axis equal
	axis tight
    xlabel('(mm)')
    ylabel('(mm)')
    if mod(iframe,2)
%         title(sprintf('%s SO_2 Frame %d',fbase, (iframe+1)/2))
        title(sprintf('Frame %d (SO_2)',iframe))
    else
%         title(sprintf('%s HBT Frame %d',fbase, iframe/2))
        title(sprintf('Frame %d (HBT)',iframe))
    end
%     title(sprintf('%s Frame %d',fbase, iframe))
%     pause(0.3)
end
