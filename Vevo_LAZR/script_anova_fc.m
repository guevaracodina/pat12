%% script_anova_fc
clear; clc; close all;

%% Load LPS + Ctrl
load('F:\Edgar\Data\PAT_Results_20130517\RS\group_results_HbO_HbR_LPS_Ctrl\group_corr_pair_seeds.mat')
% renaming
LPS_Ctrl_eTotal = eTotal; 
LPS_Ctrl_groupCorrData = groupCorrData; 
LPS_Ctrl_groupCorrDataDiff = groupCorrDataDiff; 
LPS_Ctrl_groupCorrDataRaw = groupCorrDataRaw; 
LPS_Ctrl_groupCorrIdx = groupCorrIdx; 
LPS_Ctrl_groupID = groupID; 
LPS_Ctrl_isTreatment = isTreatment; 
LPS_Ctrl_meanCorr = meanCorr; 
LPS_Ctrl_pairedSeedsNames = pairedSeedsNames; 
LPS_Ctrl_statTest = statTest; 
LPS_Ctrl_stdCorr = stdCorr; 
LPS_Ctrl_subjectName = subjectName; 
LPS_Ctrl_yTotal = yTotal;
% cleanup
clear eTotal groupCorrData groupCorrDataDiff groupCorrDataRaw groupCorrIdx groupID isTreatment meanCorr pairedSeedsNames statTest stdCorr subjectName yTotal;

%% Load LPS + Sham
load('F:\Edgar\Data\PAT_Results_20130517\RS\group_results_HbO_HbR_LPS_Sham\group_corr_pair_seeds.mat')
% renaming
LPS_NaCl_eTotal = eTotal; 
LPS_NaCl_groupCorrData = groupCorrData; 
LPS_NaCl_groupCorrDataDiff = groupCorrDataDiff; 
LPS_NaCl_groupCorrDataRaw = groupCorrDataRaw; 
LPS_NaCl_groupCorrIdx = groupCorrIdx; 
LPS_NaCl_groupID = groupID; 
LPS_NaCl_isTreatment = isTreatment; 
LPS_NaCl_meanCorr = meanCorr; 
LPS_NaCl_pairedSeedsNames = pairedSeedsNames; 
LPS_NaCl_statTest = statTest; 
LPS_NaCl_stdCorr = stdCorr; 
LPS_NaCl_subjectName = subjectName; 
LPS_NaCl_yTotal = yTotal;
% cleanup
clear eTotal groupCorrData groupCorrDataDiff groupCorrDataRaw groupCorrIdx groupID isTreatment meanCorr pairedSeedsNames statTest stdCorr subjectName yTotal;

%% Arranging data
nLPS = numel(find(LPS_Ctrl_isTreatment));
nCtrl = numel(find(~LPS_Ctrl_isTreatment));
nNaCl = numel(find(~LPS_NaCl_isTreatment));
% Contrast
for c1 = [1 2 4 5],
    % ROI (1:3) M, S1, S1BF
    for r1 = 1:3,
        % Gather all measurements
        dataLPS{c1}(:,r1) = LPS_Ctrl_groupCorrData{r1,c1}(LPS_Ctrl_isTreatment);
        dataCtrl{c1}(:,r1) = LPS_Ctrl_groupCorrData{r1,c1}(~LPS_Ctrl_isTreatment);
        dataNaCl{c1}(:,r1) = LPS_NaCl_groupCorrData{r1,c1}(~LPS_NaCl_isTreatment);
        % Mean values
        meansLPS(r1,c1) = LPS_Ctrl_meanCorr{r1,c1}(2);
        meansCtrl(r1,c1) = LPS_Ctrl_meanCorr{r1,c1}(1);
        meansNaCl(r1,c1) = LPS_NaCl_meanCorr{r1,c1}(1);
        % Std. Dev. values (SEM for display)
        stdsLPS(r1,c1) = LPS_Ctrl_stdCorr{r1,c1}(2);
        stdsCtrl(r1,c1) = LPS_Ctrl_stdCorr{r1,c1}(1);
        stdsNaCl(r1,c1) = LPS_NaCl_stdCorr{r1,c1}(1);
    end
end

