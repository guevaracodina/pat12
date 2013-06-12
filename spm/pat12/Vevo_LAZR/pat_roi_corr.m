function [corrMatrix corrMatrixDiff corrMatrixFname corrMatrixDiffFname] = pat_roi_corr(job,scanIdx)
% Gets the correlation matrix for every seed/ROI time trace.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Load PAT.mat information
[PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);

if ~isfield(PAT.jobsdone, 'GLMOK') % GLM OK
    disp(['No GLM regression available for subject ' int2str(scanIdx) ' ... skipping seed to seed correlation matrix']);
    corrMatrix          = [];
    corrMatrixDiff      = [];
    corrMatrixFname     = [];
    corrMatrixDiffFname = [];
else
    % Get colors to include information
    IC = job.IC;
    colorNames = fieldnames(PAT.color);
    % Get ROI info
    [all_ROIs selected_ROIs] = pat_get_rois(job);
    nROI = 1:length(PAT.res.ROI); % All the ROIs
    
    % Load regressed ROI data in cell ROIregress
    load(PAT.fcPAT.SPM.fnameROIregress)
    
    % Loop over sessions (in PAT always 1 session per scan)
    s1=1;
    % Loop over available colors
    for c1=1:length(PAT.nifti_files)
        doColor = pat_doColor(PAT,c1,IC);
        if doColor
            % Loop over ROI/seeds, just to preallocate the time vector
            for r1 = nROI,
                if ~isempty(PAT.fcPAT.SPM.ROIregressOK{r1})
                    if PAT.fcPAT.SPM.ROIregressOK{r1}{s1,c1}
                        if job.scrubbing && isfield(PAT.jobsdone, 'scrubOK')
                            % load scrubbing parameters
                            load(PAT.motion_parameters.scrub.fname)
                            % Get only valid frames after scrubbing
                            ROIregress{r1}{s1,c1} = ROIregress{r1}{s1,c1}(scrubMask{c1});
                        end
                        % Preallocate map for the seed-to-seed correlation matrix
                        tVector = numel(ROIregress{r1}{s1,c1});
                        if isfield (job,'derivative')
                            tVectorDiff = numel(ROIregress{r1}{s1,c1})-1;
                        end
                        % fprintf('time vector size found for seed
                        % %d\n',r1);
                        roiOK = true;
                        break; % end loop for as soon as a good ROI is found
                    else
                        roiOK = false;
                        fprintf('time vector size NOT found for seed %d, session %d, (%s)!\n',r1,s1,colorNames{1+c1});
                    end
                else
                    roiOK = false;
                    fprintf('Empty seed %d, session %d, (%s)!\n',r1,s1,colorNames{1+c1});
                end
            end
            if roiOK
                % Preallocate
                roiMatrix = zeros([tVector numel(nROI)]);
                if isfield (job,'derivative')
                    roiMatrixDiff = zeros([tVectorDiff numel(nROI)]);
                end
                
                % Load again the original regressed ROI data in cell ROIregress
                load(PAT.fcPAT.SPM.fnameROIregress)
    
                % Loop over ROI/seeds
                for r1 = nROI,
                    if all_ROIs || sum(r1==selected_ROIs)
                        if PAT.fcPAT.SPM.ROIregressOK{r1}{s1,c1}
                            if job.scrubbing && isfield(PAT.jobsdone, 'scrubOK')
                                % load scrubbing parameters
                                load(PAT.motion_parameters.scrub.fname)
                                % Get only valid frames after scrubbing
                                ROIregress{r1}{s1,c1} = ROIregress{r1}{s1,c1}(scrubMask{c1});
                            end
                            roiMatrix(:, r1) = ROIregress{r1}{s1,c1};
                            if isfield (job,'derivative')
                                roiMatrixDiff(:, r1) = diff(ROIregress{r1}{s1,c1});
                            end
                        else
                            roiMatrix = [];
                            roiMatrixDiff = [];
                        end
                    end
                end % loop over sessions
                % Compute seed-to-seed correlation matrix
                corrMatrix{1}{s1,c1} = corrcoef(roiMatrix);
                if isfield (job,'derivative')
                    % Compute seed-to-seed correlation matrix of the derivative
                    corrMatrixDiff{1}{s1,c1} = corrcoef(roiMatrixDiff);
                end
                if PAT.fcPAT.SPM.ROIregressOK{r1}{s1,c1}
                    % Show correlation matrix
                    if job.generate_figures
                        h = figure; set(h,'color','w')
                        imagesc(corrMatrix{1}{s1,c1},[-1 1]); axis image; colorbar
                        set(gca,'FontSize',8)
                        colormap(get_colormaps('rwbdoppler'));
                        set(gca,'yTick',1:2:numel(PAT.res.ROI))
                        set(gca,'yTickLabel',PAT.ROI.ROIname(1:2:end),'FontSize',8)
                        set(gca,'xTick',1:2:numel(PAT.res.ROI))
                        set(gca,'xTickLabel',PAT.ROI.ROIname(1:2:end),'FontSize',8)
                        % Moves x-axis on top
                        set(gca,'xAxisLocation','top')
                        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
                        scanName = splitStr{end-1};
                        newName = sprintf('%s_S%d_C%d(%s)_s2sCorrMat',scanName,s1,c1,colorNames{1+c1});
                        title(newName,'interpreter','none','FontSize',8)
                        if job.save_figures
                            % Allow printing of black background
                            set(h, 'InvertHardcopy', 'off');
                            % Specify window units
                            set(h, 'units', 'inches')
                            % Change figure and paper size (fixed to 3x3 in)
                            set(h, 'Position', [0.1 0.1 3 3])
                            set(h, 'PaperPosition', [0.1 0.1 3 3])
                            % Save as EPS
                            spm_figure('Print', 'Graphics', fullfile(dir_patmat,newName));
                            % Save as PNG
                            print(h, '-dpng', fullfile(dir_patmat,newName), '-r300');
                            % Save as a figure
                            saveas(h, fullfile(dir_patmat,newName), 'fig');
                        end
                        close(h)
                        if isfield (job,'derivative')
                            h = figure; set(gcf,'color','w')
                            imagesc(corrMatrixDiff{1}{s1,c1},[-1 1]); axis image; colorbar
                            set(gca,'FontSize',8)
                            colormap(get_colormaps('rwbdoppler'));
                            set(gca,'yTick',1:2:numel(PAT.res.ROI))
                            set(gca,'yTickLabel',PAT.ROI.ROIname(1:2:end),'FontSize',8)
                            set(gca,'xTick',1:2:numel(PAT.res.ROI))
                            set(gca,'xTickLabel',PAT.ROI.ROIname(1:2:end),'FontSize',8)
                            % Moves x-axis on top
                            set(gca,'xAxisLocation','top','FontSize',8)
                            newName = sprintf('%s_S%d_C%d(%s)_s2sCorrMatDiff',scanName,s1,c1,colorNames{1+c1});
                            title(newName,'interpreter','none')
                            if job.save_figures
                                % Allow printing of black background
                                set(h, 'InvertHardcopy', 'off');
                                % Specify window units
                                set(h, 'units', 'inches')
                                % Change figure and paper size (fixed to 3x3 in)
                                set(h, 'Position', [0.1 0.1 3 3])
                                set(h, 'PaperPosition', [0.1 0.1 3 3])
                                % Save as EPS
                                spm_figure('Print', 'Graphics', fullfile(dir_patmat,newName));
                                % Save as PNG
                                print(h, '-dpng', fullfile(dir_patmat,newName), '-r300');
                                % Save as a figure
                                saveas(h, fullfile(dir_patmat,newName), 'fig');
                            end
                            close(h)
                        end
                    end
                else
                    % Do not plot (empty matrix)
                end
            else
                % No ROIs are correctly regressed
                corrMatrix{1}{s1,c1} = [];
                corrMatrixDiff{1}{s1,c1} = [];
            end
        end
    end % loop over colors
    
    corrMatrixFname = fullfile(dir_patmat,'s2sCorrMat.mat');
    corrMatrixDiffFname = fullfile(dir_patmat,'s2sCorrMatDiff.mat');
end % GLM regression ok

% EOF
