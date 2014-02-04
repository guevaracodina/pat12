%% load data
load('F:\Edgar\Data\PAT_Results\ctl01_ISO\BPF\PAT.mat')
load('F:\Edgar\Data\PAT_Results\ctl01_ISO\BPF\ROIregress.mat')

%% Time vector
TR = pat_get_TR(PAT);
t1 = 180; % in seconds
t2 = 240; % in seconds
t = 0:TR:TR*(numel(ROIregress{1}{2})-1);
idxT = find(t>t1, 1, 'first');
idxT2 = find(t>t2, 1, 'first');

%% Correlation values
clc
% ROI 1 & 2
r1 = 1; r2 = 2;
% Color SO2
c1 = 2;
corr_before_M = corr(ROIregress{r1}{c1}(1:idxT)', ROIregress{r2}{c1}((1:idxT))');
fprintf('Correlation coefficient between %06.2f and %06.2f s. r = %0.4f Seeds: %s & %s\n',t(1), t(idxT), corr_before_M, PAT.ROI.ROIname{r1}, PAT.ROI.ROIname{r2});
corr_after_M = corr(ROIregress{r1}{c1}(idxT2:end)', ROIregress{r2}{c1}((idxT2:end))');
fprintf('Correlation coefficient between %06.2f and %06.2f s. r = %0.4f Seeds: %s & %s\n', t(idxT2), t(end),  corr_after_M, PAT.ROI.ROIname{r1}, PAT.ROI.ROIname{r2});
% ROI 3 & 4
r1 = 3; r2 = 4;
corr_before_S1BF = corr(ROIregress{r1}{c1}(1:idxT)', ROIregress{r2}{c1}((1:idxT))');
fprintf('\nCorrelation coefficient between %06.2f and %06.2f s. r = %0.4f Seeds: %s & %s\n',t(1), t(idxT), corr_before_S1BF, PAT.ROI.ROIname{r1}, PAT.ROI.ROIname{r2});
corr_after_S1BF = corr(ROIregress{r1}{c1}(idxT2:end)', ROIregress{r2}{c1}((idxT2:end))');
fprintf('Correlation coefficient between %06.2f and %06.2f s. r = %0.4f Seeds: %s & %s\n', t(idxT2), t(end),  corr_after_S1BF, PAT.ROI.ROIname{r1}, PAT.ROI.ROIname{r2});

%% Print figure
% set(h, 'Position', [0.1 0.1 5 3]); set(h, 'PaperPosition', [0.1 0.1 5 3]);
% print(2, '-dpng', fullfile('F:\Edgar\Data\PAT_Results\ctl01_ISO\BPF','correlation.png'), sprintf('-r%d',300));

% EOF
