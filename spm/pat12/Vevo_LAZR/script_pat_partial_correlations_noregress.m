% script_pat_partial_correlations
ctrlNoRegress = nan([3 9]);
lpsNoRegress =  nan([3 9]);
c1 = 2;
INTERP = true;
clc;
fprintf('Bilateral correlation without global signal regression\n')

%% 2012-09-07-14-48-55_ctl02 7:8, 175:180, 192:200
load('F:\Edgar\Data\PAT_Results\2012-09-07-14-48-55_ctl02\seedRadius14\BPF\PAT.mat')
load(PAT.fcPAT.filtNdown.fname)
% scan name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
TR = PAT.fcPAT.filtNdown.TR;
% partial correlations
idx = 9:174;
% interpolation
if INTERP
    N = numel(filtNdownROI{1}{c1});
    xi = 1:N;
    x = [1:6, 9:174, 181:191, 201:N];
    idx = 1:N;
end
fprintf('%s, correlation computed for ~ %.0f s.\n',splitStr{end-1}, TR*numel(idx));
for iROI=1:2:18,
    if INTERP
        % ROI odd
        y = filtNdownROI{iROI}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI}{c1} = yi;
        % ROI even
        y = filtNdownROI{iROI+1}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI+1}{c1} = yi;
    end
    ctrlNoRegress(1, (iROI+1)/2) = corr(filtNdownROI{iROI}{c1}(idx)', filtNdownROI{iROI+1}{c1}(idx)');
end

%% 2012-11-09-16-18-31_ctl03 122:127, 190:193
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\seedRadius10\PAT.mat')
load(PAT.fcPAT.filtNdown.fname)
% scan name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
TR = PAT.fcPAT.filtNdown.TR;
% partial correlations
idx = 128:189;
% interpolation
if INTERP
    N = numel(filtNdownROI{1}{c1});
    xi = 1:N;
    x = [1:121, 128:189, 194:N];
    idx = 1:N;
end
fprintf('%s, correlation computed for ~ %.0f s.\n',splitStr{end-1}, TR*numel(idx))
for iROI=1:2:18,
    if INTERP
        % ROI odd
        y = filtNdownROI{iROI}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI}{c1} = yi;
        % ROI even
        y = filtNdownROI{iROI+1}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI+1}{c1} = yi;
    end
    ctrlNoRegress(2, (iROI+1)/2) = corr(filtNdownROI{iROI}{c1}(idx)', filtNdownROI{iROI+1}{c1}(idx)');
end

%% 2012-11-09-16-21-53_ctl01 194:199, 213
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-21-53_ctl01\seedRadius10\PAT.mat')
load(PAT.fcPAT.filtNdown.fname)
% scan name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
TR = PAT.fcPAT.filtNdown.TR;
% partial correlations
idx = 1:193;
% interpolation
if INTERP
    N = numel(filtNdownROI{1}{c1});
    xi = 1:N;
    x = [1:193, 200:212, 214:N];
    idx = 1:N;
end
fprintf('%s, correlation computed for ~ %.0f s.\n',splitStr{end-1}, TR*numel(idx))
for iROI=1:2:18,
    if INTERP
        % ROI odd
        y = filtNdownROI{iROI}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI}{c1} = yi;
        % ROI even
        y = filtNdownROI{iROI+1}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI+1}{c1} = yi;
    end
    ctrlNoRegress(3, (iROI+1)/2) = corr(filtNdownROI{iROI}{c1}(idx)', filtNdownROI{iROI+1}{c1}(idx)');
end

%% 2012-11-09-16-23-04_toe08 None
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-23-04_toe08\seedRadius10\PAT.mat')
load(PAT.fcPAT.filtNdown.fname)
% scan name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
TR = PAT.fcPAT.filtNdown.TR;
% partial correlations
idx = 1:222;
% interpolation
if INTERP
    N = numel(filtNdownROI{1}{c1});
    xi = 1:N;
    x = 1:N;
    idx = 1:N;
end
fprintf('%s, correlation computed for ~ %.0f s.\n',splitStr{end-1}, TR*numel(idx))
for iROI=1:2:18,
    if INTERP
        % ROI odd
        y = filtNdownROI{iROI}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI}{c1} = yi;
        % ROI even
        y = filtNdownROI{iROI+1}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI+1}{c1} = yi;
    end
    lpsNoRegress(1, (iROI+1)/2) = corr(filtNdownROI{iROI}{c1}(idx)', filtNdownROI{iROI+1}{c1}(idx)');
