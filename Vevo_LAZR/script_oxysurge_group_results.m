%% script_oxysurge_group_results
clear; close all; clc;
load('F:\Edgar\Data\PAT_Results_20130517\OxySurge\TablResultatSerieE.mat')
% Rename serie E variable
TablResultatSerieE = TablResultat; clear TablResultat;
% Load data from first 2 series
load('F:\Edgar\Data\PAT_Results_20130517\OxySurge\TablResultat.mat')
% Animals ID
ID = [TablResultat(2:end,1); TablResultatSerieE(2:end,1)];
% Grouped data
Data = cell2mat([TablResultat(2:end,2:end); TablResultatSerieE(2:end,2:end)]);

% First series only
CtrlIdx = [10 13 15 16];
CtrlInjectedIdx = [7 8 12 ];
LPSIdx = [1 2 3 5 6 9 11 14 ];

% Whole series
% CtrlIdx = [10 13 15 16 26 27];
% CtrlInjectedIdx = [7 8 12 17 18 19];
% LPSIdx = [1 2 3 5 6 9 11 14 20 21 22 23 24];

% Gathering data in the corresponding vectors
Ctrl = Data(CtrlIdx,:);
LPS = Data(LPSIdx,:);
CtrlInjected = Data(CtrlInjectedIdx,:);
% Significance value
job.optStat.alpha = 0.05;

%% Statistical test (only to be performed for two groups analysis)
clc;
colorNames = TablResultat(1,:);
statTest(1).w(1).id = 'Wilcoxon rank sum test';
fprintf('%s\n',statTest(1).w(1).id);
% c1 is measurements index
for c1 = 1:4
    [statTest(1).w(1).P{c1}, statTest(1).w(1).H{c1}, statTest(1).w(1).STATS{c1}] =...
        ranksum ([Ctrl(:,c1); CtrlInjected(:,c1)], LPS(:,c1), job.optStat.alpha);
    statTest(1).w(1).id = 'Wilcoxon rank sum test';
    fprintf('(%s) Ctrl = %0.4f ± %0.4f; LPS = %0.4f ± %0.4f. p=%0.4f\n', ...
        colorNames{1+c1}, mean([Ctrl(:,c1); CtrlInjected(:,c1)] ), std([Ctrl(:,c1); CtrlInjected(:,c1)]),...
        mean(LPS(:,c1)), std(LPS(:,c1)), statTest(1).w(1).P{c1});
end
fprintf('p = [%0.4f %0.4f %0.4f %0.4f] (FDR corrected)\n',pat_fdr(cell2mat(statTest.w.P)));
fprintf('p = [%0.4f %0.4f %0.4f %0.4f] (uncorrected)\n',cell2mat(statTest.w.P));

%% ANOVA
close all
alphaVal = job.optStat.alpha;
% c1 is measurements index 
% 1: Area under the curve
% 2: Pos. slope
% 3: Neg. slope
% 4: Plateau
for c1 = 1:4;
    criterionType = 'tukey-kramer';
    groupID = {'LPS'; 'Control'; 'NaCl (sham)'};
    nRows = max([size(LPS,1); size(Ctrl,1); size(CtrlInjected,1)]);
    % Preallocate variable with grouped data
    groupedData = nan([nRows, numel(groupID)]);
    % Fill grouped data variable
    groupedData(1:numel(LPS(:,c1)), 1) = LPS(:,c1);
    groupedData(1:numel(Ctrl(:,c1)), 2) = Ctrl(:,c1);
    groupedData(1:numel(CtrlInjected(:,c1)), 3) = CtrlInjected(:,c1);
    % Perform 1-way ANOVA
    [p1,table1,stats1] = anova1(groupedData, groupID, 'off');
    h = figure;
    % Perform multiple-comparisons test
    [comparison, means, h, groupNames] = multcompare(stats1, 'alpha', alphaVal, 'ctype', criterionType);
    switch c1
        case 1
            windowName = 'Area under the curve';
        case 2
            windowName = 'Positive slope';
        case 3
            windowName = 'Negative Slope';
        case 4
            windowName = 'Plateau';
        otherwise
            windowName = '';
    end
    set(h,'Name',windowName)
    title(windowName);
    disp([groupNames num2cell(comparison)]);
end
% EOF
