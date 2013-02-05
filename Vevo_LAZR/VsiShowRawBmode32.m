% VsiShowRawBmode32.m
% Copyright VisualSonics 1999-2012
% A. Needles
% Revision: 1.0 Oct 24 2012
% A script to display RAW 32-bit B-Mode files from data export on the Vevo 2100
% and calls the functions "VsiOpenRawBmode32" and "VsiParseXml"


clear all
close all

% Edit these parameters
fbase = 'Bmode32.raw';
fmode = '.bmode';
StartFrame = 1;
EndFrame = 1;
DisplayMapLow = 0; %dB
DisplayMapHigh = 50; %dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iframe = StartFrame:EndFrame
    
    [ImageData, WidthAxis, DepthAxis] = VsiOpenRawBmode32(fbase, fmode, iframe);
	
    figure; imagesc(WidthAxis, DepthAxis, ImageData);
	colormap('gray')
	colorbar
	axis equal
	axis tight
    xlabel('(mm)')
    ylabel('(mm)')
end