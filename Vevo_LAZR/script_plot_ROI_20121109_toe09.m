%% Script plot ROIs
%% Job options
job.figColors = {'r' 'b' 'g' 'k' 'm' 'y'};
job.figLS = {'-' '-' '-' '--' '--' '--'};
job.figLW = 1.5;
job.figSize = [6 2];
job.figRes = 300;
job.titleFontSize = 14;
job.axisLabelFontSize = 14;
job.axisFontSize = 12;

job.ROI_choice.select_ROIs.selected_ROIs = [1 2];

job.IC = struct();
job.IC(1).include_HbT = true;
job.IC(1).include_SO2 = true;
job.IC(1).include_Bmode = false;

job.generate_figures = true;
job.save_figures = true;
job.extractBrainMask = true;
job.plotfiltNdown = true;
job.legendShow = false;
job.PATmat = {'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\Bmode\BrainMask\ROI\LPF\ROItimeCourse\BPF\PAT.mat'};
% PAT copy/overwrite method
job.PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('plotROI');

%% Load PAT matrix and data
scanIdx = 1;
% Load PAT.mat information
[PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
if isfield(PAT.jobsdone, 'seriesOK')
    % {nROI}{1 x nColors}
    load(PAT.ROI.ROIfname);
end
if isfield(PAT.jobsdone, 'maskSeriesOK')
    load(PAT.fcPAT.mask.fnameSeries);
end
if isfield(PAT.jobsdone, 'filtNdownOK')
    load(PAT.fcPAT.filtNdown.fname);
    tVec = (0:numel(filtNdownBrain{1}{1})-1)*PAT.fcPAT.filtNdown.TR;
end

%% ROI selection
[all_ROIs selected_ROIs] = pat_get_rois(job);
nROI = 1:length(PAT.res.ROI); % All the ROIs

%% PLOT raw ROIs
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
                        h1 = errorbar(ROI{r1}{1,c1}, ROIsem{r1}{1,c1}, strcat(job.figColors{r1}, job.figLS{1}));
                        % Change linwidth for signal only, not error
                        hChild = get(h1, 'Children');
                        set(hChild(1), 'LineWidth', job.figLW);
                    end
                    legendCell = cat(1,legendCell,PAT.ROI.ROIname{r1});
                end
            end % ROIS loop
            if isfield(PAT.jobsdone, 'maskSeriesOK')
                % Plot raw brain mask signal
                h1 = errorbar(brainMaskSeries{1}{1,c1}, brainMaskSem{1}{1,c1}, strcat(job.figColors{r1}, job.figLS{r1}));
                % Change linwidth for signal only, not error
                hChild = get(h1, 'Children');
                set(hChild(1), 'LineWidth', job.figLW);
                legendCell = cat(1,legendCell,'Global Brain Signal');
            end
            axis tight;
            set(gca, 'FontSize', job.axisFontSize)
            if job.legendShow
                legend(legendCell, 'FontSize', job.axisLabelFontSize);
            end
            title(sprintf('%s', colorNames{c1+1}), 'interpreter', 'none', 'FontSize', job.titleFontSize);
            xlabel('t [s]', 'FontSize', job.axisLabelFontSize)
            ylabel(sprintf('%s [a.u.]', colorNames{c1+1}), 'FontSize', job.axisLabelFontSize)
            
            if job.save_figures
                % ---------------------- Saving plots --------------------------
                [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
                scanName = splitStr{end-1};
                newName = [sprintf('%s_C%d(%s)',scanName,c1, colorNames{c1+1}) '_plotROI'];
                if isfield(job.PATmatCopyChoice,'PATmatCopy')
                    dir_filtfig = fullfile(dir_patmat,strcat('fig_',job.PATmatCopyChoice.PATmatCopy.NewPATdir));
                else
                    dir_filtfig = fullfile(dir_patmat,'fig_plotROI');
                end
                if ~exist(dir_filtfig,'dir'), mkdir(dir_filtfig); end
                % Save as PNG
                print(h, '-dpng', fullfile(dir_filtfig,newName), '-r300');
                % Save as a figure
                saveas(h, fullfile(dir_filtfig,newName), 'fig');
                % Return the property to its default
                set(h, 'units', 'pixels')
                close(h)
            end % Save figures
            % ------------------------------------------------------------------
        end
    end % Colors loop
end

%% Plot filtered series
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
                    if isfield(PAT.jobsdone, 'filtNdownOK')
                        % Plot raw ROIs
                        hold on
                        h1 = errorbar(filtNdownROI{r1}{1,c1}, ROIsem{r1}{1,c1}, strcat(job.figColors{r1}, job.figLS{1}));
                        % Change linwidth for signal only, not error
                        hChild = get(h1, 'Children');
                        set(hChild(1), 'LineWidth', job.figLW);
                    end
                    legendCell = cat(1,legendCell,PAT.ROI.ROIname{r1});
                end
            end % ROIS loop
            if isfield(PAT.jobsdone, 'maskSeriesOK')
                % Plot raw brain mask signal
                h1 = errorbar(filtNdownBrain{1}{1,c1}, brainMaskSem{1}{1,c1}, strcat(job.figColors{r1}, job.figLS{1}));
                % Change linwidth for signal only, not error
                hChild = get(h1, 'Children');
                set(hChild(1), 'LineWidth', job.figLW);
                legendCell = cat(1,legendCell,'Global Brain Signal');
            end
            axis tight;
            set(gca, 'FontSize', job.axisFontSize)
            if job.legendShow
                legend(legendCell, 'FontSize', job.axisLabelFontSize);
            end
            title(sprintf('%s [%0.3f-%0.3f] Hz',colorNames{c1+1}, PAT.fcPAT.filtNdown.BPFfreq), 'interpreter', 'none', 'FontSize', job.titleFontSize);
            xlabel('t [s]', 'FontSize', job.axisLabelFontSize)
            ylabel(sprintf('%s [a.u.]', colorNames{c1+1}), 'FontSize', job.axisLabelFontSize)
            
            if job.save_figures
                % ---------------------- Saving plots --------------------------
                [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
                scanName = splitStr{end-1};
                newName = [sprintf('%s_C%d(%s)',scanName,c1,colorNames{c1+1}) '_plotROIfilt'];
                if isfield(job.PATmatCopyChoice,'PATmatCopy')
                    dir_filtfig = fullfile(dir_patmat,strcat('fig_',job.PATmatCopyChoice.PATmatCopy.NewPATdir));
                else
                    dir_filtfig = fullfile(dir_patmat,'fig_plotROI');
                end
                if ~exist(dir_filtfig,'dir'), mkdir(dir_filtfig); end
                % Save as PNG
                print(h, '-dpng', fullfile(dir_filtfig,newName), '-r300');
                % Save as a figure
                saveas(h, fullfile(dir_filtfig,newName), 'fig');
                % Return the property to its default
                set(h, 'units', 'pixels')
                close(h)
            end % Save figures
            % ------------------------------------------------------------------
        end
    end % Colors loop
end

%% Display ROIs and brain mask 
% TO DO...

% EOF
