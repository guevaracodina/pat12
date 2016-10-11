function [ReturnParam] = VsiParseXml(baseFolder, baseFilename, modeName)
% A function to parse the xml parameter files exported from the Vevo 2100
% and read selected parameters.
%
% Input:
%   baseFolder = Folder containing the data
%   baseFilename = Filename of the xml file (extension required)
%   modeName = Mode name to get the correct list of parameters. Valid
%       values: {'.bmode', '.3d.bmode', '.color', '.3d.color', '.pw',
%       '.3d.pw', '.pamode', '.3d.pamode'
%
% Output:
%   ReturnParam = A structure containing the fields related to the
%       requested mode. Structure fields names depends on the mode.

ReturnParam = [];

try
  filename = [baseFolder '/' baseFilename];
  
  if (~exist(filename, 'file'))
    error('File (%s) not found', filename);
  end
  
  % paramList represents the nodes to read from the xml.
  %   Column 1: Node name
  %   Column 2: Structure name for the return parameter
  %   Column 3: Type of data ('double' or 'char')
  switch (modeName)
    case {'.bmode', '.3d.bmode'}
      paramList = {
        'B-Mode/Samples',       'BmodeNumSamples',  'double';
        'B-Mode/Lines',         'BmodeNumLines',    'double';
        'B-Mode/Depth-Offset',  'BmodeDepthOffset', 'double';
        'B-Mode/Depth',         'BmodeDepth',       'double';
        'B-Mode/Width',         'BmodeWidth',       'double';
        'B-Mode/Centre',        'BmodeCentre',      'double';
        'B-Mode/RX-Frequency',  'BmodeRxFrequency', 'double';
        'B-Mode/TX-Frequency',  'BmodeTxFrequency', 'double';
        'B-Mode/Quad-2X',       'BmodeQuad2x',      'char';
        'B-Mode/Focal-Zones-Count', 'BmodeNumFocalZones', 'double'};
    case {'.color', '.3d.color'}
      paramList = {
        'Color-Mode/Samples',       'ColorNumSamples',  'double';
        'Color-Mode/Lines',         'ColorNumLines',    'double';
        'Color-Mode/Depth-Offset',  'ColorDepthOffset', 'double';
        'Color-Mode/TX-Frequency',  'ColorTxFrequency', 'double';
        'Color-Mode/RX-Frequency',  'ColorRxFrequency', 'double';
        'Color-Mode/Ensemble-n',    'ColorNumEnsemble', 'double';
        'Color-Mode/Ensemble-Extra',    'ColorEnsembleExtra', 'double';
        'Color-Mode/Lines-Extra-Blank', 'ColorLinesExtra',    'double';
        'Color-Mode/Steering-Angle',    'ColorSteeringAngle', 'double';
        'B-Mode/Samples',           'BmodeNumSamples',  'double';
        'B-Mode/Lines',             'BmodeNumLines',    'double';
        'B-Mode/Depth-Offset',      'BmodeDepthOffset', 'double';
        'B-Mode/Depth',             'BmodeDepth',       'double';
        'B-Mode/Width',             'BmodeWidth',       'double'};
    case {'.pw'}
      paramList = {
        'Pw-Mode/Samples',          'PwNsamples',       'double';
        'Pw-Mode/TX-Frequency',     'PwTxFrequency',    'double';
        'Pw-Mode/RX-Frequency',     'PwRxFrequency',    'double';
        'Pw-Mode/Steering-Angle',   'PwSteeringAngle',  'double';
        'Pw-Mode/TX-PRF',           'PwTxPrf',          'double';
        'Pw-Mode/Spectral-Size',    'PwSpectralSize',   'double';
        'Pw-Mode/Spectral-Spacing', 'PwSpectralSpacing', 'double';
        'Pw-Mode/Display-Gain',     'PwDisplayGain',    'double';
        'Pw-Mode/Display-Range',    'PwDisplayRange',   'double';
        'Pw-Mode/Y-Offset',         'PwYOffset',        'double';
        'Pw-Mode/V-Offset',         'PwVOffset',        'double'};
    case {'.pamode', '.3d.pamode'}
      paramList = {
        'Pa-Mode/Samples',      'PaNumSamples',     'double';
        'Pa-Mode/Lines',        'PaNumLines',       'double';
        'Pa-Mode/Depth-Offset', 'PaDepthOffset',    'double';
        'Pa-Mode/Depth',        'PaDepth',          'double';
        'Pa-Mode/Width',        'PaWidth',          'double';
        'Pa-Mode/Centre',       'PaCentre',         'double';
        'B-Mode/Samples',       'BmodeNumSamples',  'double';
        'B-Mode/Lines',         'BmodeNumLines',    'double';
        'B-Mode/Depth-Offset',  'BmodeDepthOffset', 'double';
        'B-Mode/Depth',         'BmodeDepth',       'double';
        'B-Mode/Width',         'BmodeWidth',       'double';
        'B-Mode/RX-Frequency',  'BmodeRxFrequency', 'double'};
    otherwise
      error('Mode (%s) not supported', modeName);
  end
  
  if (isempty(paramList))
    error('Parameter list is empty')
  end
  
  iCount = 0;
  
  xDoc = xmlread(filename);
  AllParameters = xDoc.getElementsByTagName('parameter');
  for i = 0:AllParameters.getLength-1
    node = AllParameters.item(i);
    for j = 1:size(paramList,1)
      if (strcmp(char(node.getAttribute('name')), paramList(j, 1)))
        switch (paramList{j,3})
          case 'double'
            javaTmp = node.getAttribute('value');
            ReturnParam.(paramList{j,2}) = str2double(javaTmp);
          case 'char'
            javaTmp = node.getAttribute('value');
            ReturnParam.(paramList{j,2}) = char(javaTmp);
          otherwise
            warning('Unhandled conversion to %s', paramList{j,3});
        end
        
        iCount = iCount + 1;
        break;
      end
    end
  end
  
  if (iCount ~= size(paramList,1))
    error('Number of specified and recorded parameters not equal')
  end
  
catch err
  rethrow(err)
end

end
