function [BMode] = VsiReadBModeRaw(baseFolder, baseFilename, iFrame, modeName, varargin)
% A function to read in B-Mode raw data.
%
% Input:
%   baseFolder = Folder containing the data
%   baseFilename = Filename containing the data (extensions not required)
%   iFrame = A vector specifying the desired frames, -1 to load all frames
%   modeName = Mode name, '.bmode' and '.3d.bmode' are valid
%   varargin = Extra parameters
%       'TimestampOnly' = Can be set to true or false. Default false
%
% Output:
%   BMode = Structure containing fields
%     BMode.FrameNum = Vector of frame number 
%     BMode.Timestamp = Vector of the timestamps for each frame
%     BMode.Data = Cell containing the data 
%     BMode.Width = Vector for the width axis
%     BMode.Depth = Vector for the depth axis

BMode = struct('FrameNum', [], 'Data', {}, 'Width', [], 'Depth', [], 'Timestamp', []);

try
  paramList = {
    'TimestampOnly', @islogical, false };
  parsedResults = VsiParseVarargin(paramList, varargin{:});

  timestampOnly = parsedResults.TimestampOnly;
  
  fname  = [baseFolder '/' baseFilename '.raw' modeName];
  fnameXml = [baseFilename '.raw.xml'];
  
  if (~exist(fname, 'file'))
    error('File (%s) not found', fname);
  end
   
  if (~exist([baseFolder '/' fnameXml], 'file'))
    error('File (%s) not found', [baseFolder '/' fnameXml]);
  end

  % Read xml file
  param = VsiParseXml(baseFolder, fnameXml, '.bmode');

  % Open file
  fid = fopen(fname,'r');
  if (-1 == fid)
    error('Failed to open %s', fname);
  end
  
  retVal = fseek(fid, 4, 'bof');
  if (-1 == retVal)
    error('Failed to read file %s', fname);
  end
  
  numFrames = fread(fid, 1, 'uint32');
  if (~(any(iFrame == -1) || (all(iFrame >= 1) && all(iFrame <= numFrames))))
    str = ['Invalid frame number(s): ' ...
      num2str(iFrame(~(iFrame >= 1 & iFrame <= numFrames)))];
    error('Invalid frame number(s) (%s)', str);
  end
  
  if (any(iFrame == -1))
    if (length(iFrame) > 1)
      warning('Frame list includes -1. Loading all data.');
    end
    frameList = 1:numFrames;
  else
    frameList = iFrame;
  end
  
  % Get short variable names
  numSamples = param.BmodeNumSamples;
  numLines = param.BmodeNumLines;
  depthOffset = param.BmodeDepthOffset; %Units: mm
  depth = param.BmodeDepth;   %Units: mm
  width = param.BmodeWidth;   %Units: mm
  center = param.BmodeCentre; %Units: mm
  
  % Get file header and datatype size
  dataByteSize = 1; % Bytes
  file_header = 40; % Bytes
  line_header = 0;  % Bytes
  frame_header = 56; % Bytes
  
  numFramesToRead = length(frameList);
  BMode(1).FrameNum = zeros(1, numFramesToRead);
  BMode(1).Timestamp = zeros(1, numFramesToRead);
  
  if (~timestampOnly)
    BMode(1).Depth = [depthOffset:(depth-depthOffset)/(numSamples-1):depth]; %#ok<NBRAK>
    BMode(1).Width = [0:width/(numLines-1):width] - width/2 + center; %#ok<NBRAK>
    BMode(1).Data = cell(1, numFramesToRead);
  end
  
  % Read specified frames
  for j = 1:numFramesToRead    
    BMode.FrameNum(j) = frameList(j);
    
    header = file_header + frame_header*frameList(j) + ...
      (dataByteSize*numSamples*numLines + numLines*line_header)*(frameList(j)-1);
    
    fseek(fid, header - frame_header + 4, 'bof');
    BMode.Timestamp(j) = fread(fid, 1, 'double');
    
    if (~timestampOnly)
      fseek(fid, header ,'bof');
      [BMode.Data{j}(:,:)] = ...
        reshape(fread(fid, numSamples * numLines, 'uchar', line_header), ...
        [numSamples, numLines]);
    end
  end
  
  fclose(fid);
catch err
  if (exist('fid','var') && -1 ~= fid)
    fclose(fid);
  end
  
  rethrow(err);
end

end

