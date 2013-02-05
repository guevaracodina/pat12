% VsiOpenRawBmode32.m
% Copyright VisualSonics 1999-2012
% A. Needles
% Revision: 1.0 Oct 24 2012
% A function to open RAW 32-bit B-Mode files from data export on the Vevo 2100
% and read selected parameters


function [Rawdata, WidthAxis, DepthAxis] = VsiOpenRawBmode32(fnameBase, ModeName, iframe)

% Set up file names
fname = [fnameBase ModeName];
fnameXml = [fnameBase '.xml'];

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXml(fnameXml, ModeName);
BmodeNumSamples = param.BmodeNumSamples;
BmodeNumLines = param.BmodeNumLines;
BmodeDepthOffset = param.BmodeDepthOffset; %mm
BmodeDepth = param.BmodeDepth; %mm
BmodeWidth = param.BmodeWidth; %mm
BmodeDepth =  param.BmodeDepth; %mm
BmodeWidth =  param.BmodeWidth; %mm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% This is to strip the header data in the files - DO NOT CHANGE
size = 4; % 4 bytes
file_header = 40; % 40bytes
line_header = 4; % 4bytes
frame_header = 56; % 56bytes  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(fname,'r');
DepthAxis = [BmodeDepthOffset:(BmodeDepth-BmodeDepthOffset)/(BmodeNumSamples-1):BmodeDepth];
WidthAxis = [0:BmodeWidth/(BmodeNumLines-1):BmodeWidth];

% Initialize data
Rawdata = zeros(BmodeNumSamples, BmodeNumLines);

header = file_header + frame_header*iframe + (size*BmodeNumSamples*BmodeNumLines + BmodeNumLines*line_header)*(iframe-1);

for i=1:BmodeNumLines

    fseek(fid, header + (size*BmodeNumSamples + line_header)*(i-1),-1);
    fseek(fid, line_header, 'cof');
    [Rawdata(:,i),count]=fread(fid, BmodeNumSamples, 'float');
    
end

fclose(fid);