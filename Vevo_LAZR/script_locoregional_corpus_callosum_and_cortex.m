%% script corpus callosum and left/right cortex
clear; clc
% Only SO2 c1=2
c1 = 2;
% load data
load ('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\LeftCortex\locoregional_SO2_data')
LPSleft = LPS;
shamleft = CtrlInjected;
load ('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\RightCortex\locoregional_SO2_data')
LPSright = LPS;
shamright = CtrlInjected;
load('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\CorpusCallosum\locoregional_SO2_data')
LPScc = LPS;
shamcc = CtrlInjected;
% save figures
job.save_figures = true;
% legend
job.optFig.legends.legendShow.legendStr = {'NaCl' 'LPS'};
job.optFig.legends.legendShow.legendLocation = 'NorthEast';
job.optFig.legends.legendShow.legendFontSize = 14;
% figure size
job.optFig.figSize = [4 3.25];
% vertical limits
job.optFig.yLimits.yLimManual.yLimValue = [0 72];
% names of contrasts
colorNames      = fieldnames(PAT.color);

%% statistical test comparison (for two groups only)
clear statTest; clc
iROI = 1;
[statTest(1).t(1).H(iROI), statTest(1).t(1).P(iROI), statTest(1).t(1).CI(iROI,:), ...
    statTest(1).t(1).STATS(iROI)] = ...
    ttest2(LPSleft, shamleft, job.optStat.alpha,'both');
statTest(1).t(1).id{iROI} = 'Left Cortex Unpaired-sample t-test';
[statTest(1).w(1).P(iROI), statTest(1).w(1).H(iROI), statTest(1).w(1).STATS(iROI)] =...
    ranksum (LPSleft, shamleft, job.optStat.alpha);
statTest(1).w(1).id{iROI} = 'Left Cortex Wilcoxon rank sum test';

iROI = 2;
[statTest(1).t(1).H(iROI), statTest(1).t(1).P(iROI), statTest(1).t(1).CI(iROI,:), ...
    statTest(1).t(1).STATS(iROI)] = ...
    ttest2(LPScc, shamcc, job.optStat.alpha,'both');
statTest(1).t(1).id{iROI} = 'Corpus callosum Unpaired-sample t-test';
[statTest(1).w(1).P(iROI), statTest(1).w(1).H(iROI), statTest(1).w(1).STATS(iROI)] =...
    ranksum (LPScc, shamcc, job.optStat.alpha);
statTest(1).w(1).id{iROI} = 'Corpus callosum Wilcoxon rank sum test';

iROI = 3;
[statTest(1).t(1).H(iROI), statTest(1).t(1).P(iROI), statTest(1).t(1).CI(iROI,:), ...
    statTest(1).t(1).STATS(iROI)] = ...
    ttest2(LPSright, shamright, job.optStat.alpha,'both');
statTest(1).t(1).id{iROI} = 'Right Cortex Unpaired-sample t-test';
[statTest(1).w(1).P(iROI), statTest(1).w(1).H(iROI), statTest(1).w(1).STATS(iROI)] =...
    ranksum (LPSright, shamright, job.optStat.alpha);
statTest(1).w(1).id{iROI} = 'Right Cortex Wilcoxon rank sum test';

% FDR adjustment
statTest(1).t(1).P = pat_fdr(statTest(1).t(1).P);
statTest(1).w(1).P = pat_fdr(statTest(1).w(1).P);
for iROI=1:3,
    fprintf('%s: Contrast (%s) p=%0.4f\n',statTest(1).t(1).id{iROI}, colorNames{1+c1},statTest(1).t(1).P(iROI));
    fprintf('%s: Contrast (%s) p=%0.4f\n',statTest(1).w(1).id{iROI}, colorNames{1+c1},statTest(1).w(1).P(iROI));
end

