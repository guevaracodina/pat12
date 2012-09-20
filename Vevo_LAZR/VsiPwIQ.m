function [Idata,Qdata,param,numFrames_adjust] = VsiPwIQ(fnameBase, ModeName)
% A script to extract data from PW data in an IQ file
% Authors: G. Sundar
% Copyright VisualSonics 1999-2010
% Revision: 1.1 June 28 2010

% Set up file names
fname = [fnameBase '.pw'];
fnameXml = [fnameBase '.xml'];

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXml(fnameXml,ModeName);
Nsamples = param.PwNsamples; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to strip the header data in the files - DO NOT CHANGE
size = 4; % bytes
file_header = 40; % bytes
frame_header = 56; % bytes  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(fname,'r');

%read in number of frames from file header
frameinfo_position = 4;
fseek(fid,frameinfo_position,-1);
numFrames = fread(fid,1,'uint32');
totalSamples = numFrames*Nsamples;

% Initialize data
Idata = zeros(Nsamples, numFrames);
Qdata = zeros(Nsamples, numFrames);

i=1;
emptyFrames = 0;

while i <= numFrames    
    fseek(fid,file_header+frame_header*(i-1)+size*Nsamples*2*(i-1),-1);
    timeStamp = fread(fid,1,'uint32');
    if(timeStamp ~= 0)  %checking for empty frame
        header = file_header + frame_header*i + (size*Nsamples*2)*(i-1);
        fseek(fid, header,-1);
        [Idata(:,i),count]=fread(fid, Nsamples, 'int32', size);
        fseek(fid, header + size,-1);
        [Qdata(:,i),count]=fread(fid, Nsamples, 'int32', size);        
    else
        emptyFrames = emptyFrames+1;
    end
    i = i+1;
end

%generate new matrix of data after cutting out empty frames
numFrames_adjust = numFrames - emptyFrames;
Idata_new = zeros(Nsamples,numFrames_adjust);
Qdata_new = zeros(Nsamples,numFrames_adjust);
Idata_new = Idata(:,1:numFrames_adjust);
Qdata_new = Qdata(:,1:numFrames_adjust);

%transform matrix into a vector - concatenate data
totalSamples_adjust = Nsamples*numFrames_adjust;
Idata = reshape(Idata_new,1,totalSamples_adjust);
Qdata = reshape(Qdata_new,1,totalSamples_adjust);

fclose(fid);


