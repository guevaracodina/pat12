function [rawDataBmode, param] = pat_VsiOpenRawBmode_multi(fileName, varargin)
% Modified from VsiOpenRawPa.m. This version opens the file once, reads all
% available frames and closes it.
% SYNTAX
% [rawDataSO2, rawDataHbT,  param] = pat_VsiOpenRawPa_multi(fileName, [framesVector])
% INPUTS
% fileName          Full file name with extension of raw.pamode file
% [framesVector]    Vector with frames to extract, if empty, extracts the whole
%                   file
% OUTPUTS
% rawDataSO2        4-D matrix with SO2 raw data, with the following dimensions:
%                   [nSamples(depth) nLines(width) 1 nFrames]
% rawDataHbT        4-D matrix with HbT raw data, same dimensions as rawDataSO2
% param             Structure with relevant info in the extracted images
%_______________________________________________________________________
% Copyright VisualSonics 1999-2010
% A. Needles
% Revision: 1.0 Dec 3 2010
%_______________________________________________________________________

% only want 1 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 2
    error('pat_VsiOpenRawBmode_multi:TooManyInputs', ...
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
fnameXml = [fnameBase '.xml'];

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXml(fnameXml, ModeName);
BmodeNumSamples = param.BmodeNumSamples;
BmodeNumLines = param.BmodeNumLines;
BmodeDepthOffset = param.BmodeDepthOffset; % mm
BmodeDepth = param.BmodeDepth; % mm
BmodeWidth = param.BmodeWidth; % mm
param.pixDepth = (BmodeDepth-BmodeDepthOffset)/(BmodeNumSamples-1);
param.DepthAxis = BmodeDepthOffset:param.pixDepth:BmodeDepth;
param.pixWidth = BmodeWidth/(BmodeNumLines-1);
param.WidthAxis = 0:param.pixWidth:BmodeWidth;

rawDataBmode = [];

%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % This is to strip the header data in the files - DO NOT CHANGE
% size            = 2;    % 2 bytes
% file_header     = 40;   % 40bytes
% line_header     = 0;    % 0 bytes
% frame_header    = 56;   % 56 bytes  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Open file
% fid = fopen(fileName, 'r');
% 
% %% Get total number of frames
% fileInfo = dir(fileName);
% fileSize = fileInfo.bytes;
% % nFrames represents the total of frames SO2 & HbT
% nFrames = (fileSize - file_header) ./ (BmodeNumLines.*(size.*BmodeNumSamples + line_header) + frame_header./2);
% if isinf(framesVector)
%     framesVector = 1:nFrames;
% end
% % Initialize data
% Rawdata = zeros(BmodeNumSamples, BmodeNumLines, 1, numel(framesVector));
% 
% %% Frames loop
% fprintf('Reading %d frames from file %s...\n',numel(framesVector)/2, fileName);
% for iFrames = framesVector
%     % Updated by A. Needles Oct 2, 2012 for opening Oxy-Hemo raw file
%     if mod(iFrames,2) == 1
%         TempFrame = (iFrames+1)/2;
%     else
%         TempFrame = iFrames/2;
%     end
%     
%     header = file_header + frame_header*TempFrame + (size*BmodeNumSamples*BmodeNumLines + BmodeNumLines*line_header)*(iFrames-1);
%     
%     % A-lines loop
%     for iLines = 1:BmodeNumLines
%         fseek(fid, header + (size*BmodeNumSamples + line_header)*(iLines-1),-1);
%         fseek(fid, line_header, 'cof');
%         [Rawdata(:,iLines,1,iFrames), ~] = fread(fid, BmodeNumSamples, 'ushort');
%     end
% end
% rawDataSO2 = Rawdata(:,:,1,1:2:end);
% rawDataHbT = Rawdata(:,:,1,2:2:end);
% 
% %% Close file
% fclose(fid);
% fprintf('%d frames extracted!\n',numel(framesVector)/2);

% EOF