%% Plot results
% Plots statistical analysis group results
% Positioning factor for the * mark, depends on max data value at the given seed
starPosFactor   = 1.05;
% Font Sizes
axisFontSize    = 12;
starFontSize    = 22;
axMargin        = 1;
labelYaxis{1}   = 'HbT (a.u.)';
labelYaxis{2}   = 'SO_2 (%)';
statsNames = {'t' 'w'};
statsID = {'T-test' 'Wilcoxon'};
job.optFig.xAxisLabels = {'L' 'cc' 'R'};
for iStats = 2:numel(statsNames)
    y = [mean(shamleft) mean(LPSleft); mean(shamcc) mean(LPScc); mean(shamright) mean(LPSright) ];
    e = [std(shamleft) std(LPSleft); std(shamcc) std(LPScc); std(shamright) std(LPSright) ];
    % Show standard error bars instead of standard deviation
    if job.optFig.stderror
        sampleSize = ones(size(e));
        % First row: sham group
        sampleSize(:,1) = sampleSize(:,1) .* numel(shamcc);
        % Second row: LPS group
        sampleSize(:,2) = sampleSize(:,2) .* numel(LPScc);
        % std error bars: sigma/sqrt(N)
        e = e ./ sqrt(sampleSize);
    end
    
    if job.generate_figures
        % Display plots on new figure
        h = figure; set(gcf,'color','w')
        % Specify window units
        set(h, 'units', 'inches')
        % Change figure and paper size
        set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Custom bar graphs with error bars (1st arg: error)
        barwitherr(e, y)
        % Display colormap according to the contrast
        switch(c1)
            case 1
                % HbT contrast
                colormap([0.5 0.5 0.5; 1 1 1]);
            case 2
                % SO2 contrast
                colormap([0.25 0.25 0.25; 1 1 1]);
            case 3
                % B-mode contrast
                colormap([0 0 0; 1 1 1]);
            otherwise
                colormap(gray)
        end
%         
%         title(sprintf('C%d(%s) %s (*p<%.2g)',...
%             c1,colorNames{1+c1}, statsID{iStats}, job.optStat.alpha),'interpreter','none','FontSize',job.optFig.titleFontSize)
        set(gca,'FontSize',axisFontSize)
        ylabel(labelYaxis{c1},'FontSize',job.optFig.yLabelFontSize)
        set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
        if isfield(job.optFig.legends, 'legendShow')
            legend(job.optFig.legends.legendShow.legendStr,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
        end
%         set(gca, 'xLim', [1-axMargin size(y,1)+axMargin]);
        set(gca, 'xLim', [0.5 3.5]);
        if isfield(job.optFig.yLimits, 'yLimManual')
            set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
        end
        for iROI = 1:3
            % Show a * when a significant difference is found.
            if statTest(1).(statsNames{iStats})(1).P(iROI) <= job.optStat.alpha
                if max(e)>=0
                    yPos = starPosFactor*(max(y(iROI,:)) + max(e(iROI,:)));
                else
                    yPos = starPosFactor*(min(y(iROI,:)) - max(e(iROI,:)));
                end
                xPos = iROI;
                if statTest(1).(statsNames{iStats})(1).P(iROI) <= 0.001
                    starText = '***';
                elseif statTest(1).(statsNames{iStats})(1).P(iROI) <= 0.01
                    starText = '**';
                else
                    starText = '*';
                end
                text(xPos, yPos, starText, 'FontSize', starFontSize, 'FontWeight', 'b');
                fprintf('ROI %d , %sP=%0.4f\n', iROI, starText, statTest(1).(statsNames{iStats})(1).P(iROI));
            end
        end % ROIs loops
        if job.save_figures
            newName = sprintf('groupCorr_%c_C%d_(%s)',statsNames{iStats},c1,colorNames{1+c1});
            % Save as PNG
            print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
            % Save as a figure
            saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
            % Return the property to its default
            set(h, 'units', 'pixels')
            close(h)
        end
    end % end generate figures
end % stats loop

%% Find Fisher or x2 test sex confounding factor
tblID = {   '',     '';
            '',     '';
            '',     '';
            'NaCl', 'M';
            'NaCl', 'M';
            'NaCl', 'M';
            'NaCl', 'F';
            '',     'M';
            '',     'F';
            'NaCl', 'M';
            '',     '';
            'NaCl', 'M';
            'NaCl', 'M';
            'NaCl', 'M';
            '',     'M';
            '',     'M';
            '',     'M';
            '',     'M';
            'LPS',  'F';
            'LPS',  'M';
            'LPS',  'M';
            'LPS',  'M';
            'LPS',  'M';
            'LPS',  'M';
            'LPS',  'M';
            'LPS',  'F';
            'LPS',  'F';
            'LPS',  'F';
            'LPS',  'F';};
%       sham    LPS
% M     7       6
% F     1       5
tbl2x2 = [7 6;1 5];
Pm = pat_fisher_extest(tbl2x2, 'ne');
% EOF
