function out = pat_plot_roi_run(job)
% Plots the time course of regions of interest.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------

% Initialize variables
tVec            = [];
filtNdownROI    = [];
ROIsem          = [];
ROIstd          = [];
filtNdownBrain  = [];
brainMaskSem    = [];
brainMaskStd    = [];
ROIregress      = [];
ROIregressSem   = [];
ROIregressStd   = [];
for scanIdx = 1:length(job.PATmat)
    try
        tic
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        % Load computed seeds time courses
        if isfield(PAT.jobsdone, 'seriesOK')
            % {nROI}{1 x nColors}
            load(PAT.ROI.ROIfname);
            tVec = 0:numel(ROI{1}{1,1})-1;
        end
        % Load computed brain signal time course
        if isfield(PAT.jobsdone, 'maskSeriesOK')
            load(PAT.fcPAT.mask.fnameSeries);
        end
        % Load computed seeds filtered time courses
        if isfield(PAT.jobsdone, 'filtNdownOK')
            load(PAT.fcPAT.filtNdown.fname);
            tVec = (0:numel(filtNdownBrain{1}{1})-1)*PAT.fcPAT.filtNdown.TR;
        end
        % Load computed seeds regressed time courses
        if isfield(PAT.jobsdone, 'GLMOK')
            load(PAT.fcPAT.SPM.fnameROIregress);
            tVec = (0:numel(filtNdownBrain{1}{1})-1)*PAT.fcPAT.filtNdown.TR;
        end
        %% Plot raw ROIs
        subfunction_plot_seeds(tVec, ROI, ROIsem, ROIstd, brainMaskSeries, brainMaskSem, brainMaskStd, job, PAT, scanIdx)
        %% Plot filtered series
        subfunction_plot_filtered_seeds(tVec, filtNdownROI, ROIsem, ROIstd, filtNdownBrain, brainMaskSem, brainMaskStd, job, PAT, scanIdx)
        %% Plot global brain signal regressed signals.
        subfunction_plot_GLM_seeds(tVec, ROIregress, ROIregressSem, ROIregressStd, job, PAT, scanIdx);
        %% Display ROIs and brain mask over anatomical image
        subfunction_display_seeds;
        % TO DO...
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        fprintf('Scan %s, %d of %d complete %30s\n', splitStr{end-1}, scanIdx, length(job.PATmat), spm('time'));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
    end
end % loop over scans
end % pat_plot_roi_run

function subfunction_plot_seeds(tVec, ROI, ROIsem, ROIstd, brainMaskSeries, brainMaskSem, brainMaskStd, job, PAT, scanIdx)
% Plot raw ROIs
% ROI selection
[all_ROIs selected_ROIs] = pat_get_rois(job);
nROI = 1:length(PAT.res.ROI); % All the ROIs
if job.generate_figures
    colorNames = fieldnames(PAT.color);
    % Loop over colors
    for c1 = 1:length(PAT.nifti_files)
        doColor = pat_doColor(PAT,c1,job.IC);
        if doColor
            % --------------------- Plot options -------------------------------
            h = figure; set(gcf,'color','w');
            % Specify window units
            set(h, 'units', 'inches')
            % Change figure and paper size
            set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
            set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
            % ------------------------------------------------------------------
            legendCell = {};
            % Loop over ROIs/seeds
            for r1 = nROI,
                if all_ROIs || sum(r1==selected_ROIs)
                    if isfield(PAT.jobsdone, 'seriesOK')
                        % Plot raw ROIs
                        hold on
                        if job.stderror
                            e = ROIsem{r1}{1,c1};
                        else
                            e = ROIstd{r1}{1,c1};
                        end
                        h1 = errorbar(tVec, ROI{r1}{1,c1}, e, strcat(job.figColors{r1}, job.figLS{r1}));
                        % Change linwidth for signal only, not error
                        hChild = get(h1, 'Children');
                        set(hChild(1), 'LineWidth', job.figLW);
                    end
                    legendCell = cat(1,legendCell,PAT.ROI.ROIname{r1});
                end
            end % ROIS loop
            if isfield(PAT.jobsdone, 'maskSeriesOK') && job.extractBrainMask
                if job.stderror
                    e = brainMaskSem{1}{1,c1};
                else
                    e = brainMaskStd{1}{1,c1};
                end
                % Plot raw brain mask signal
                h1 = errorbar(tVec, brainMaskSeries{1}{1,c1}, e, strcat(job.figColors{r1+1}, job.figLS{r1+1}));
                % Change linwidth for signal only, not error
                hChild = get(h1, 'Children');
                set(hChild(1), 'LineWidth', job.figLW);
                legendCell = cat(1,legendCell,'Global Brain Signal');
            end
            axis tight;
            if isfield(job.yLimits, 'yLimManual')
                set(gca, 'ylim', job.yLimits.yLimManual.yLimValue)
            end
            set(gca, 'FontSize', job.axisFontSize)
            if isfield(job.legends, 'legendShow')
                legend(legendCell, 'FontSize', job.legends.legendShow.legendFontSize, 'Location', job.legends.legendShow.legendLocation);
            end
            title(sprintf('%s', colorNames{c1+1}), 'interpreter', 'none', 'FontSize', job.titleFontSize);
            xlabel('t [s]', 'FontSize', job.axisLabelFontSize)
            ylabel(sprintf('%s [a.u.]', colorNames{c1+1}), 'FontSize', job.axisLabelFontSize)
            % Save figures
            pat_save_figs(job, h, 'plotROI', scanIdx, c1);
        end
    end % Colors loop
