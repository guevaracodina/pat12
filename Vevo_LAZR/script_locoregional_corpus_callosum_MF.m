%% script_locoregional_corpus_callosum
close all; clc;
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
job.ROI_choice              = [11];     % Analyze only corpus callosum

% Include only certain frames if scrubbing is not performed
if ~DO_SCRUBBING
    frames2includeIdx = 30:90;
end

% Control group
job.PATmatCtrl = {  
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-12-10-31_ctl01\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-14-48-55_ctl02\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-18-31_ctl03\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DI_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DJ_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS3\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E10_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E11_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E12_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E13_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                };

% LPS group
job.PATmatLPS = {
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                };
% Colors to include (OD,HbO,HbR,HbT,Flow)
job.IC                      = pat_include_colors_cfg(1,1);
          
% Significance level
job.optStat.alpha           = 0.05;

% Generate / save figures
job.generate_figures        = true;
job.save_figures            = true;

if job.ROI_choice == 11
    job.parent_results_dir{1}   = 'F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\CorpusCallosum';
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
xLabelFontSize              = 16;
% Y-axis font size
yLabelFontSize              = 16;
% Title font size
titleFontSize               = 16;

% ------------------------------------------------------------------------------
% Legends options
% ------------------------------------------------------------------------------
legendStr                   = {'Ctrl' 'LPS'};
legendLocation              = 'NorthEast';
legendFontSize              = 16;
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

hROIs = figure; hold on

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
                currentROI = ROI{r1}{c1}(scrubMask{c1});
            else
                currentROI = ROI{r1}{c1}(frames2includeIdx);
            end
            tmpROI = [tmpROI currentROI];
            if c1 == 2
                figure(hROIs)
                if any(scanIdx == CtrlInjectedIdx)
                    % NaCl (sham)
                    plot(pat_raw2so2(currentROI), 'b-')
                else
                    % Control
                    plot(pat_raw2so2(currentROI), 'k-')
                end
            end
        end
        % Compute average and standard deviation from all ROIs
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
    'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\scrubbing.mat'   % Outlier?
    'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\scrubbing.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\scrubbing.mat'
    };

% Index of scans to exclude
idx2exclude = 0;

% Load PAT data
for scanIdx = 1:numel(job.PATmatLPS)
    if scanIdx ~= idx2exclude
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
                    currentROI = ROI{r1}{c1}(scrubMask{c1});
                else
                    currentROI = ROI{r1}{c1}(frames2includeIdx);
                end
                tmpROI = [tmpROI currentROI];
                if c1 == 2
                    figure(hROIs)
                    plot(pat_raw2so2(currentROI), 'r-')
                end
            end
            % Compute average and standard deviation from all ROIs
            AvgLPS(scanIdx, c1) = nanmean(tmpROI);
            StdLPS(scanIdx, c1) = nanstd(tmpROI);
            % Convert raw SO2 values to %
            if c1 == 2
                % SO2 index = 2
                AvgLPS(scanIdx, c1) = pat_raw2so2(AvgLPS(scanIdx, c1));
                StdLPS(scanIdx, c1) = pat_raw2so2(StdLPS(scanIdx, c1));
            end
        end
    else
        fprintf('Excluded: %s',motion_parameters.scrub.fname{scanIdx});
    end
end
figure(hROIs); set(hROIs, 'color', 'w')
xlim([0 350]);
xlabel('Frames','FontSize',xLabelFontSize)
ylabel('SO_2 (%)','FontSize',yLabelFontSize)
legend({'Ctrl' '' '' 'NaCl (sham)' '' '' '' '' '' '' '' '' '' '' '' '' ''  '' 'LPS'},'FontSize',legendShow.legendFontSize)
set(gca,'FontSize',legendFontSize)
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
% [p1, table1, stats1] = anova1(groupedData, group, 'off');
% [p1, table1, stats1] = kruskalwallis(groupedData, group, 'off');
% figure;
% [comparison, means, h, groupNames] = multcompare(stats1, 'alpha', job.optStat.alpha, 'ctype', criterionType);
% set(h,'Name','Multiple comparison of average SO_2 values');
% title('Locoregional cortical SO_2')
% disp([groupNames num2cell(comparison)]);

%% Print multiple comparisons ANOVA
% if job.save_figures
%     colorNames      = fieldnames(PAT.color);
%     % Specify window units
%     set(h, 'units', 'inches')
%     % Change figure and paper size
%     set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
%     set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
%     c1 = 2; % only SO2 here
%     if DO_SCRUBBING
%         newName = sprintf('ANOVA_multiple_comparisons_%s_C%d_(%s)',criterionType,c1,colorNames{1+c1});
%     else
%         newName = sprintf('ANOVA_multiple_comparisons_%s_C%d_(%s)_%02dto%02d',criterionType,c1,colorNames{1+c1},frames2includeIdx(1),frames2includeIdx(end));
%     end
%     % Save as PNG
%     print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
%     % Save as a figure
%     saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
%     % Return the property to its default
%     set(h, 'units', 'pixels')
%     close(h)
% end

%% N-way ANOVA
% Only for SO2
c1= 2;
% SO2 concentration in corpus callosum
SO2values = [AvgCtrl(:,c1); AvgLPS(:,c1)];

% Sex indices
unknownIdx = [1:3,11];      % 4 unknown rat pups [1:3,11]
femaleIdx = [7,9,19,26:29];
maleIdx = [4:6,8,10,12:18,20:25];

% 1st grouping variable(factor): group
group = cell(size(SO2values));
% group(CtrlIdx) = {'Ctrl'};
% Missing Values
group(CtrlIdx) = {''};
group(CtrlInjectedIdx) = {'NaCl'};
group(19:end) = {'LPS'};

% 2nd Grouping variable(factor): sex
sex = cell(size(SO2values));

% sex(unknownIdx) = {'X'};
% Missing values ''
sex(unknownIdx) = {''};
sex(femaleIdx) = {'F'};
sex(maleIdx) = {'M'};

% anovan parameters
groupingVars = {'Group' 'Sex'};
modelType = 'interaction';
[p,table,stats,terms] = anovan(SO2values, {group sex}, 'alpha', job.optStat.alpha, ...
    'varnames', groupingVars, 'model', modelType);
figure;
[comparison, means, h, groupNames] = multcompare(stats, 'alpha', job.optStat.alpha,...
    'ctype', criterionType, 'dimension', [1 2], 'display', 'on');
% EOF
