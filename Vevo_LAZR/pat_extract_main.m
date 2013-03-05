function [PAT ROI varargout] = pat_extract_main(PAT,ROI,job,d,d3,d4,c1,s1,colorOK,mask,Amask, varargin)
% The time course is made up of the means of all the pixel values in the
% ROI/seed. 
% Optional computation of standard deviation and standard error of mean 
% [ROIstd ROIsem]
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 2 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 2
    error('pat_extract_main:TooManyInputs', ...
        'requires at most 2 optional inputs: ROIstd, ROIsem');
end
% set defaults for optional inputs ()
optArgs = {cell(1) cell(1)};
% skip any new inputs if they are empty
newVals = cellfun(@(x) ~isempty(x), varargin);
% now put these defaults into the optArgs cell array, and overwrite the ones
% specified in varargin.
optArgs(newVals) = varargin(newVals);
% Place optional args in memorable variable names
[ROIstd ROIsem] = optArgs{:};

% Color names
colorNames = fieldnames(PAT.color);
[all_ROIs selected_ROIs] = pat_get_rois(job);
msg_ColorNotOK = true;
nROI = 1:length(PAT.res.ROI); % All the ROIs
if isfield(job,'extractingBrainMask')
    if job.extractingBrainMask
        nROI = 1; % Only 1 brain mask
    end
end
% If activation mask is chosen
if ~isempty(Amask)
    Amask = pat_imresize(Amask, size(mask{nROI(1)}));
    for r1 = nROI
        mask{r1} = logical(mask{r1} .* Amask);
    end
end
% Loop over ROIs/seeds
for r1 = nROI,
    if all_ROIs || sum(r1==selected_ROIs)
        tmp_mask_done = false;
        for i3=1:d3
            pat_text_waitbar(0, sprintf('Extracting ROI/seed %d of %d. Color %d (%s)',r1,numel(nROI),c1,colorNames{1+c1}));
            for i4=1:d4
                %extracted data
                try tmp_d = d(:,:,i3,i4); end
                %just take mean over mask for now
                try
                    meanVal = mean(tmp_d(mask{r1}));
                    % Standard deviation
                    if nargout >= 1
                        stdev = std(tmp_d(mask{r1}));
                    end
                    % Standard error of the mean
                    if nargout >= 2
                        sem = std(tmp_d(mask{r1})) / sqrt(numel(tmp_d(mask{r1})));
                    end
                catch
                    if msg_ColorNotOK
                        msg = ['Problem extracting for color ' int2str(c1) ', session ' int2str(s1) ...
                            ',region ' int2str(r1) ': size mask= ' int2str(size(mask{r1},1)) 'x' ...
                            int2str(size(mask{r1},2)) ', but size image= ' int2str(size(tmp_d,1)) 'x' ...
                            int2str(size(tmp_d,2))];
                        PAT = pat_disp_msg(PAT,msg);
                        msg_ColorNotOK = false;
                    end
                    if colorOK
                        try
                            %try to resize mask - but only attempt to do it once
                            if ~tmp_mask_done
                                % tmp_mask = imresize(mask{r1},size(tmp_d));
                                % pat_imresize works with no image
                                % processing toolbox //EGC
                                tmp_mask = pat_imresize(mask{r1},size(tmp_d));
                                tmp_mask_done = true;
                            end
                            meanVal = mean(tmp_d(tmp_mask));
                            if nargout >= 1
                                stdev = std(tmp_d(mask{r1}));
                            end
                            % Standard error of the mean
                            if nargout >= 2
                                sem = std(tmp_d(mask{r1})) / numel(tmp_d(mask{r1}));
                            end
                        catch
                            msg = ['Unable to extract color ' int2str(c1) ', session ' int2str(s1)];
                            PAT = pat_disp_msg(PAT,msg);
                            colorOK = false;
                        end
                    end
                end
                if colorOK
                    ROI{r1}{s1,c1} = [ROI{r1}{s1,c1} meanVal];
                    if nargout >= 1
                        ROIstd{r1}{s1,c1} = [ROIstd{r1}{s1,c1} stdev];
                    end
                    if nargout >= 2
                        ROIsem{r1}{s1,c1} = [ROIsem{r1}{s1,c1} sem];
                    end
                end
                % Update progress bar
                pat_text_waitbar(i4/d4, sprintf('Processing frame %d of %d', i4, d4));
            end % Loop along 4th dimension
            % Clear progress bar
            pat_text_waitbar('Clear');
        end % Loop along 3rd dimension
    end
end % Loop over ROIs/seeds

% Assign optional outputs
if nargout >= 1
    varargout{1} = ROIstd;
end
if nargout >= 2
    varargout{2} = ROIsem;
end

% EOF

