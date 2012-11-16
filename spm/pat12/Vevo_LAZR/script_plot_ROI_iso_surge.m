%% Load PAT ROIs timecourse
% pathName = 'D:\Edgar\Data\PAT_Data\PAT_CSV';
% fileName = fullfile(pathName,'2012-09-07-10-40-07.csv');
addpath(genpath('D:\spm8\toolbox\pat12'))
addpath(genpath('D:\Edgar\ssoct\Matlab'))


% Place optional args in memorable variable names
dataFolder = 'D:\Edgar\Data\PAT_Data\LPS_12_11_09';

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
tData = cell([size(roiList,1) 3]);
roiNames = cell([size(roiList,1) 3]);
subjectNames = cell([size(roiList,1) 1]);

%% Plot PAT ROIs timecourse
saveFigs = false;
seconds  = true;
for iFiles = 1:numel(roiList)
    [ROI mainHeader] = pat_import_csv(roiList{iFiles}, true);
    h = figure; set(gcf,'color','w')
    t1 = ROI(1).data(:, 2);
    r1 = ROI(1).data(:, 4);
    t2 = ROI(2).data(:, 2);
    r2 = ROI(2).data(:, 4);
    if seconds
        % Convert from ms to s
        t1 = t1/1000;
        t2 = t2/1000;
    end
    if numel(ROI) == 3
        t3 = ROI(3).data(:, 2);
        r3 = ROI(3).data(:, 4);
        roiNames{iFiles, 3} = ROI(3).name;
        if seconds
            % Convert from ms to s
            t3 = t3/1000;
        end
    else
        t3 = [];
        r3 = [];
    end
    % First column ROI 1
    roiData{iFiles,1} = r1;
    % Second column ROI 2
    roiData{iFiles,2} = r2;
    % Third column ROI 3
    roiData{iFiles,3} = r3;
    % First column ROI 1
    tData{iFiles,1} = t1;
    % Second column ROI 2
    tData{iFiles,2} = t2;
    % Third column ROI 3
    tData{iFiles,3} = t3;
    roiNames{iFiles, 1} = ROI(1).name;
    roiNames{iFiles, 2} = ROI(2).name;
%     % Find correlation (4th column)
%     roiData{iFiles,4} = corr(r1, r2);
%     % Find correlation (4th column)
%     roiData{iFiles,5} = corr(r1, r2);
%     % Find correlation (4th column)
%     roiData{iFiles,6} = corr(r1, r2);
    
    if seconds
        % Convert from ms to s
        t1 = t1/1000;
        t2 = t2/1000;
    end
    plot(t1, r1,'c.-','LineWidth',2); 
    hold on
    plot(t2, r2,'g.-','LineWidth',2)
    if seconds
        labelX = 'Relative time [s]';
    else
        labelX = ROI(1).header{2};
    end
    xlabel(labelX,'FontSize',14); 
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
    subjectNames{iFiles, 1} = [studyName ' - ' seriesName];
    [pathName fileName ext] = fileparts(roiList{iFiles, 1});
    title(subjectNames{iFiles, 1}, 'FontSize', 14, 'interpreter', 'none'); 
    if saveFigs
        export_fig(fullfile(dataFolder,fileName),'-png',gcf)
        saveas(h, fullfile(dataFolder, fileName), 'fig');
    end
    close(h)
end % Files loop


%% O2 surge CTL1
% protocol 1 min, 2 min, 2 min
% rat#
iRat = 1;
% Start of surge
o2begin = 60;
% End of surge
o2end = o2begin + 120;
saveFigs = true;
seconds  = true;
for iRat=1:3
    h = figure; set(gcf,'color','w')
    plot(tData{iRat, 1}, roiData{iRat, 1},'c.-','LineWidth',2);
    hold on
    plot(tData{iRat, 2}, roiData{iRat, 2},'g.-','LineWidth',2)
    limitsY = get(gca,'Ylim');
    plot([o2begin o2begin], limitsY,'k--','LineWidth',2)
    plot([o2end o2end], limitsY,'k--','LineWidth',2)
    if seconds
        labelX = 'Relative time [s]';
    else
        labelX = ROI(1).header{2};
    end
    xlabel(labelX,'FontSize',14);
    ylabel(ROI(1).header{4},'FontSize',14);
    % legend({roiNames{iRat, 1}, roiNames{iRat, 2}}); set(gca,'FontSize',12)
    legend({'Right Cortex', 'Left Cortex'}); set(gca,'FontSize',12)
    title(subjectNames{iRat, 1})
    
    % Find indices of O2 surge
    idxO2(1) = find(tData{iRat, 1} > o2begin, 1, 'first');
    idxO2(2) = find(tData{iRat, 1} > o2end, 1, 'first');
    % Correlation coefficient
    r(iRat,1) = corr(roiData{iRat, 1}(1:idxO2(1)), roiData{iRat, 2}(1:idxO2(1)));
    r(iRat,2) = corr(roiData{iRat, 1}(idxO2(1)+1:idxO2(2)), roiData{iRat, 2}(idxO2(1)+1:idxO2(2)));
    r(iRat,3) = corr(roiData{iRat, 1}(idxO2(2)+1:end), roiData{iRat, 2}(idxO2(2)+1:end));
    
    if saveFigs
        export_fig(fullfile(dataFolder,[subjectNames{iRat, 1} '_corr']),'-png',gcf)
        saveas(h, fullfile(dataFolder, [subjectNames{iRat, 1} '_corr']), 'fig');
    end
    close(h)
end
z = pat_fisherz(r);
%% O2 surge CTL2

%% O2 surge CTL3

% %% t-stat
% % Control group
% x = [roiData{4,3}; roiData{6,3}];
% % Treatment group
% y = [cell2mat(roiData(1:3,3)); cell2mat(roiData(5,3)); cell2mat(roiData(7:8,3))];
% % Convert tio Fisher's z
% x = fisherz(x);
% y = fisherz(y);
% alpha = 0.05;
% tail = 'both';
% vartype = 'unequal';
% [hyp, p, ci, stats] = ttest2(x, y, alpha, tail, vartype);
% 
% %% Plot errorbars
% h = figure; set(gcf,'color','w')
% % Control group
% testData(1,:) = nanmean(x);
% testError(1,:) = nanstd(x);
% % Treatment group
% testData(2,:) = nanmean(y);
% testError(2,:) = nanstd(y);
% % Custom bar graphs with error bars (1st arg: error)
% barwitherr(testError, testData);
% colormap([0.5 0.5 0.5; 1 1 1])
% % close(h)
% ylabel('Bilateral Functional correlation z(r)','FontSize',18)
% set(gca,'XTickLabel',{'Control', 'Rat Toe'},'FontWeight', 'b')
% set(gca,'FontSize',14)
% % legend({'Control' '4-AP'},'FontSize',12)
% %%
% % export_fig(fullfile('D:\Edgar\Documents\Dropbox\Docs\fcOIS\2012_10_29_Report', ['tTest_p' num2str(p)]),'-png',gcf)
% % close(h)
