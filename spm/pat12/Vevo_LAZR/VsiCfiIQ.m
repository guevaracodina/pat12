function [Idata,Qdata,param] = VsiCfiIQ(fnameBase, ModeName, iframe)
% Copyright VisualSonics 1999-2010
% Revision: 1.1 March  18 2011
% reads IQ data and system parameters
% Set up file names

% Parse the XML parameter file 
fnameXml = [fnameBase '.xml'];

% header data sizes 
size = 2; % bytes
file_header = 40; % bytes
line_header = 4; % bytes
frame_header = 56; % bytes  

switch ModeName
    case '.color'
% ---------------------------------------------
param = VsiParseXml(fnameXml,'.color');    
% ---------------------------------------------
% Color Flow parameters required to read IQ data
ColorNumSamples = param.ColorNumSamples; 
ColorNumLines = param.ColorNumLines; 
ColorDepthOffset = param.ColorDepthOffset; 
ColorNumEnsemble = param.ColorNumEnsemble;
ColorEnsembleExtra = param.ColorEnsembleExtra; 
ColorLinesExtra = param.ColorLinesExtra; 
% read color flow IQ data
fname = [fnameBase '.color'];
Nlines= (ColorNumLines+ColorLinesExtra)*(ColorNumEnsemble + ColorEnsembleExtra);
Nsamples= ColorNumSamples;
fid = fopen(fname,'r')  
% Initialize data
Idata = zeros(Nsamples, Nlines);
Qdata = zeros(Nsamples, Nlines);
header = file_header + frame_header*iframe + (size*Nsamples*Nlines*2 + Nlines*line_header)*(iframe-1);
for i=1:Nlines
    fseek(fid, header + (size*Nsamples*2 + line_header)*(i-1),-1);
    fseek(fid, line_header, 'cof');
    [Qdata(:,i),count]=fread(fid, Nsamples, 'int16', size,'ieee-be');
    fseek(fid, header + (size*Nsamples*2 + line_header)*(i-1) + size,-1);
    fseek(fid, line_header, 'cof');
    [Idata(:,i),count]=fread(fid, Nsamples, 'int16', size,'ieee-be');
end
fclose(fid);

    case '.bmode'
% ---------------------------------------------
param = VsiParseXml(fnameXml,'.color');    
% ---------------------------------------------
% B-Mode parameters required to read IQ data
BmodeNumSamples = param.BmodeNumSamples; 
BmodeNumLines = param.BmodeNumLines; 
% read B-Mode IQ data
fname = [fnameBase '.bmode'];
Nlines= BmodeNumLines;
Nsamples= BmodeNumSamples;
fid = fopen(fname,'r')  
% Initialize data
Idata = zeros(Nsamples, Nlines);
Qdata = zeros(Nsamples, Nlines);
header = file_header + frame_header*iframe + (size*Nsamples*Nlines*2 + Nlines*line_header)*(iframe-1);
for i=1:Nlines
    fseek(fid, header + (size*Nsamples*2 + line_header)*(i-1),-1);
    fseek(fid, line_header, 'cof');
    [Qdata(:,i),count]=fread(fid, Nsamples, 'int16', size);
    fseek(fid, header + (size*Nsamples*2 + line_header)*(i-1) + size,-1);
    fseek(fid, line_header, 'cof');
    [Idata(:,i),count]=fread(fid, Nsamples, 'int16', size);
end
fclose(fid);  
       
end



