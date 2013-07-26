%% script_locoregional_cortical_pat
close all; clear; clc;
% scrubbing
DO_SCRUBBING = true;
% Choose ROI selection method (all/selected)
%     'CPu_L'
%     'CPu_R'
%     'LV_L'
%     'LV_R'
%     'M_L'
%     'M_R'
%     'S1_L'
%     'S1_R'
%     'S1BF_L'
%     'S1BF_R'
%     'Cortex_L'
%     'Cortex_R'
job.ROI_choice              = [11];     % Analyze only Left Cortex (injection side)

% Control group
job.PATmatCtrl = {  
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-12-10-31_ctl01\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-14-48-55_ctl02\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-18-31_ctl03\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DI_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DJ_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS3\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E10_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E11_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E12_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E13_RS\newROIs\PAT.mat'
                };

% LPS group
job.PATmatLPS = {
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\newROIs\PAT.mat'
                };
% Colors to include (OD,HbO,HbR,HbT,Flow)
job.IC                      = pat_include_colors_cfg(1,1);
          
% Significance level
job.optStat.alpha           = 0.05;

% Generate / save figures
job.generate_figures        = true;
job.save_figures            = false;

if job.ROI_choice == 11
    job.parent_results_dir{1}   = 'F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\LeftCortex';
elseif job.ROI_choice == 12
    job.parent_results_dir{1}   = 'F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\RightCortex';
else 
    job.parent_results_dir{1}   = 'F:\Edgar\Data\PAT_Results_20130517\RS\locoregional';
end
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Print figure options
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Figure size
figSize                     = [3.25 3.25];
% Figure resolution
figRes                      = 300;
% Show standard error bar
stderror                    = true;

% ------------------------------------------------------------------------------
% Choose axis limits
% ------------------------------------------------------------------------------
yLimValue                   = [-1 1.5];
yLimManual.yLimValue        = yLimValue;
yLimAuto                    = true;
yLimits.yLimAuto            = yLimAuto;
%yLimits.yLimManual          = yLimManual;
% ------------------------------------------------------------------------------
% X-axis labels
xAxisLabels                 = {'Ctrl' 'LPS'};
% X-axis font size
xLabelFontSize              = 10;
% Y-axis font size
yLabelFontSize              = 10;
% Title font size
titleFontSize               = 10;

% ------------------------------------------------------------------------------
% Legends options
% ------------------------------------------------------------------------------
legendStr                   = {'Ctrl' 'LPS'};
legendLocation              = 'NorthEast';
legendFontSize              = 10;
legendShow.legendStr        = legendStr;
legendShow.legendLocation   = legendLocation;
legendShow.legendFontSize   = legendFontSize;
legendHide                  = false;
% legends.legendShow          = legendShow;
legends.legendHide          = legendHide ;
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Figure options
% ------------------------------------------------------------------------------
job.optFig.stderror         = stderror;
job.optFig.figSize          = figSize;
job.optFig.figRes           = figRes;
job.optFig.yLimits          = yLimits;
job.optFig.xAxisLabels      = xAxisLabels;
job.optFig.xLabelFontSize   = xLabelFontSize;
job.optFig.yLabelFontSize   = yLabelFontSize;
job.optFig.titleFontSize    = titleFontSize;
job.optFig.legends          = legends;
% ------------------------------------------------------------------------------

%% Controls
% Preallocate arrays
AvgCtrl = nan([numel(job.PATmatCtrl) 2]);
StdCtrl = nan([numel(job.PATmatCtrl) 2]);
tmpROI = [];
% Scrubbing filenames for controls
motion_parameters.scrub.fname = {
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-12-10-31_ctl01\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-14-48-55_ctl02\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-18-31_ctl03\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DI_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DJ_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS3\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E10_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E11_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E12_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E13_RS\GLMfcPAT\scrubbing.mat'
    };

% Indices for sham and untreated controls
CtrlInjectedIdx = [4:7 10 12:14]';
CtrlIdx         = [1:3 8 9 11 15:18]';
 
% Load PAT data
for scanIdx = 1:numel(job.PATmatCtrl)
    %Load PAT.mat information
    load(job.PATmatCtrl{scanIdx})
    % Load ROIs raw data
    load(PAT.ROI.ROIfname);
    % Colors loop
    for c1 = 1:2,
