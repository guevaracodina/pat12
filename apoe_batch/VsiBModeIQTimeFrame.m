function [TimeStampData] = VsiBModeIQTimeFrame(fnameBase, ModeName, n_frames)

% Author: CMP

% Set up file names
fname = [fnameBase '.bmode'];
fnameXml = [fnameBase '.xml'];

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXmlModif(fnameXml,ModeName);
BmodeNumFocalZones = param.BmodeNumFocalZones;
BmodeNumSamples = param.BmodeNumSamples; 
BmodeNumLines = param.BmodeNumLines; 

% This is to strip the header data in the files - DO NOT CHANGE
size = 2; % bytes
file_header = 40; % bytes
line_header = 4; % bytes
frame_header = 56; % bytes  
Nlines= BmodeNumFocalZones*BmodeNumLines;
dwTimeStamp_header = 4;


% Modif Carl - Done separately from data to avoid corruption of data 
TimeStampData = zeros(n_frames,1);

fid = fopen(fname,'r');
fseek(fid, file_header, 'bof');

for i=1:n_frames
    fseek(fid, dwTimeStamp_header, 'cof');
    TimeStampData(i) = fread(fid, 1, 'double=>double');
%     TimeStampData(i) = swapbytes(TimeStampData(i));
    fseek(fid, 44 + (size*BmodeNumSamples*Nlines*2 + Nlines*line_header), 'cof');
end
fclose(fid);