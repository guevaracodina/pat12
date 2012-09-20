function [ROI mainHeader] = pat_import_csv(fileName)
% import CSV with ROI time-trace
% SYNTAX
% ROI = pat_import_csv(filename)
% INPUT
% fileName      Name of the exported .CSV file with ROIs time course
% OUTPUT
% ROI           Structure containing ROIs info and data.
% mainHeader    [Optional] cell array with the main header
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

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

% EOF
