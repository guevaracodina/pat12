%% script_locoregional_cortical_pat
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
job.ROI_choice              = [12];     % Analyze only Left Cortex (11) (injection side)

% Include only certain frames if scrubbing is not performed
if ~DO_SCRUBBING
    frames2includeIdx = 30:90;
end

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

%% Stat test for left and right, male, female
load('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\locoregional_SO2_data_LR.mat')
% Only for SO2
c1= 2;
criterionType = 'tukey-kramer';
% SO2 concentration in corpus callosum
SO2values = [LPS_left; Ctrl_left; CtrlInjected_left; LPS_right; Ctrl_right; CtrlInjected_right];
% Group indices
CtrlIdx = [12:21, 41:50];
CtrlInjectedIdx = [22:29, 51:58];
LPSIdx = [1:11, 30:40];
% Sex indices TODO CORRECT INDICES!!!!!!!!
unknownIdx = [1:3,11,30:32,40];      % 4 unknown rat pups [1:3,11]
femaleIdx = [7,9,19,26:29,36,38,48,55:58];
maleIdx = [4:6,8,10,12:18,20:25,33:35,37,39,41:47,49:54];
% Hemisphere indices
leftIdx = 1:29;
rightIdx = 30:58;

% 1st grouping variable: group

group = cell(size(SO2values));
group(CtrlIdx,:) = {'Ctrl'};
group(CtrlInjectedIdx) = {'NaCl'};
group(LPSIdx) = {'LPS'};

% 2nd grouping variable: sex
sex = cell(size(SO2values));
sex(unknownIdx) = {'X'};
sex(femaleIdx) = {'F'};
sex(maleIdx) = {'M'};

% 3rd grouping variable: hemisphere
hemisphere = cell(size(SO2values));
hemisphere(leftIdx) = {'Left'};
hemisphere(rightIdx) = {'Right'};

% anovan parameters
groupingVars = {'Group' 'Sex' 'Hemisphere'};
modelType = 'interaction';

%% 3-way ANOVA
close all
[p,table,stats,terms] = anovan(SO2values, {group sex hemisphere}, 'alpha', job.optStat.alpha, ...
    'varnames', groupingVars, 'model', modelType);
figure;
[comparison, means, h, groupNames] = multcompare(stats, 'alpha', job.optStat.alpha,...
    'ctype', criterionType, 'dimension', [1 2 3], 'display', 'on');

% EOF
