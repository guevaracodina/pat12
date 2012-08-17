function [] = DisplayUSdata(handles, abs_data, param)


set(0,'defaultTextUnits','Normalized');

handles.acq.image_dims = size(abs_data);

% MS250/LZ250 settings
a = 0.25e-3; %m - lens thickness
pitch = 90e-6; %m

% Paramters not yet in the xml file but should be added - DO NOT CHANGE
NumPulses = 1; 
Quad2x = 'true';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
samples = param.BmodeNumSamples;
lines = param.BmodeNumLines;
DepthOffset = param.BmodeDepthOffset; %mm
Depth =  param.BmodeDepth; %mm
Width = pitch*lines*1e3; %mm
fs = param.BmodeRxFrequency; %Hz
YOffset = handles.acq.YOffset;
VOffset = handles.acq.VOffset;

% Setup the Rx axes
DepthAxis = [DepthOffset:(Depth-DepthOffset)/(samples-1):Depth];
WidthAxis = [0:Width/((lines/NumPulses)-1):Width];
DR = 60; % Dynamic Range in dB 
% Parse the XML parameter file - DO NOT CHANGE


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axes(handles.axes1);
rescaled_abs_data = min(abs_data(:))+ abs_data+1;
image_finale =  128/60*(20.*log10(sqrt(rescaled_abs_data)) - YOffset) + VOffset;
image_finale(find(image_finale < 0)) = 0;
image_finale(find(image_finale > 128)) = 128;

% clims = [0 128];
% handles.acq.himage = imagesc(WidthAxis, DepthAxis, image_finale, clims);

X_lim = get(handles.axes1,'XLim');
Y_lim = get(handles.axes1,'YLim');

handles.acq.himage = image(WidthAxis, DepthAxis, image_finale);

set(handles.axes1,'YLim',Y_lim);
set(handles.axes1,'XLim',X_lim);

if (handles.acq.starting_flag)
    axis equal
    axis tight
end

xlabel('Width (mm)')
ylabel('Depth (mm)')
		
colormap(handles.acq.cmap);
colorbar