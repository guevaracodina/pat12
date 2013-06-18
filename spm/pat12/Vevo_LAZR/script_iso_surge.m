%% script_iso_surge
job.parent_results_dir{1} ='F:\Edgar\Data\PAT_Results_20130517\IsoSurge\';
load(fullfile(job.parent_results_dir{1}, 'group_data.mat'))
job.optFig.titleFontSize = 10;
job.optFig.yLabelFontSize = 10;
job.optFig.xLabelFontSize = 10;
axisFontSize    = 10;
starFontSize    = 22;
axMargin        = 0.5;
job.optFig.figSize = [3.25 3.25];
newName = 'IsoSurgeResults';
job.optFig.legends.legendShow.legendFontSize = 10;
job.optFig.xAxisLabels = {'M', 'S1', 'S1BF'};
job.optFig.figRes = 300;
% signrank is the non-parametric equivalent to the paired t-test
%% Display plots on new figure
h = figure; set(gcf,'color','w')
% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
% Custom bar graphs with error bars (1st arg: error)
e = e/sqrt(size(e,1));
barwitherr(e, y)
% SO2 contrast
colormap([0.25 0.25 0.25; 1 1 1]);
title('','interpreter','none','FontSize',job.optFig.titleFontSize)
set(gca,'FontSize',axisFontSize)
ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
legend({'Iso 1.8%', 'Iso 3.5%'},'FontSize',job.optFig.legends.legendShow.legendFontSize,'location','northeast')
set(gca, 'xLim', [axMargin size(y,1) + axMargin]);

%%
% Save as PNG
print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
% Save as a figure
saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
% Return the property to its default
set(h, 'units', 'pixels')
close(h)
% EOF