end % generate figures
end % subfunction_plot_seeds

function subfunction_plot_filtered_seeds(tVec, filtNdownROI, ROIsem, ROIstd, filtNdownBrain, brainMaskSem, brainMaskStd, job, PAT, scanIdx)
% Plot filtered series
% ROI selection
[all_ROIs selected_ROIs] = pat_get_rois(job);
nROI = 1:length(PAT.res.ROI); % All the ROIs
if job.generate_figures && job.plotfiltNdown
    colorNames = fieldnames(PAT.color);
    % Loop over colors
    for c1 = 1:length(PAT.nifti_files)
        doColor = pat_doColor(PAT,c1,job.IC);
        if doColor
            % --------------------- Plot options -------------------------------
            h = figure; set(gcf,'color','w');
            % Specify window units
            set(h, 'units', 'inches')
            % Change figure and paper size
            set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
            set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
            % ------------------------------------------------------------------
            legendCell = {};
            % Loop over ROIs/seeds
            for r1 = nROI,
                if all_ROIs || sum(r1==selected_ROIs)
                    if isfield(PAT.jobsdone, 'filtNdownOK')
                        if job.stderror
                            e = ROIsem{r1}{1,c1};
                        else
                            e = ROIstd{r1}{1,c1};
                        end
                        % Plot filtered ROIs
                        hold on
                        h1 = errorbar(tVec, filtNdownROI{r1}{1,c1}, e, strcat(job.figColors{r1}, job.figLS{r1}));
                        % Change linwidth for signal only, not error
                        hChild = get(h1, 'Children');
                        set(hChild(1), 'LineWidth', job.figLW);
                    end
                    legendCell = cat(1,legendCell,PAT.ROI.ROIname{r1});
                end
            end % ROIS loop
            if isfield(PAT.jobsdone, 'maskSeriesOK') && isfield(PAT.jobsdone, 'filtNdownOK') && job.extractBrainMask
                if job.stderror
                    e = brainMaskSem{1}{1,c1};
                else
                    e = brainMaskStd{1}{1,c1};
                end
                % Plot filtered brain mask signal
                h1 = errorbar(tVec, filtNdownBrain{1}{1,c1}, e, strcat(job.figColors{r1+1}, job.figLS{r1+1}));
                % Change linwidth for signal only, not error
                hChild = get(h1, 'Children');
                set(hChild(1), 'LineWidth', job.figLW);
                legendCell = cat(1,legendCell,'Global Brain Signal');
            end
            axis tight;
            if isfield(job.yLimits, 'yLimManual')
                set(gca, 'ylim', job.yLimits.yLimManual.yLimValue)
            end
            set(gca, 'FontSize', job.axisFontSize)
            if isfield(job.legends, 'legendShow')
                legend(legendCell, 'FontSize', job.legends.legendShow.legendFontSize, 'Location', job.legends.legendShow.legendLocation);
            end
            title(sprintf('%s [%0.3f-%0.3f] Hz',colorNames{c1+1}, PAT.fcPAT.filtNdown.BPFfreq), 'interpreter', 'none', 'FontSize', job.titleFontSize);
            xlabel('t [s]', 'FontSize', job.axisLabelFontSize)
            ylabel(sprintf('%s [a.u.]', colorNames{c1+1}), 'FontSize', job.axisLabelFontSize)
            % Save figures
            pat_save_figs(job, h, 'plotROIfilt', scanIdx, c1);
        end
    end % Colors loop