end

%% 2012-11-09-16-23-51_toe09 4:5, 50, 74:76, 107
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\seedRadius10\PAT.mat')
load(PAT.fcPAT.filtNdown.fname)
% scan name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
TR = PAT.fcPAT.filtNdown.TR;
% partial correlations
idx = 108:219;
% interpolation
if INTERP
    N = numel(filtNdownROI{1}{c1});
    xi = 1:N;
    x = [1:3, 6:49, 51:73, 77:106, 108:N];
    idx = 1:N;
end
fprintf('%s, correlation computed for ~ %.0f s.\n',splitStr{end-1}, TR*numel(idx))
for iROI=1:2:18,
    if INTERP
        % ROI odd
        y = filtNdownROI{iROI}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI}{c1} = yi;
        % ROI even
        y = filtNdownROI{iROI+1}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI+1}{c1} = yi;
    end
    lpsNoRegress(2, (iROI+1)/2) = corr(filtNdownROI{iROI}{c1}(idx)', filtNdownROI{iROI+1}{c1}(idx)');
end

%% 2012-11-09-16-16-25_toe04	115:116, 189:190, 221:222, 263
load('F:\Edgar\Data\PAT_Results\2012-11-09-16-16-25_toe04\seedRadius10\PAT.mat')
load(PAT.fcPAT.filtNdown.fname)
% scan name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
TR = PAT.fcPAT.filtNdown.TR;
% partial correlations
idx = 1:114;
% interpolation
if INTERP
    N = numel(filtNdownROI{1}{c1});
    xi = 1:N;
    x = [1:114, 117:188, 191:220, 223:262, 264:N];
    idx = 1:N;
end
fprintf('%s, correlation computed for ~ %.0f s.\n',splitStr{end-1}, TR*numel(idx))
for iROI=1:2:18,
    if INTERP
        % ROI odd
        y = filtNdownROI{iROI}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI}{c1} = yi;
        % ROI even
        y = filtNdownROI{iROI+1}{c1}(x);
        yi = interp1(x, y, xi);
        filtNdownROI{iROI+1}{c1} = yi;
    end
    lpsNoRegress(3, (iROI+1)/2) = corr(filtNdownROI{iROI}{c1}(idx)', filtNdownROI{iROI+1}{c1}(idx)');
end


%% Stats
mCtrl = mean(ctrlNoRegress);
semCtrl = std(ctrlNoRegress)/sqrt(size(ctrlNoRegress,1));
mLPS = mean(lpsNoRegress);
semLPS = std(lpsNoRegress)/sqrt(size(lpsNoRegress,1));

%% Graph display
close all; h = figure;
% ROI pairs to display
idxROI = 1:5;
figSize = [0.1 0.1 11 8.5];
fontSize = 20;
set(h, 'color', 'w')
barwitherr([semCtrl(idxROI)', semLPS(idxROI)'], [mCtrl(idxROI)', mLPS(idxROI)']);
colormap([0.5 0.5 0.5; 1 1 1])
ylabel('Bilateral correlation (r)', 'FontSize', fontSize, 'FontWeight', 'b');
ROIlabels  = {                  'Cg'      % Cingulate cortex
    'M'       % Motor cortex
    'S1HL'    % hindlimb primary somatosensory cortex
    'S1FL'    % forelimb primary somatosensory cortex
    'S1BF'    % barrel field primary somatosensory cortex
    'S2'      % secondary somatosensory cortex
    'cc'      % corpus callosum
    'LV'      % Lateral ventricle
    'CPu'}';  % Caudate putamen
set(gca, 'XTickLabel', ROIlabels(idxROI), 'FontSize', fontSize, 'FontWeight', 'b');
set(gca, 'FontSize', fontSize, 'FontWeight', 'b');
legend({'Ctrl' 'LPS'}, 'FontSize', fontSize, 'FontWeight', 'b');
ylim([-0.4 0.9]);

%% Print figure
set(h, 'units', 'inches')
set(h, 'Position', figSize); set(h, 'PaperPosition', figSize);
dirName = 'F:\Edgar\Data\PAT_Results\PAS2013\interp6rats';
newName = 'PAS2013_bilateral_correlation_noregress';
set(h,'Name',newName);
print(h, '-dpng', fullfile(dirName,newName), sprintf('-r%d',300));
% Save as a figure
saveas(h, fullfile(dirName,newName), 'fig');
close(h);

% EOF
