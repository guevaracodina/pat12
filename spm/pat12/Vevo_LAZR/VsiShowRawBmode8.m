% VsiShowRawBmode8.m
% Copyright VisualSonics 1999-2012
% A. Needles
% Revision: 1.0 Oct 24 2012
% A script to display RAW 8-bit B-Mode files from data export on the Vevo 2100
% and calls the functions "VsiOpenRawBmode8" and "VsiParseXml"


clear all
close all

% Edit these parameters
fbase = 'F:\Edgar\Data\Injection\RatToeD9_2013-05-16-13-05-51.raw';
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