end % generate figures
end % subfunction_plot_filtered_seeds

function subfunction_plot_GLM_seeds(tVec, ROIregress, ROIregressSem, ROIregressStd, job, PAT, scanIdx)
% Plot GLM-regressed series
% ROI selection
[all_ROIs selected_ROIs] = pat_get_rois(job);
nROI = 1:length(PAT.res.ROI); % All the ROIs
if job.generate_figures && job.plotGLM
    colorNames = fieldnames(PAT.color);
    % Loop over colors
    for c1 = 1:length(PAT.nifti_files)
        doColor = pat_doColor(PAT,c1,job.IC);
        if doColor
            % --------------------- Plot options -------------------------------
            h = figure; set(gcf,'color','w');
            % Specify window units
            set(h, 'units', 'inches')
            % Change figure and paper size
            set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
            set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
            % ------------------------------------------------------------------
            legendCell = {};
            % Loop over ROIs/seeds
            for r1 = nROI,
                if all_ROIs || sum(r1==selected_ROIs)
                    if isfield(PAT.jobsdone, 'filtNdownOK') && isfield(PAT.fcPAT.SPM, 'ROIregressOK')
                        if r1 <= numel(PAT.fcPAT.SPM.ROIregressOK),
                            if PAT.fcPAT.SPM.ROIregressOK{r1}{1, c1}
                                if job.stderror
                                    e = ROIregressSem{r1}{1,c1};
                                else
                                    e = ROIregressStd{r1}{1,c1};
                                end
                                % Plot filtered ROIs
                                hold on
                                h1 = errorbar(tVec, ROIregress{r1}{1,c1}, e, strcat(job.figColors{r1}, job.figLS{r1}));
                                % Change linwidth for signal only, not error
                                hChild = get(h1, 'Children');
                                set(hChild(1), 'LineWidth', job.figLW);
                                legendCell = cat(1,legendCell,PAT.ROI.ROIname{r1});
                            else
                                fprintf('No regressed data for ROI %d (%s)\n',r1,colorNames{c1+1})
                            end
                        else
                            fprintf('No regressed data for ROI %d (%s)\n',r1,colorNames{c1+1})
                        end
                    else
                        fprintf('ROI regression not found (%s)!\n',colorNames{c1+1})
                    end
                end
            end % ROIS loop             
            axis tight;
            if isfield(job.yLimits, 'yLimManual')
                set(gca, 'ylim', job.yLimits.yLimManual.yLimValue)
            end
            set(gca, 'FontSize', job.axisFontSize)
            if isfield(job.legends, 'legendShow')
                legend(legendCell, 'FontSize', job.legends.legendShow.legendFontSize, 'Location', job.legends.legendShow.legendLocation);
            end
            title(sprintf('%s global signal regressed',colorNames{c1+1}), 'interpreter', 'none', 'FontSize', job.titleFontSize);
            xlabel('t [s]', 'FontSize', job.axisLabelFontSize)
            ylabel(sprintf('%s [a.u.]', colorNames{c1+1}), 'FontSize', job.axisLabelFontSize)
            % Save figures
            pat_save_figs(job, h, 'plotROIregress', scanIdx, c1);
        end
    end % Colors loop
end % generate figures
end % subfunction_plot_GLM_seeds

function subfunction_display_seeds
% Display ROIS as colored blobs on anatomical image with brain mask
fprintf('Display ROIs and brain mask over anatomical image: Work in progress...\nEGC\n')
end % subfunction_display_seeds

% EOF
