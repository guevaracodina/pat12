%% Load PAT ROIs timecourse
pathName = 'D:\Edgar\Data\PAT_Data\PAT_CSV';
fileName = fullfile(pathName,'2012-09-07-10-40-07.csv');
addpath(genpath('D:\spm8\toolbox\pat12'))
[ROI mainHeader] = pat_import_csv(fileName);

%% Plot PAT ROIs timecourse
figure; set(gcf,'color','w')
plot(ROI(1).data(:, 2),ROI(1).data(:, 4),'c.-','LineWidth',2); hold on
plot(ROI(2).data(:, 2),ROI(2).data(:, 4),'g.-','LineWidth',2)
xlabel(ROI(1).header{2},'FontSize',14); 
ylabel(ROI(1).header{4},'FontSize',14); 
legend({ROI(1).name, ROI(2).name}); set(gca,'FontSize',12)
% print(gcf, '-dpng', fullfile('D:\Edgar\Documents\Dropbox\Docs\fcOIS\2012_09_24_Report','PAT_ROI'), '-r300');
