%% Load PAT ROIs timecourse
% pathName = 'D:\Edgar\Data\PAT_Data\PAT_CSV';
% fileName = fullfile(pathName,'2012-09-07-10-40-07.csv');
addpath(genpath('D:\spm8\toolbox\pat12'))
addpath(genpath('D:\Edgar\ssoct\Matlab'))


% Place optional args in memorable variable names
dataFolder = 'D:\Edgar\Data\PAT_Data\PAT_CSV';

% Check if dataFolder is a valid directory, else get current working dir
if ~exist(dataFolder,'dir')
    dataFolder = pwd;
end

% Separate subdirectories and files:
d = dir(dataFolder);
isub = [d(:).isdir];            % Returns logical vector
folderList = {d(isub).name}';
% Remove . and ..
folderList(ismember(folderList,{'.','..'})) = [];

%% Choose the subjects folders
cd(dataFolder);
[roiList, sts] = cfg_getfile(Inf,'any','Select ROI files',folderList, dataFolder, '.*(.csv)$');
roiData = cell([size(roiList,1) 3]);

%% Plot PAT ROIs timecourse
for iFiles = 1:numel(roiList)
    [ROI mainHeader] = pat_import_csv(roiList{iFiles}, true);
    h = figure; set(gcf,'color','w')
    t1 = ROI(1).data(:, 2);
    r1 = ROI(1).data(:, 4);
    t2 = ROI(2).data(:, 2);
    r2 = ROI(2).data(:, 4);
    % First column ROI 1
    roiData{iFiles,1} = r1;
    % Second column ROI 2
    roiData{iFiles,2} = r2;
    % Find correlation (3rd column)
    roiData{iFiles,3} = corr(r1, r2);
    
    plot(t1, r1,'c.-','LineWidth',2); hold on
    plot(t2, r2,'g.-','LineWidth',2)
    xlabel(ROI(1).header{2},'FontSize',14); 
    ylabel(ROI(1).header{4},'FontSize',14); 
    legend({ROI(1).name, ROI(2).name}); set(gca,'FontSize',12)

    % Find study and series name
    for iLines = 1:numel(mainHeader)
        [startIndex, endIndex, ~, ~, ~, ~, splitStr] = ...
            regexp(mainHeader{iLines}, '^("Study Name",")', 'once');
        if ~isempty(startIndex) && ~isempty(endIndex)
            studyName = splitStr{end}(1:end-1);
        end
        [startIndex, endIndex, ~, ~, ~, ~, splitStr] = ...
            regexp(mainHeader{iLines}, '^("Series Name",")', 'once');
        if ~isempty(startIndex) && ~isempty(endIndex)
            seriesName = splitStr{end}(1:end-1);
        end
    end
    roiNames{iFiles, 1} = [studyName ' - ' seriesName];
    title(roiNames{iFiles, 1}, 'FontSize', 14, 'interpreter', 'none'); 
%     export_fig(fullfile('D:\Edgar\Documents\Dropbox\Docs\fcOIS\2012_10_29_Report', roiNames{iFiles, 1}),'-png',gcf)
    close(h)
end % Files loop


%% t-stat
% Control group
x = [roiData{4,3}; roiData{6,3}];
% Treatment group
y = [cell2mat(roiData(1:3,3)); cell2mat(roiData(5,3)); cell2mat(roiData(7:8,3))];
% Convert tio Fisher's z
x = fisherz(x);
y = fisherz(y);
alpha = 0.05;
tail = 'both';
vartype = 'unequal';
[hyp, p, ci, stats] = ttest2(x, y, alpha, tail, vartype);

%% Plot errorbars
h = figure; set(gcf,'color','w')
% Control group
testData(1,:) = nanmean(x);
testError(1,:) = nanstd(x);
% Treatment group
testData(2,:) = nanmean(y);
testError(2,:) = nanstd(y);
% Custom bar graphs with error bars (1st arg: error)
barwitherr(testError, testData);
colormap([0.5 0.5 0.5; 1 1 1])
% close(h)
ylabel('Bilateral Functional correlation z(r)','FontSize',18)
set(gca,'XTickLabel',{'Control', 'Rat Toe'},'FontWeight', 'b')
set(gca,'FontSize',14)
% legend({'Control' '4-AP'},'FontSize',12)
%%
% export_fig(fullfile('D:\Edgar\Documents\Dropbox\Docs\fcOIS\2012_10_29_Report', ['tTest_p' num2str(p)]),'-png',gcf)
% close(h)
