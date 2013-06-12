function [PAT ROI varargout] = pat_extract_core(PAT, job, mask, Amask, varargin)
% ROI time course extraction over colors and files. Calls pat_extract_main
% Optional computation of standard deviation and standard error of mean 
% [ROIstd ROIsem].
% SYNTAX:
% [PAT ROI ROIstd ROIsem] = pat_extract_core(PAT, job, mask, Amask,dataType, ROIstd, ROIsem)
% INPUTS:
% PAT       Matrix with the PAT structure
% job       Matlab batch job structure
% mask      ROI/seed binary mask
% Amask     Activation mask
% [dataType]
%           'rawData'       - Default: extract ROIs/seeds raw data
%           'filtData'      - extract ROIs/seeds temporally BPF data
%           'regressData'   - extract ROIs/seeds GLM-regressed data
% [ROIstd]  Cell with ROIs/seeds standard deviation
% [ROIsem]  Cell with ROIs/seeds standard error of the mean
% OUTPUTS:
% PAT       Matrix with the PAT structure
% ROI       Cell with ROIs/seeds time traces
% [ROIstd]  Cell with ROIs/seeds standard deviation
% [ROIsem]  Cell with ROIs/seeds standard error of the mean
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 3 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 3
    error('pat12:pat_extract_core:TooManyInputs', ...
        'requires at most 2 optional inputs: dataType, ROIstd, ROIsem');
end
% set defaults for optional inputs ()
optArgs = {'rawData' cell(1) cell(1)};
% skip any new inputs if they are empty
newVals = cellfun(@(x) ~isempty(x), varargin);
% now put these defaults into the optArgs cell array, and overwrite the ones
% specified in varargin.
optArgs(newVals) = varargin(newVals);
% Place optional args in memorable variable names
[dataType ROIstd ROIsem] = optArgs{:};


[all_ROIs selected_ROIs] = pat_get_rois(job);
IC = job.IC;
% loop over sessions (in PAT only 1 session per scan)
s1 = 1;
% Loop over available colors
for c1 = 1:length(PAT.nifti_files)
    doColor = pat_doColor(PAT,c1,IC);
    if doColor
        colorOK = true;
        %skip B-mode only extract PA
        if ~(PAT.color.eng(c1)==PAT.color.Bmode)
            switch dataType
                case 'rawData'
                    % HbT/SO2 filenames (raw data)
                    fname_list = PAT.nifti_files(:,c1);
                case 'filtData'
                    % HbT/SO2 filenames (filtered data)
                    fname_list = PAT.fcPAT.filtNdown.fnameWholeImage(:,c1);
                case 'regressData'
                    % GLM regressed data
                    fname_list = PAT.fcPAT.SPM.fname(:,c1);
                otherwise
                    % HbT/SO2 filenames (raw data)
                    fname_list = PAT.nifti_files(:,c1);
            end
            % Color names
            colorNames = fieldnames(PAT.color);
            % number of ROIs is 1 if extracting brain mask signal
            if job.extractBrainMask && job.extractingBrainMask
                nROI = 1; % Only 1 brain mask
            else
                nROI = 1:length(PAT.res.ROI); % All the ROIs
            end
       
            % initialize ROI cell
            for r1 = nROI
                if all_ROIs || sum(r1==selected_ROIs)
                    ROI{r1}{s1,c1} = [];
                    if nargout >= 1
                        ROIstd{r1}{s1,c1} = [];
                    end
                    if nargout >= 2
                        ROIsem{r1}{s1,c1} = [];
                    end
                end
                % In case we are extracting brain mask
                if job.extractBrainMask && job.extractingBrainMask
                    ROI{r1}{s1,c1} = [];
                    if nargout >= 1
                        ROIstd{r1}{s1,c1} = [];
                    end
                    if nargout >= 2
                        ROIsem{r1}{s1,c1} = [];
                    end
                end
            end

            % loop over files
            for f1 = 1:length(fname_list)
                try
                    fname = fname_list{f1};
                    vols = spm_vol(fname);
                    d = spm_read_vols(vols);
                    [d1 d2 d3 d4] = size(d);
                    if d1 <= 1 || d2 <= 1
                        colorOK = false;
                    end
                catch
                    colorOK = false;
                end
                % pat_extract_main loops over ROIs
                [PAT ROI ROIstd ROIsem] = pat_extract_main(PAT,ROI,job,d,d3,d4,c1,s1,colorOK,mask,Amask,ROIstd,ROIsem);
            end % Loop over files
            if colorOK
                if job.extractBrainMask && job.extractingBrainMask
                    fprintf('Global brain signal extraction for color %d (%s) completed\n',c1,colorNames{1+c1})
                else
                    fprintf('ROI/seed extraction for color %d (%s) completed\n',c1,colorNames{1+c1})
                end
            end
        end % Skip B-mode
    end
end % Loop over colors

% Assign optional outputs
if nargout >= 1
    varargout{1} = ROIstd;
end
if nargout >= 2
    varargout{2} = ROIsem;
end

% EOF