%% Plot group results
close all
titleContrast = {'HbT' 'SO_2' '' 'HbO_2' 'HbR'};
labelY = 'Bilateral correlations z(r)';
ROIlabel = {'M' 'S1' 'S1BF'};
fontSize = 12;
ylimits = [-0.2 1];
group = {'LPS'; 'Control'; 'NaCl '};
colormaps = {[1 1 1;0.75 0.75 0.75; 0.5 0.5 0.5], [1 1 1;0.75 0.75 0.75; 0.5 0.5 0.5],...
    [], [1 1 1;1 0 0;0.5 0 0], [1 1 1;0 0 1;0 0 0.5]};
figSize = [0.1 0.1 3.5 3.5];
% Contrast
for c1 = [1 2 4 5],
    h = figure; set(gcf,'color','w')
    % (SEM for display)
    pat_barwitherr([    stdsLPS(:,c1)./sqrt(nLPS) ...
                        stdsCtrl(:,c1)./sqrt(nCtrl) ... 
                        stdsNaCl(:,c1)./sqrt(nNaCl) ], ...
        [meansLPS(:,c1) meansCtrl(:,c1) meansNaCl(:,c1)])
    
    set(h, 'units', 'inches')
    set(h, 'PaperPosition', figSize)
    set(h, 'Position', figSize)
    
    axis tight
    ylim(ylimits);
    set(gca,'FontSize',fontSize);
    set(gca,'xTickLabel',ROIlabel,'FontSize',fontSize);
    ylabel(labelY,'FontSize',fontSize);
    title(titleContrast{c1},'FontSize',fontSize);
    legend(group)
    colormap(colormaps{c1})
    
    print(gcf, '-dpng', ...
        fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures\HbOHbR_connectivity_ANOVA',...
        sprintf('ANOVA_%s',titleContrast{c1})), '-r300');
end

%% Plot only 2 groups
close all
titleContrast = {'HbT' 'SO_2' '' 'HbO_2' 'HbR'};
labelY = 'Bilateral correlations z(r)';
ROIlabel = {'M' 'S1' 'S1BF'};
fontSize = 16;
ylimits = [0 0.95];
group = {'NaCl'; 'LPS'};
colormaps = {flipud([1 1 1;0.5 0.5 0.5; 0.25 0.25 0.25]), flipud([1 1 1;0.75 0.75 0.75; 0.5 0.5 0.5]),...
    [], flipud([1 1 1;1 0 0;0.5 0 0]), flipud([1 1 1;0 0 1;0 0 0.5])};
figSize = [0.1 0.1 3.5 3.5];
% Contrast
for c1 = [1 2 4 5],
    h = figure; set(gcf,'color','w')
    % (SEM for display)
    pat_barwitherr( [   stdsNaCl(:,c1)./sqrt(nNaCl)...
                        stdsLPS(:,c1)./sqrt(nLPS)],...
                    [   meansNaCl(:,c1)...
                        meansLPS(:,c1)]);
    
    set(h, 'units', 'inches')
    set(h, 'PaperPosition', figSize)
    set(h, 'Position', figSize)
    
    axis tight
    xlim([0.5 3.5]);
    ylim(ylimits);
    set(gca,'FontSize',fontSize);
    set(gca,'xTickLabel',ROIlabel,'FontSize',fontSize);
    ylabel(labelY,'FontSize',fontSize);
%     title(titleContrast{c1},'FontSize',fontSize);
    legend(group,'FontSize',fontSize)
    colormap(colormaps{c1})
    
    print(gcf, '-dpng', ...
        fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures\HbOHbR_connectivity_LPS_NaCl',...
        sprintf('groupCorr_Wtest_C1_(%s)',titleContrast{c1})), '-r300');
end

%% Performing multi-variate ANOVA
% Contrast
c1 = 2;
alpha = 0.05;
criterionType = 'tukey-kramer';
[p, table] = pat_anova_rm({ dataLPS{c1} dataCtrl{c1} dataNaCl{c1}},'on');
% Build stats structure
% stats1.gnames
% stats1.n
% stats1.source = 'anova1';
% stats1.means
% stats1.df
% stats1.s
% [comparison, means, h, groupNames] = multcompare(stats1, 'alpha', alpha, 'ctype', criterionType);
% EOF
