function [ROI mainHeader] = pat_import_csv(fileName, varargin)
% Import CSV with predefined ROI time-trace in PA mode. The CSV file was
% exported from Vevo LAZR photo-acoustic system.
% SYNTAX
% [ROI mainHeader] = pat_import_csv(fileName)
% INPUTS
% fileName      Name of the exported .CSV file with predefined ROIs time trace.
% saveMatFile   OPTIONAL: If true, saves outputs to a .mat file.
% OUTPUTS
% ROI           Structure containing the following fileds for each ROI:
%               name:   Original name from Vevo LAZR system
%               header: Describes every column of data
%               data:   Usually 6 columns with ROI time trace
%               lambda: 2-element vector with wavelengths used.
% mainHeader    [Optional] cell array with the main header (one line per cell)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 1
    error('pat12:pat_import_csv:TooManyInputs', ...
        'requires at most 1 optional input: saveMatFile');
end

% set defaults for optional inputs ()
optArgs = {true};

% now put these defaults into the optArgs cell array,
% and overwrite the ones specified in varargin.
optArgs(1:numVarArgs) = varargin;
% or ...
% [optargs{1:numvarargs}] = varargin{:};

% Place optional args in memorable variable names
saveMatFile = optArgs{:};

%% Open .CSV file as a text string
fid = fopen(fileName);
stringOut = textscan(fid,'%s','Delimiter', '\n');
fclose(fid);

%% Find beginning of every ROI time-trace
idxROI = false(size(stringOut{1}));
for iLines = 1:size(stringOut{1},1),
    if ~isempty(regexpi(stringOut{1}{iLines},'^(PA\sRegion)'))
        idxROI(iLines) = true;
    end
end
% Get main header
mainHeader = stringOut{1}(1:find(idxROI,true,'first')-1);
% Keep only the indices marking the beginning of ROI data
idxROI = find(idxROI);
idxROI(end+1) = size(stringOut{1},1);
% Find number of ROIs
nROI = numel(find(idxROI))-1;
% Preallocate data
cellROI = cell(nROI,1);

%% Find PA ROI time trace data
for iROI = 1:nROI,
    % Extract relevant data from whole string
    cellROI{iROI} = stringOut{1}(idxROI(iROI):idxROI(iROI+1)-1);
    iData = 1;
    % Check every line
    for iLines = 1:size(cellROI{iROI},1)
        % Do nothing if current line is empty
        if ~isempty(cellROI{iROI}{iLines})
            % Find lines that begin with PA Region
            if ~isempty(regexpi(cellROI{iROI}{iLines},'^(PA\sRegion)'))
                % Assign ROI name
                ROI(iROI).name = cellROI{iROI}{iLines};
                % Find lines that begin with "Frame Number"
            elseif ~isempty(regexpi(cellROI{iROI}{iLines},'^("Frame Number")'));
                % Split line in different columns
                cellHeader = regexpi(cellROI{iROI}{iLines},'","', 'split');
                for iCols = 1:size(cellHeader,2)
                    % Strip header from " and ",
                    cellHeader{iCols} = regexprep(cellHeader{iCols},'^"','');
                    cellHeader{iCols} = regexprep(cellHeader{iCols},'(",)$','');
                end % columns loop
                % Assign header
                ROI(iROI).header = cellHeader;
            else
                % Get frame data
                cellHeader = regexpi(cellROI{iROI}{iLines},'","', 'split');
                for iCols = 1:size(cellHeader,2)
                    % Strip header from " and ",
                    cellHeader{iCols} = regexprep(cellHeader{iCols},'^"','');
                    cellHeader{iCols} = regexprep(cellHeader{iCols},'(",)$','');
                    if isempty(regexpi(cellHeader{iCols},'/'))
                        % Convert frame data to double
                        ROI(iROI).data(iData, iCols) = str2double(cellHeader{iCols});
                    else
                        % Leave a zero, but retrieve wavelengths
                        ROI(iROI).lambda = str2double(regexpi(cellHeader{iCols},'/','split'));
                    end
                end % columns loop
                % Increment row counter for current ROI data
                iData = iData+1;
            end
        end
    end % lines loop
end % ROI loop

if saveMatFile
    [pathName, fileName, fileExt] = fileparts(fileName);
    save(fullfile(pathName, [fileName '.mat']), 'ROI', 'mainHeader')
    fprintf('ROI data saved to %s\n', fullfile(pathName, [fileName '.mat']));
end

% EOF
