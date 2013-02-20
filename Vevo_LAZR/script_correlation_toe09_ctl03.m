%% Correlation example toe09
load('E:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\Bmode\BrainMask\ROI\LPF\ROItimeCourse\BPF\GLMfcPAT\PAT.mat')
load(PAT.ROI.ROIfname)
load(PAT.fcPAT.filtNdown.fname)
load(PAT.fcPAT.SPM.fnameROIregress)
colorNames = fieldnames(PAT.color);
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
scanName = splitStr{end-1};
clc
fprintf('\nCorrelation coefficients for %s \n', scanName);
for c1 = 1:2
    for r1 = 1
        fprintf('Raw data r = %f (%s)\n', corr(ROI{r1}{1,c1}', ROI{r1+1}{1,c1}'), colorNames{c1+1});
        fprintf('Filtered data r = %f (%s)\n', corr(filtNdownROI{r1}{1,c1}', filtNdownROI{r1+1}{1,c1}'), colorNames{c1+1});
        fprintf('Regressed data r = %f (%s)\n', corr( ROIregress{r1}{1,c1}',  ROIregress{r1+1}{1,c1}'), colorNames{c1+1});
    end
end

% ctl03
% load('E:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\GLMfcPAT\PAT.mat');
load('E:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\newROIs\PAT.mat')
load(PAT.ROI.ROIfname)
load(PAT.fcPAT.filtNdown.fname)
load(PAT.fcPAT.SPM.fnameROIregress)
colorNames = fieldnames(PAT.color);
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
scanName = splitStr{end-1};
fprintf('\nCorrelation coefficients for %s \n', scanName);
for c1 = 1:2
    for r1 = 1
        fprintf('Raw data r = %f (%s)\n', corr(ROI{r1}{1,c1}', ROI{r1+1}{1,c1}'), colorNames{c1+1});
        fprintf('Filtered data r = %f (%s)\n', corr(filtNdownROI{r1}{1,c1}', filtNdownROI{r1+1}{1,c1}'), colorNames{c1+1});
        fprintf('Regressed data r = %f (%s)\n', corr( ROIregress{r1}{1,c1}',  ROIregress{r1+1}{1,c1}'), colorNames{c1+1});
    end
end

% EOF


