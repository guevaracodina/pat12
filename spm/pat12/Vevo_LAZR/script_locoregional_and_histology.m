%% script corpus callosum and left/right cortex
clear; clc
% Only SO2 c1=2
c1 = 2;
% load data
load('E:\Edgar\Dropbox\Docs\PAT\Histo\AvgVesselLength.mat')
load ('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\LeftCortex\locoregional_SO2_data')
LPSidx = [5:11];
NaClidx = [4:7 10 12:14];
LPSleft = LPS(LPSidx);
shamleft = AvgCtrl(NaClidx,2);
% Parent directory
job.parent_results_dir{1} = 'E:\Edgar\Dropbox\Docs\PAT\Histo';
% save figures
job.save_figures = false;
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

%% Plot correlation between SO2 and histology measures
close all
h=figure; set(h,'color','w')
% Font sizes
axisFont = 12;
textFont = 12;
axisLabelFont = 12;
dottedLineWidth = 2;
markSize = 10;

plotType = 'ks';
lineType = 'k--';
plot(NaCl_L, shamleft, plotType, 'LineWidth', dottedLineWidth, 'MarkerSize', markSize)
% Measure of correlation r^2
[R(1) pVals(1)] = corr(NaCl_L, shamleft);
R2(1) = R(1) .^ 2;
% fit data to a 1st degree polynomial
pfit = polyfit(NaCl_L, shamleft,1);
f = polyval(pfit, NaCl_L);
hold on
% plot(NaCl_L, f, lineType, 'LineWidth', dottedLineWidth)

plotType = 'ro';
lineType = 'r:';
plot(LPS_L, LPSleft, plotType, 'LineWidth', dottedLineWidth, 'MarkerSize', markSize,'MarkerFaceColor','r')
% Measure of correlation r^2
[R(2) pVals(2)] = corr(LPS_L, LPSleft);
R2(2) = R(2) .^ 2;
% fit data to a 1st degree polynomial
pfit = polyfit(LPS_L, LPSleft,1);
f = polyval(pfit, LPS_L);
hold on
% plot(LPS_L, f, lineType, 'LineWidth', dottedLineWidth)

plotType = 'b^';
lineType = 'b-';

% Measure of correlation r^2
[R(3) pVals(3)] = corr([NaCl_L; LPS_L], [shamleft; LPSleft]);
R2(3) = R(3) .^ 2;
% fit data to a 1st degree polynomial
pfit = polyfit([NaCl_L; LPS_L], [shamleft; LPSleft],1);
f = polyval(pfit, [NaCl_L; LPS_L]);
hold on
plot([NaCl_L; LPS_L], f, lineType, 'LineWidth', dottedLineWidth)

fprintf('\t\t r^2 \t\t p\n NaCl \t %0.4f \t %0.4f\n LPS  \t %0.4f \t %0.4f\n All  \t %0.4f \t %0.4f\n',...
    R2(1),pVals(1),R2(2),pVals(2),R2(3),pVals(3));
set(gca,'FontSize',axisFont);
xlabel('Average length (A.U.)','FontSize',axisLabelFont);
ylabel('Average SO_2 (%)','FontSize',axisLabelFont);
% legend({'NaCl';'NaCl fit';'LPS';'LPS fit';'All fit'})
legend({'NaCl';'LPS';'Linear fit'})
text(83, 57.3, sprintf('r^2=%0.4f *p=%0.4f', R2(3),pVals(3)),...
                    'FontSize', textFont, 'FontWeight', 'b', 'Color', 'k')
                
job.figSize = [3.5 3.5];
job.figRes = 300;

% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])

%% Print
% Save as PNG at the user-defined resolution
print(h, '-dpng', ...
    fullfile(job.parent_results_dir{1}, 'length_vs_so2'),...
    sprintf('-r%d',job.figRes));

% EOF
