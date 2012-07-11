% VsiBModeReconstructRF.m
% A script to open IQ files from B-Mode data export on the Vevo 2100
% and reconstruct the RF signal
% Authors: A. Needles, J. Mehi  
% Copyright VisualSonics 1999-2010
% Revision: 1.0 June 28 2010
% Revision: 1.1 July 22 2010: for software version 1.2 or higher
function [handles] = VsiBModeReconstructRFModif(handles,fnameBase, frameNumber)

set(0,'defaultTextUnits','Normalized');

% % specify filename here ------------------
% fnameBase = 'test_export_PA_3D_2012-02-21-12-26-25.iq';
% % specify frame number here ------------------
% frameNumber = 100;
% ------------------------------------------
[Idata,Qdata,param] = VsiBModeIQModif(fnameBase, '.bmode', frameNumber);
% ------------------------------------------

% BmodeNumSamples = param.BmodeNumSamples;
% BmodeNumFocalZones = param.BmodeNumFocalZones;
% BmodeNumLines = param.BmodeNumLines; 
% BmodeDepthOffset = param.BmodeDepthOffset; 
% BmodeDepth = param.BmodeDepth; 
% BmodeWidth = param.BmodeWidth; 
% BmodeQuad2x = param.BmodeQuad2x;
% BmodeRxFrequency = param.BmodeRxFrequency; %Hz
% BmodeTxFrequency = param.BmodeTxFrequency; %Hz
% % ------------------------------------------
% % Setup the Rx frequency
% fs= BmodeRxFrequency;
% f_rf = fs; % reconstruct to the original Rx freq in the param file
% if strcmp(BmodeQuad2x,'true') 
%     fs = fs*2; % actual Rx freq is double because of Quad 2x
%     IntFac = 8;
% else
%     IntFac = 16;
% end
% fs_int = fs*IntFac;
% 
% % Initialize
% IdataInt = zeros(BmodeNumSamples*IntFac, BmodeNumLines);
% QdataInt = zeros(BmodeNumSamples*IntFac, BmodeNumLines);
% RfData = zeros(BmodeNumSamples*IntFac, BmodeNumLines);
% t = [0:1/fs_int:((BmodeNumSamples*IntFac)-1)/fs_int];
% 
% % Interpolate I/Q and reconstruct RF
% for i=1:BmodeNumLines
%     IdataInt(:,i) = interp(Idata(:,i), IntFac);
%     QdataInt(:,i) = interp(Qdata(:,i), IntFac);
%     % phase term in complex exponential modified for rev. 1.1
%     RfData(:,i) = real(complex(IdataInt(:,i), QdataInt(:,i)).*exp(sqrt(-1)*(2*pi*f_rf*t')));
% end
% 
% if strcmp(BmodeQuad2x,'true')
%     RfData= -RfData;  
% end
% 
% % plot B-Mode image and reconstructed RF line
% % specify which RF line to plot 
% % specify range for RF data plot  
% % RF samples range from 1 to BmodeNumSamples*IntFac
% % ------------------------
% lineNumber= 250;
% sampleWindow= 2000:5000;
% ----------------------------------
% fig1= figure('units','normalized','position',[.01 .55 .4 .35]);
handles.acq.image_dims = size(Idata);

fnameXml = [fnameBase '.xml'];

% MS250/LZ250 settings
a = 0.25e-3; %m - lens thickness
pitch = 90e-6; %m

% Paramters not yet in the xml file but should be added - DO NOT CHANGE
NumPulses = 1; 
Quad2x = 'true';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param = VsiParseXmlModif(fnameXml, '.bmode');
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
% handles.acq.himage = imagesc(10*log10(Idata.^2 + Qdata.^2)); 
% MaxVal = max(max(abs(BfData(:,:))));
% handles.acq.himage = imagesc(WidthAxis, DepthAxis, 20.*log10(Idata.^2 + Qdata.^2));
% handles.acq.himage = imagesc(WidthAxis, DepthAxis, 20.*log10(sqrt(Idata.^2 + Qdata.^2)));
abs_data = Idata.^2 + Qdata.^2;
abs_data = min(abs_data(:))+ abs_data+1;
% VOffset = 64;  % 128
% YOffset = 55;       % 55
image_finale =  128/60*(20.*log10(sqrt(abs_data)) - YOffset) + VOffset;
image_finale(find(image_finale < 0)) = 0;
image_finale(find(image_finale > 128)) = 128;
min(image_finale(:))
max(image_finale(:))
clims = [0 128];
% handles.acq.himage = imagesc(WidthAxis, DepthAxis, image_finale, clims);
handles.acq.himage = image(WidthAxis, DepthAxis, image_finale);

axis equal 
axis tight
xlabel('Width (mm)')
ylabel('Depth (mm)')
		
colormap(handles.acq.cmap);
colorbar

% title(fnameBase,'interpreter','none');
% colormap('gray'); colorbar;
% fig2= figure('units','normalized','position',[.01 .10 .4 .35]);
% plot(sampleWindow,RfData(sampleWindow,lineNumber)); grid;
% title(fnameBase,'interpreter','none');
% text(.8,.95,['line ' num2str(lineNumber)]);
% xlabel('RF sample number')



