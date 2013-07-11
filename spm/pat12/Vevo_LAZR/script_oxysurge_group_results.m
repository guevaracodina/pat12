%% script_oxysurge_group_results
load('D:\Edgar\Documents\Dropbox\Docs\PAT\OS\TablResultat.mat')
Data = cell2mat(TablResultat(2:end,2:end));
CtrlIdx = [4 7 8 10 12 13 15 16];
LPSIdx = [1 2 3 5 6 9 11 14];
Ctrl = Data(CtrlIdx,:);
LPS = Data(LPSIdx,:);
job.optStat.alpha = 0.05;

%% Statistical test
clc;
colorNames = TablResultat(1,:);
statTest(1).w(1).id = 'Wilcoxon rank sum test';
fprintf('%s\n',statTest(1).w(1).id);
for c1 = 1:4
    [statTest(1).w(1).P{c1}, statTest(1).w(1).H{c1}, statTest(1).w(1).STATS{c1}] =...
        ranksum (Ctrl(:,c1), LPS(:,c1), job.optStat.alpha);
    statTest(1).w(1).id = 'Wilcoxon rank sum test';
    fprintf('(%s) Ctrl = %0.4f ± %0.4f; LPS = %0.4f ± %0.4f. p=%0.4f\n', ...
        colorNames{1+c1}, mean(Ctrl(:,c1)), std(Ctrl(:,c1)),...
        mean(LPS(:,c1)), std(LPS(:,c1)), statTest(1).w(1).P{c1});
end
% EOF
