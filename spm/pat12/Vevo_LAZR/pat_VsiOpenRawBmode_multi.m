function [rawDataBmode, param] = pat_VsiOpenRawBmode_multi(fileName, varargin)
% Modified from VsiOpenRawPa.m. This version opens the file once, reads all
% available frames and closes it.
% SYNTAX
% [rawDataBmode, param] = pat_VsiOpenRawBmode_multi(fileName, [framesVector])
% INPUTS
% fileName          Full file name with extension of raw.pamode file
% [framesVector]    Vector with frames to extract, if empty, extracts the whole
%                   file
% OUTPUTS
% rawDataBmode      4-D matrix with B-mode raw data, with the following dimensions:
%                   [nSamples(depth) nLines(width) 1 nFrames]
% param             Structure with relevant info in the extracted images
%_______________________________________________________________________________
% Copyright VisualSonics 1999-2012
% A. Needles
% Revision: 1.0 Oct 24 2012
%_______________________________________________________________________________

% only want 1 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 2
    error('pat12:pat_VsiOpenRawBmode_multi:TooManyInputs', ...
        'requires at most 2 optional input: framesVector');
end
% set defaults for optional inputs ()
optArgs = {Inf};
% skip any new inputs if they are empty
newVals = cellfun(@(x) ~isempty(x), varargin);
% now put these defaults into the optArgs cell array, and overwrite the ones
% specified in varargin.
optArgs(newVals) = varargin(newVals);

% Place optional args in memorable variable names
framesVector = optArgs{:};

% Set up file names
[pathString fnameBase ModeName] = fileparts(fileName);
fnameBase = fullfile(pathString, fnameBase);
% Remove '.3d' from base name
fnameBase = regexprep(fnameBase,'\.3d','');
fnameXml = [fnameBase '.xml'];

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the XML parameter file - DO NOT CHANGE
param               = VsiParseXml(fnameXml, ModeName);
BmodeNumSamples     = param.BmodeNumSamples;
BmodeNumLines       = param.BmodeNumLines;
BmodeDepthOffset    = param.BmodeDepthOffset;   % mm
BmodeDepth          = param.BmodeDepth;         % mm
BmodeWidth          = param.BmodeWidth;         % mm
param.pixDepth      = (BmodeDepth-BmodeDepthOffset)/(BmodeNumSamples-1);
param.DepthAxis     = BmodeDepthOffset:param.pixDepth:BmodeDepth;
param.pixWidth      = BmodeWidth/(BmodeNumLines-1);
param.WidthAxis     = 0:param.pixWidth:BmodeWidth;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to strip the header data in the files - DO NOT CHANGE
size            = 1;    % 1 byte
file_header     = 40;   % 40 bytes
line_header     = 0;    % 0 bytes
frame_header    = 56;   % 56 bytes  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Open file
fid = fopen(fileName, 'r');

%% Get total number of frames
fileInfo = dir(fileName);
fileSize = fileInfo.bytes;
% nFrames represents the total of B-mode frames.
nFrames = (fileSize - file_header) / (BmodeNumLines*(size*BmodeNumSamples + line_header) + frame_header);
if isinf(framesVector)
    framesVector = 1:nFrames;
end
% Initialize data
rawDataBmode = zeros(BmodeNumSamples, BmodeNumLines, 1, numel(framesVector));

%% Frames loop
% Initialize progress bar
spm_progress_bar('Init', nFrames, sprintf('Read %d frames from raw B-mode\n',nFrames), 'Frames');
pat_text_waitbar(0, sprintf('Read %d frames from raw B-mode file %s...\n', nFrames, fileName));
for iFrames = framesVector,
    % Update header for each frame
    header = file_header + frame_header*iFrames + (size*BmodeNumSamples*BmodeNumLines + BmodeNumLines*line_header)*(iFrames-1);
    % A-lines loop
    for iLines = 1:BmodeNumLines,
        fseek(fid, header + (size*BmodeNumSamples + line_header)*(iLines-1),-1);
        fseek(fid, line_header, 'cof');
        [rawDataBmode(:,iLines,1,iFrames), ~] = fread(fid, BmodeNumSamples, 'uchar');
    end
    % Update progress bar
    spm_progress_bar('Set', iFrames);
    pat_text_waitbar(iFrames/nFrames, sprintf('Processing frame %d from %d', iFrames, nFrames));
end
% Clear progress bar
spm_progress_bar('Clear');
pat_text_waitbar('Clear');
%% Close file
fclose(fid);
fprintf('%d frames extracted!\n',numel(framesVector));

% EOF
