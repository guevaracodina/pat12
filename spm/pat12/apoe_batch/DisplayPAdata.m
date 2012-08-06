function [handles] = DisplayPAdata(handles, BfData, param)



%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Beamforming Settings - these paramters need to be set manually
Beamform= 1; % This can be turned off (set = 0) if you just want to open a file and look at the data without beamforming

% This determines how many quadrants are used for full-width
ApertureStart = 0; % zero-based
ApertureEnd = 255; % zero-based

% This determines how many quadrants are used for half-width (uncomment)
%ApertureStart = 64; % zero-based
%ApertureEnd = 191; % zero-based

% Size of aperture to use for beamforming
NoElem=64;

% Set the region of the dataset to beamform (for speed)
StartLine = 0.0; % as a fractional percentage of total
EndLine = 1.0;  % as a fractional percentage of total
StartSample = 0.01; % as a fractional percentage of total
EndSample = 1.0; % as a fractional percentage of total
% StartSample = 0; % as a fractional percentage of total
% EndSample = 0.99; % as a fractional percentage of total

%contants
ct = 1540; %m/s
cl = 2340; %m/s

% MS250/LZ250 settings
a = 0.25e-3; %m - lens thickness
pitch = 90e-6; %m


% Display Options, 0 = OFF, 1 = ON
ShowIQ = 0;
ShowReorderedIQ = 0;
ShowBeamformedIQ = 1;
DR = -60; % Dynamic Range in dB 
%%%%%%%%%%%%%%%%%%%%%%%%%%

% These parameters need to be set manually for opening the file
% StartFrame = 1; 
% EndFrame = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Parse the XML parameter file - DO NOT CHANGE

samples = param.PaNumSamples;
lines = param.PaNumLines;
DepthOffset = param.PaDepthOffset; %mm
Depth =  param.PaDepth; %mm
Width = pitch*lines*1e3; %mm
fs = param.BmodeRxFrequency; %Hz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Paramters not yet in the xml file but should be added - DO NOT CHANGE
NumPulses = 1; 
Quad2x = 'true';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup the Rx axes
DepthAxis = [DepthOffset:(Depth-DepthOffset)/(samples-1):Depth];
WidthAxis = [0:Width/((lines/NumPulses)-1):Width];

DR = -60; % Dynamic Range in dB 

DisplayMapLow = -40; %dB
DisplayMapHigh = -10; %dB

abs_data = abs(BfData);
abs_data = abs_data/max(abs_data(:));

image_finale = 20.*log10(abs_data);
image_finale = image_finale -(DisplayMapLow);
image_finale = image_finale/(DisplayMapHigh-DisplayMapLow)*128;
image_finale(find(image_finale < 0)) = 0;
image_finale(find(image_finale > 128)) = 128;
image_finale = image_finale + 129;

axes(handles.axes2);
handles.acq.h_axes2 = image(WidthAxis, DepthAxis, image_finale);

axis equal
axis tight
xlabel('Width (mm)')
ylabel('Depth (mm)')
% colormap(jet);
colorbar