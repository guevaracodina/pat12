uiopen('F:\Edgar\Dropbox\Docs\PAT\Figures\PLoS One\DG_RS_C2(SO2)_R00_fig_scrub.fig',1)
h = gcf;
job.figSize = [7 5];
job.figRes = 300;
job.parent_results_dir{1} = 'F:\Edgar\Dropbox\Docs\PAT\Figures\PLoS One';
% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
drawnow
%% Print
% Save as PNG at the user-defined resolution
print(h, '-dtiff', ...
    fullfile(job.parent_results_dir{1}, 'figureS1'),...
    sprintf('-r%d',job.figRes));
