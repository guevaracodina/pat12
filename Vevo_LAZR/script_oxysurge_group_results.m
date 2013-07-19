%% script_oxysurge_group_results
load('D:\Edgar\Documents\Dropbox\Docs\PAT\OS\TablResultat.mat')
Data = cell2mat(TablResultat(2:end,2:end));
% CtrlIdx = [4 7 8 10 12 13 15 16];
CtrlIdx = [10 13 15 16];
CtrlInjectedIdx = [7 8 12];
LPSIdx = [1 2 3 5 6 9 11 14];
Ctrl = Data(CtrlIdx,:);
LPS = Data(LPSIdx,:);
CtrlInjected = Data(CtrlInjectedIdx,:);
job.optStat.alpha = 0.05;

%% Statistical test
clc;
colorNames = TablResultat(1,:);
statTest(1).w(1).id = 'Wilcoxon rank sum test';
fprintf('%s\n',statTest(1).w(1).id);
% c1 is measurements index
for c1 = 1:4
    [statTest(1).w(1).P{c1}, statTest(1).w(1).H{c1}, statTest(1).w(1).STATS{c1}] =...
        ranksum (Ctrl(:,c1), LPS(:,c1), job.optStat.alpha);
    statTest(1).w(1).id = 'Wilcoxon rank sum test';
    fprintf('(%s) Ctrl = %0.4f ± %0.4f; LPS = %0.4f ± %0.4f. p=%0.4f\n', ...
        colorNames{1+c1}, mean(Ctrl(:,c1)), std(Ctrl(:,c1)),...
        mean(LPS(:,c1)), std(LPS(:,c1)), statTest(1).w(1).P{c1});
    
    [statTest(1).w(1).P{c1}, statTest(1).w(1).H{c1}, statTest(1).w(1).STATS{c1}] =...
        ranksum (Ctrl(:,c1), CtrlInjected(:,c1), job.optStat.alpha);
    statTest(1).w(1).id = 'Wilcoxon rank sum test';
    fprintf('(%s) Ctrl = %0.4f ± %0.4f; CtrlInjected = %0.4f ± %0.4f. p=%0.4f\n', ...
        colorNames{1+c1}, mean(Ctrl(:,c1)), std(Ctrl(:,c1)),...
        mean(LPS(:,c1)), std(LPS(:,c1)), statTest(1).w(1).P{c1});
    
    [statTest(1).w(1).P{c1}, statTest(1).w(1).H{c1}, statTest(1).w(1).STATS{c1}] =...
        ranksum (LPS(:,c1), CtrlInjected(:,c1), job.optStat.alpha);
    statTest(1).w(1).id = 'Wilcoxon rank sum test';
    fprintf('(%s) LPS = %0.4f ± %0.4f; CtrlInjected = %0.4f ± %0.4f. p=%0.4f\n\n', ...
        colorNames{1+c1}, mean(LPS(:,c1)), std(LPS(:,c1)),...
        mean(CtrlInjected(:,c1)), std(CtrlInjected(:,c1)), statTest(1).w(1).P{c1});
end

%% ANOVA
close all
alphaVal = 0.05;
% c1 is measurements index
c1 = 1;
criterionType = 'tukey-kramer';
group = {'Control'; 'LPS'; 'Control Injected'};
% z_seed12_tmp = squeeze(Z(1,2,:));
nRows = max([size(LPS,1); size(Ctrl,1); size(CtrlInjected,1)]);
groupedData = nan([nRows, numel(group)]);
groupedData(1:numel(Ctrl(:,c1)), 1) = Ctrl(:,c1);
groupedData(1:numel(LPS(:,c1)), 2) = LPS(:,c1);
groupedData(1:numel(CtrlInjected(:,c1)), 3) = CtrlInjected(:,c1);
[p1,table1,stats1] = anova1(groupedData, group);
figure;
[comparison, means, h, groupNames] = multcompare(stats1, 'alpha', alphaVal, 'ctype', criterionType);
disp([groupNames num2cell(comparison)]);
% EOF