%         scrubMask{c1} = 5:20;
        for r1 = job.ROI_choice
            % Load data from selected ROIs
            if DO_SCRUBBING
                % load scrubbing parameters
                load(motion_parameters.scrub.fname{scanIdx})
                tmpROI = [tmpROI ROI{r1}{c1}(scrubMask{c1})];
            else
                tmpROI = [tmpROI ROI{r1}{c1}];
            end
            % Compute average and standard deviation from all ROIs
            % if SO2, convert to [%]
        end
        AvgCtrl(scanIdx, c1) = nanmean(tmpROI);
        StdCtrl(scanIdx, c1) = nanstd(tmpROI);
        % Convert raw SO2 values to %
        if c1 == 2
            % SO2 index = 2
            AvgCtrl(scanIdx, c1) = pat_raw2so2(AvgCtrl(scanIdx, c1));
            StdCtrl(scanIdx, c1) = pat_raw2so2(StdCtrl(scanIdx, c1));
        end
    end
end

% Data for ANOVA
CtrlInjected = AvgCtrl(CtrlInjectedIdx,2);
Ctrl = AvgCtrl(CtrlIdx,2);

%% LPS
% Preallocate arrays
AvgLPS = nan([numel(job.PATmatLPS) 2]);
StdLPS = nan([numel(job.PATmatLPS) 2]);
tmpROI = [];
% Scrubbing filenames for LPS
motion_parameters.scrub.fname = {
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\scrubbing.mat'
    };
% Load PAT data
for scanIdx = 1:numel(job.PATmatLPS)
    %Load PAT.mat information
    load(job.PATmatLPS{scanIdx})
    % Load ROIs raw data
    load(PAT.ROI.ROIfname);
    % Colors loop
    for c1 = 1:2,
%         scrubMask{c1} = 5:20;
        for r1 = job.ROI_choice
            % Load data from selected ROIs
            if DO_SCRUBBING
                % load scrubbing parameters
                load(motion_parameters.scrub.fname{scanIdx})
                tmpROI = [tmpROI ROI{r1}{c1}(scrubMask{c1})];
            else
            % Load data from selected ROIs
                tmpROI = [tmpROI ROI{r1}{c1}];
            % Compute average and standard deviation from all ROIs
            % if SO2, convert to [%]
            end
        end
        AvgLPS(scanIdx, c1) = nanmean(tmpROI);
        StdLPS(scanIdx, c1) = nanstd(tmpROI);
        % Convert raw SO2 values to %
        if c1 == 2
            % SO2 index = 2
            AvgLPS(scanIdx, c1) = pat_raw2so2(AvgLPS(scanIdx, c1));
            StdLPS(scanIdx, c1) = pat_raw2so2(StdLPS(scanIdx, c1));
        end
    end
end

% Data for ANOVA
LPS = AvgLPS(:,2);

% Create parent results directory if it does not exist
if ~exist(job.parent_results_dir{1},'dir'), mkdir(job.parent_results_dir{1}); end
% Save AvgCtrl, AvgLPS
dataFileName = 'locoregional_SO2_data';
save(fullfile(job.parent_results_dir{1},dataFileName),'AvgCtrl','AvgLPS',...
    'CtrlInjected','Ctrl','LPS','job','PAT')

%% perform 1-Way ANOVA
% load ('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\LeftCortex\locoregional_SO2_data')
% load ('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\RightCortex\locoregional_SO2_data')
close all

criterionType = 'tukey-kramer';
group = {'LPS'; 'Control'; 'NaCl (sham)'};
nRows = max([size(LPS,1); size(Ctrl,1); size(CtrlInjected,1)]);
groupedData = nan([nRows, numel(group)]);
groupedData(1:numel(LPS(:,1)), 1)          = LPS(:,1);
groupedData(1:numel(Ctrl(:,1)), 2)         = Ctrl(:,1);
groupedData(1:numel(CtrlInjected(:,1)), 3) = CtrlInjected(:,1);
[p1, table1, stats1] = anova1(groupedData, group, 'off');
% [p1, table1, stats1] = kruskalwallis(groupedData, group, 'off');
h = figure;
[comparison, means, h, groupNames] = multcompare(stats1, 'alpha', job.optStat.alpha, 'ctype', criterionType);
set(h,'Name','Multiple comparison of average SO_2 values');
title('Locoregional cortical SO_2')
disp([groupNames num2cell(comparison)]);

%% Print multiple comparisons ANOVA
if job.save_figures
    colorNames      = fieldnames(PAT.color);
    % Specify window units
    set(h, 'units', 'inches')
    % Change figure and paper size
    set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
    set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
    c1 = 2; % only SO2 here
    newName = sprintf('ANOVA_multiple_comparisons_%s_C%d_(%s)',criterionType,c1,colorNames{1+c1});
    % Save as PNG
    print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
    % Save as a figure
    saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
    % Return the property to its default
    set(h, 'units', 'pixels')
    close(h)
end

%% statistical test comparison (to be performed for two groups only)

