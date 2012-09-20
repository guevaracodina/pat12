%% Load PAT ROIs timecourse
pathName = 'D:\Edgar\Data\PAT_Data\PAT_CSV';
fileName = fullfile(pathName,'2012-09-07-10-40-07.csv');
[ROI mainHeader] = pat_import_csv(fileName);

%% Plot PAT ROIs timecourse
figure; plot(1e-3*ROI(1).data(:, 2),ROI(1).data(:, 4),'c.-'); 
xlabel('time [s]'); ylabel(ROI(1).header{4}); hold on
plot(1e-3*ROI(2).data(:, 2),ROI(2).data(:, 4),'g.-')
legend({ROI(1).name, ROI(2).name})
