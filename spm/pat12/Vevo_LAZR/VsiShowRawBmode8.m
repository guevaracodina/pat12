% VsiShowRawBmode8.m
% Copyright VisualSonics 1999-2012
% A. Needles
% Revision: 1.0 Oct 24 2012
% A script to display RAW 8-bit B-Mode files from data export on the Vevo 2100
% and calls the functions "VsiOpenRawBmode8" and "VsiParseXml"


clear all
close all

% Edit these parameters
fbase = 'E:\Edgar\Data\PAT_Data\2012-11-09-16-23-51_toe09\2012-11-09-16-23-51_RS_TOE9_12_11_09-2012-11-09-14-11-28_1.raw';
fmode = '.bmode';
StartFrame = 1;
EndFrame = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iframe = StartFrame:EndFrame
    
    [ImageData, WidthAxis, DepthAxis] = VsiOpenRawBmode8(fbase, fmode, iframe);
	
    figure; imagesc(WidthAxis, DepthAxis, ImageData);
	colormap('gray')
	colorbar
	axis equal
	axis tight
    xlabel('(mm)')
    ylabel('(mm)')
end