% for c1 = 1:2
%     [statTest(1).t(1).H{c1}, statTest(1).t(1).P{c1}, statTest(1).t(1).CI{c1}, ...
%         statTest(1).t(1).STATS{c1}] = ...
%         ttest2(AvgCtrl(:,c1), AvgLPS(:,c1), job.optStat.alpha,'both');
%     statTest(1).t(1).id = 'Unpaired-sample t-test';
%     fprintf('%s: Contrast (%s) p=%0.4f\n',statTest(1).t(1).id, colorNames{1+c1},statTest(1).t(1).P{c1});
%     [statTest(1).w(1).P{c1}, statTest(1).w(1).H{c1}, statTest(1).w(1).STATS{c1}] =...
%         ranksum (AvgCtrl(:,c1), AvgLPS(:,c1), job.optStat.alpha);
%     statTest(1).w(1).id = 'Wilcoxon rank sum test';
%     fprintf('%s: Contrast (%s) p=%0.4f\n', statTest(1).w(1).id, colorNames{1+c1},statTest(1).w(1).P{c1});
% end

%% Plot results %% statistical test comparison (for two groups only)

% % Plots statistical analysis group results
% % Positioning factor for the * mark, depends on max data value at the given seed
% starPosFactor   = 1.05;
% % Font Sizes
% axisFontSize    = 12;
% starFontSize    = 22;
% axMargin        = 0.5;
% labelYaxis{1}   = 'HbT (a.u.)';
% labelYaxis{2}   = 'SO_2 (%)';
% statsNames = {'t' 'w'};
% statsID = {'T-test' 'Wilcoxon'};
% for iStats = 1:numel(statsNames)
%     for c1 = 1:2
%         y = [mean(AvgCtrl(:,c1)); mean(AvgLPS(:,c1))];
%         e = [std(AvgCtrl(:,c1)); std(AvgLPS(:,c1))];
%         % Show standard error bars instead of standard deviation
%         if job.optFig.stderror
%             sampleSize = ones(size(e));
%             % First row: Control group
%             sampleSize(1,:) = sampleSize(1,:) .* numel(AvgCtrl(:,c1));
%             % Second row: Treatment group
%             sampleSize(2,:) = sampleSize(2,:) .* numel(AvgLPS(:,c1));
%             % std error bars: sigma/sqrt(N)
%             e = e ./ sqrt(sampleSize);
%         end
%         if job.generate_figures
%             % Display plots on new figure
%             h = figure; set(gcf,'color','w')
%             % Specify window units
%             set(h, 'units', 'inches')
%             % Change figure and paper size
%             set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
%             set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
%             % Custom bar graphs with error bars (1st arg: error)
%             barwitherr(e, y)
%             % Display colormap according to the contrast
%             switch(c1)
%                 case 1
%                     % HbT contrast
%                     colormap([0.5 0.5 0.5; 1 1 1]);
%                 case 2
%                     % SO2 contrast
%                     colormap([0.25 0.25 0.25; 1 1 1]);
%                 case 3
%                     % B-mode contrast
%                     colormap([0 0 0; 1 1 1]);
%                 otherwise
%                     colormap(gray)
%             end
%             
%             title(sprintf('C%d(%s) %s (*p<%.2g)',...
%                 c1,colorNames{1+c1}, statsID{iStats}, job.optStat.alpha),'interpreter','none','FontSize',job.optFig.titleFontSize)
%             set(gca,'FontSize',axisFontSize)
%             ylabel(labelYaxis{c1},'FontSize',job.optFig.yLabelFontSize)
%             set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
%             if isfield(job.optFig.legends, 'legendShow')
%                 legend(job.optFig.legends.legendShow.legendStr,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
%             end
%             set(gca, 'xLim', [axMargin size(y,1) + axMargin]);
%             if isfield(job.optFig.yLimits, 'yLimManual')
%                 set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
%             end
%             % Show a * when a significant difference is found.
%             if statTest(1).(statsNames{iStats})(1).H{c1}
%                 if max(e)>=0
%                     yPos = starPosFactor*(max(y(:)) + max(e(:)));
%                 else
%                     yPos = starPosFactor*(min(y(:)) - max(e(:)));
%                 end
%                 xPos = 1;
%                 text(xPos, yPos, '*', 'FontSize', starFontSize, 'FontWeight', 'b');
%             end
%             if job.save_figures
%                 newName = sprintf('groupCorr_%c_C%d_(%s)',statsNames{iStats},c1,colorNames{1+c1});
%                 % Save as PNG
%                 print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
%                 % Save as a figure
%                 saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
%                 % Return the property to its default
%                 set(h, 'units', 'pixels')
%                 close(h)
%             end
%         end % end generate figures
%     end % colors loop
% end % stats loop
        
% EOF
