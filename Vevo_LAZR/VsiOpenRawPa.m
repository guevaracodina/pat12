% VsiOpenRawPa.m
% Copyright VisualSonics 1999-2010
% A. Needles
% Revision: 1.0 Dec 3 2010
% A function to open RAW PA-Mode files from data export on the Vevo 2100
% and read selected parameters


function [Rawdata, WidthAxis, DepthAxis] = VsiOpenRawPa(fnameBase, ModeName, iframe)

% Set up file names
fname = [fnameBase ModeName];
fnameXml = [fnameBase '.xml'];

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXml(fnameXml, ModeName);
PaNumSamples = param.PaNumSamples;
PaNumLines = param.PaNumLines;
PaDepthOffset = param.PaDepthOffset; %mm
PaDepth = param.PaDepth; %mm
PaWidth = param.PaWidth; %mm
BmodeDepth =  param.BmodeDepth; %mm
BmodeWidth =  param.BmodeWidth; %mm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is to strip the header data in the files - DO NOT CHANGE
size = 2; % 4 bytes
file_header = 40; % 40bytes
line_header = 0; % 4bytes
frame_header = 56; % bytes  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
fid = fopen(fname,'r');

DepthAxis = [PaDepthOffset:(PaDepth-PaDepthOffset)/(PaNumSamples-1):PaDepth];
WidthAxis = [0:PaWidth/(PaNumLines-1):PaWidth];

     
% Initialize data
Rawdata = zeros(PaNumSamples, PaNumLines);

% Updated by A. Needles Oct 2, 2012 for opening Oxy-Hemo raw file
if mod(iframe,2) == 1
    TempFrame = (iframe+1)/2;
else
    TempFrame = iframe/2;
end

header = file_header + frame_header*TempFrame + (size*PaNumSamples*PaNumLines + PaNumLines*line_header)*(iframe-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:PaNumLines
    fseek(fid, header + (size*PaNumSamples + line_header)*(i-1),-1);
    fseek(fid, line_header, 'cof');
    [Rawdata(:,i),count]=fread(fid, PaNumSamples, 'ushort');
end
fclose(fid);