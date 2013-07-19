function out = pat_group_corr_unpaired_run(job)
% Performs a group comparison based on bilateral correlation between seeds
% time-courses, though a paired t-test data on the correlation before the 4-AP
% injection and its value after the epileptogenic injection. Performs the t-test
% for each pair of seeds.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmatCtrl;
% return
% ------------------------------------------------------------------------------

% For each scan:
% - choose the pairs of ROIs (1-2, 3-4, ..., 11-12 by default) (batch)
% for each color
%   - get the seed-to-seed correlation matrix
%   - transform Pearson's r to Fisher's z
%   - choose only 6 values for each mouse, each color
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% For all the subjects
% - Choose parent folder (batch)
% - Do a separate statistical for each seed data (paired t-test, wil)
% - Display a graph with ROI labels
% - Save a .csv file in parent folder for each contrast

% Concatenate all PAT matrices
job.PATmat = cat(1, job.PATmatCtrl, job.PATmatLPS);

% Load first PAT matrix to check the number of colors
[PAT PATmat dir_patmat] = pat_get_PATmat(job,1);

% Initialize cell to hold group data {pairs_of_seeds, nColors}
groupCorrData = cell([size(job.paired_seeds, 1) numel(PAT.color.eng)]);
groupCorrIdx = cell([size(job.paired_seeds, 1) numel(PAT.color.eng)]);

% Process data from the derivative of the seeds time course
if isfield (job.optStat,'derivative')
    groupCorrDataDiff = cell([size(job.paired_seeds, 1) numel(PAT.color.eng)]);
end

% Process raw data from the seeds time course
if isfield (job.optStat,'rawData')
    groupCorrDataRaw = cell([size(job.paired_seeds, 1) numel(PAT.color.eng)]);
end

% Create parent results directory if it does not exist
if ~exist(job.parent_results_dir{1},'dir'), mkdir(job.parent_results_dir{1}); end

%% Multiple comparisons adjustment
switch job.optStat.multComp
    case 0
        % No correction
        fprintf('No adjustment for multiple comparisons\n')
    case 1
        % Bonferroni
        fprintf('Bonferroni adjustment for multiple comparisons\n')
        job.optStat.alpha = job.optStat.alpha ./ size(job.paired_seeds, 1);
    case 2
        fprintf('FDR adjustment for multiple comparisons\n')
        % Do nothing for the moment
    otherwise
        % Do nothing
end


%% Big loop over scans
for scanIdx = 1:numel(job.PATmat)
    try
        tic
        %Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job, scanIdx);
        if ~isfield(PAT.fcPAT.corr,'corrMatrixOK') % correlation matrix OK
            disp(['No seed-to-seed correlation matrix available for subject ' int2str(scanIdx) ' ... skipping correlation map']);
        else
            if ~isfield(PAT.jobsdone,'corrGroupOK') || job.force_redo
                [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
                scanName = splitStr{end-1};
                % Get colors to include information
                IC = job.IC;
                colorNames = fieldnames(PAT.color);
                % File name where correlation data is saved
                PAT.fcPAT.corr(1).fnameGroup = fullfile(job.parent_results_dir{1},'group_corr_pair_seeds.mat');
                % File name where correlation data of 1st derivative is saved
                if isfield(job.optStat,'derivative')
                    PAT.fcPAT.corr(1).fnameGroupDiff = fullfile(job.parent_results_dir{1},'group_corr_pair_seeds_diff.mat');
                end
                if isfield(job.optStat, 'rawData')
                    PAT.fcPAT.corr(1).fnameGroupRaw = fullfile(job.parent_results_dir{1},'group_corr_pair_seeds_raw.mat');
                end
                % Check if mouse is tratment (1) or control (0)
                if any(scanIdx <= 1:numel(job.PATmatCtrl))
                    % It is a control
                    isTreatment(scanIdx,1) = false;
                else
                    % It is a LPS
                    isTreatment(scanIdx,1) = true;
                end
                % Treatment/control sessions is always 1
                idxSess(1,1:2) = 1;
                % Additional 3rd column with subject index
                idxSess(:,3) = scanIdx;
                % Get the seed-to-seed correlation matrix (seed2seedCorrMat)
                load(PAT.fcPAT.corr.corrMatrixFname)
                if isfield (job.optStat,'derivative')
                    if job.optStat.derivative
                        % Get the seed-to-seed correlation of 1st derivative matrix
                        % (seed2seedCorrMatDiff)
                        load(PAT.fcPAT.corr.corrMatrixDiffFname)
                    end
                end
                if isfield(job.optStat, 'rawData')
                    if job.optStat.rawData
                        % Compute the seed-to-seed correlation of raw data
                        [seed2seedCorrMatRaw PAT.fcPAT.corr(1).corrMatrixRawFname] = pat_roi_corr_raw(job,scanIdx);
                        % Save seed-to-seed correlation data
                        save(PAT.fcPAT.corr(1).corrMatrixRawFname, 'seed2seedCorrMatRaw')
                    end
                end
                % Initialize cell to hold paired seeds correlation data
                pairedSeeds = cell([size(job.paired_seeds, 1) 1]);
                for iCell = 1:size(job.paired_seeds, 1),
                    pairedSeeds{iCell} = cell([1 numel(PAT.color.eng)]);
                    if isfield (job.optStat,'derivative')
                        pairedSeedsDiff{iCell} = cell([1 numel(PAT.color.eng)]);
                    end
                    if isfield (job.optStat,'rawData')
                        pairedSeedsRaw{iCell} = cell([1 numel(PAT.color.eng)]);
                    end
                    % Get paired ROIs names
                    pairedSeedsNames{scanIdx,1}{iCell,1} = [PAT.ROI.ROIname{job.paired_seeds(iCell,1)} ' & ' PAT.ROI.ROIname{job.paired_seeds(iCell,2)}];
                    subjectName{scanIdx,1}{iCell,1} = scanName;
                    groupID{scanIdx,1}{iCell,1} = isTreatment(scanIdx,1);
                end % paired seeds loop
                
                % Loop over available colors
                for c1 = 1:size(PAT.nifti_files,2)
                    doColor = pat_doColor(PAT,c1,IC);
                    if doColor
                        % Loop over sessions
                        for s1 = 1,
                            % Get current correlation matrix
                            currCorrMat = seed2seedCorrMat{1}{s1,c1};
                            % transform Pearson's r to Fisher's z
                            currCorrMat = fisherz(currCorrMat);
                            for iROI = 1:size(job.paired_seeds, 1)
                                % Need to check this for every seed pair //EGC
                                if isempty(currCorrMat)
                                    pairedSeeds{iROI}{s1,c1} = NaN;
                                elseif isnan(currCorrMat(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2))) || isempty(currCorrMat(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2)))
                                    pairedSeeds{iROI}{s1,c1} = NaN;
                                else
                                    % choose only 6 values for each mouse, each color
                                    pairedSeeds{iROI}{s1,c1} = currCorrMat(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2));
                                end
                            end % paired ROIs loop
                            if isfield (job.optStat,'derivative')
                                if job.optStat.derivative
                                    % Get current correlation matrix
                                    currCorrMatDiff = seed2seedCorrMatDiff{1}{s1,c1};
                                    % transform Pearson's r to Fisher's z
                                    currCorrMatDiff = pat_fisherz(currCorrMatDiff);
                                    for iROI = 1:size(job.paired_seeds, 1)
                                        % Need to check this for every seed pair //EGC
                                        if isempty(currCorrMatDiff)
                                            pairedSeedsDiff{iROI}{s1,c1} = NaN;
                                        elseif isnan(currCorrMatDiff(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2))) || isempty(currCorrMatDiff(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2)))
                                            pairedSeedsDiff{iROI}{s1,c1} = NaN;
                                        else
                                            % choose only 6 values for each mouse, each color
                                            pairedSeedsDiff{iROI}{s1,c1} = currCorrMatDiff(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2));
                                        end
                                    end % paired ROIs loop
                                end
                            end % derivative
                            if isfield (job.optStat,'rawData')
                                if job.optStat.rawData
                                    % Get current correlation matrix
                                    currCorrMatRaw = seed2seedCorrMatRaw{1}{s1,c1};
                                    % transform Pearson's r to Fisher's z
                                    currCorrMatRaw = pat_fisherz(currCorrMatRaw);
                                    for iROI = 1:size(job.paired_seeds, 1)
                                        % Need to check this for every seed pair //EGC
                                        if isempty(currCorrMatRaw)
                                            pairedSeedsRaw{iROI}{s1,c1} = NaN;
                                        elseif isnan(currCorrMatRaw(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2))) || isempty(currCorrMatRaw(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2)))
                                            pairedSeedsRaw{iROI}{s1,c1} = NaN;
                                        else
                                            % choose only 6 values for each mouse, each color
                                            pairedSeedsRaw{iROI}{s1,c1} = currCorrMatRaw(job.paired_seeds(iROI,1), job.paired_seeds(iROI,2));
                                        end
                                    end % paired ROIs loop
                                end
                            end % raw time course
                        end % sessions loop
                        % Arrange the paired seeds according to idxSessions
                        fprintf('Retrieving data %s C%d (%s)...\n',scanName, c1,colorNames{1+c1});
                        tmpArray = zeros([size(job.paired_seeds, 1), 1]);
                        if isfield (job.optStat,'derivative')
                            if job.optStat.derivative
                                tmpArrayDiff = zeros([size(job.paired_seeds, 1), 1]);
                            end
                        end
                        if isfield (job.optStat,'rawData')
                            if job.optStat.rawData
                                tmpArrayRaw = zeros([size(job.paired_seeds, 1), 1]);
                            end
                        end
                        for iROI = 1:size(job.paired_seeds, 1)
                            for iSess = 1:size(idxSess, 1)
                                tmpArray(iROI,iSess,1) = pairedSeeds{iROI}{idxSess(iSess,1), c1};
                                if isfield (job.optStat,'derivative')
                                    if job.optStat.derivative
                                        tmpArrayDiff(iROI,iSess,1) = pairedSeedsDiff{iROI}{idxSess(iSess,1), c1};
                                    end
                                end
                                if isfield (job.optStat,'rawData')
                                    if job.optStat.rawData
                                        tmpArrayRaw(iROI,iSess,1) = pairedSeedsRaw{iROI}{idxSess(iSess,1), c1};
                                    end
                                end
                            end % sessions loop
                        end % paired-seeds loop
                        for iROI = 1:size(job.paired_seeds, 1)
                            % Full group index
                            groupCorrIdx{iROI,c1} = [groupCorrIdx{iROI,c1}; scanIdx];
                            % if c1 == 8
                            %    fprintf('\ntmpArray = %f Subject: %d (%s)\n', squeeze(tmpArray(iROI,:,:)), scanIdx, scanName);
                            % end
                            if ~isempty(squeeze(tmpArray(iROI,:,:)))
                                % Full group data
                                groupCorrData{iROI,c1} = [groupCorrData{iROI,c1}; squeeze(tmpArray(iROI,:,:))];
                            else
                                groupCorrData{iROI,c1} = [groupCorrData{iROI,c1}; NaN];
                            end
                            if isfield (job.optStat,'derivative')
                                if job.optStat.derivative
                                    if ~isempty(squeeze(tmpArrayDiff(iROI,:,:)))
                                        groupCorrDataDiff{iROI,c1} = [groupCorrDataDiff{iROI,c1}; squeeze(tmpArrayDiff(iROI,:,:))];
                                    else
                                        groupCorrDataDiff{iROI,c1} = [groupCorrDataDiff{iROI,c1}; NaN];
                                    end
                                end
                            end
                            if isfield (job.optStat,'rawData')
                                if job.optStat.rawData
                                    if ~isempty(squeeze(tmpArrayRaw(iROI,:,:)))
                                        groupCorrDataRaw{iROI,c1} = [groupCorrDataRaw{iROI,c1}; squeeze(tmpArrayRaw(iROI,:,:))];
                                    else
                                        groupCorrDataRaw{iROI,c1} = [groupCorrDataRaw{iROI,c1}; NaN];
                                    end
                                end
                            end
                        end % paired-seeds loop
                    end
                end % colors loop
                % Save group correlation data data (data is appended for more subjects)
                save(PAT.fcPAT.corr(1).fnameGroup, 'subjectName', 'groupID', 'pairedSeedsNames', 'isTreatment','groupCorrData','groupCorrIdx','groupCorrDataDiff','groupCorrDataRaw')
                if isfield (job,'derivative')
                    save(PAT.fcPAT.corr(1).fnameGroupDiff,'groupCorrDataDiff');
                end
                if isfield (job,'rawData')
                    save(PAT.fcPAT.corr(1).fnameGroupRaw,'groupCorrDataRaw');
                end
                % group analysis succesful
                PAT.fcPAT.corr.corrGroupOK = true;
                % Save PAT matrix
                save(PATmat,'PAT');
            end % correlation OK or redo job
        end % corrMap OK
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        disp(['Subject ' int2str(scanIdx) ' (' scanName ')' ' complete']);
        out.PATmat{scanIdx} = PATmat;
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end % Big loop over subjects

if ~exist(fullfile(job.parent_results_dir{1},'groupOK.mat'),'file') || job.force_redo
    % ------------------------------------------------------------------------------
    % For all the subjects
    % Choose parent folder (batch)
    % Loop over available colors and paired seeds
    % Do group statistical tests
    % Plot/print graphics
    % ------------------------------------------------------------------------------
    % Initialize variables
    statTest        = [];
    meanCorr        = [];
    stdCorr         = [];
    statTestDiff    = [];
    meanCorrDiff    = [];
    stdCorrDiff     = [];
    statTestRaw     = [];
    meanCorrRaw     = [];
    stdCorrRaw      = [];
    eTotal          = [];
    yTotal          = [];
    eTotalDiff      = [];
    yTotalDiff      = [];
    eTotalRaw       = [];
    yTotalRaw       = [];
    
    % dbstop if error
    
    for c1 = 1:size(PAT.nifti_files,2)
        doColor = pat_doColor(PAT,c1,IC);
        if doColor
            % Perform test on ROIs time course
            [job, PAT, e, y, eTotal, yTotal, statTest, meanCorr, stdCorr, groupCorrData] = subfunction_group_corr_test_unpaired(job, PAT, c1, groupCorrData, statTest, meanCorr, stdCorr, eTotal, yTotal, isTreatment);
            % Perform tests on the derivative of ROIs time-course
            [job, PAT, eDiff, yDiff, eTotalDiff, yTotalDiff, statTestDiff, meanCorrDiff, stdCorrDiff, groupCorrDataDiff] = subfunction_group_corr_test_diff_unpaired(job, PAT, c1, groupCorrDataDiff, statTestDiff, meanCorrDiff, stdCorrDiff, eTotalDiff, yTotalDiff, isTreatment);
            % Perform tests on raw data of ROIs time-course
            [job, PAT, eRaw, yRaw, eTotalRaw, yTotalRaw, statTestRaw, meanCorrRaw, stdCorrRaw] = subfunction_group_corr_test_raw_unpaired(job, PAT, c1, groupCorrDataRaw, statTestRaw, meanCorrRaw, stdCorrRaw, eTotalRaw, yTotalRaw, isTreatment);
            % Plot results
            subfunction_plot_group_corr_test(job, PAT, c1, e, y, statTest);
            % Plot results based on 1st derivative
            subfunction_plot_group_corr_test_diff(job, PAT, c1, eDiff, yDiff, statTestDiff);
            % Plot results based on raw data
            subfunction_plot_group_corr_test_raw(job, PAT, c1, eRaw, yRaw, statTestRaw);
            % Arrange all bilateral connectivity measurements in a big cell
            dataCell = subfunction_full_group_data(c1, subjectName, pairedSeedsNames, groupCorrData, groupCorrDataDiff, groupCorrDataRaw, groupID, groupCorrIdx);
            % create csv file name
            fileName = fullfile(job.parent_results_dir{1},['fcGroup_C'  num2str(c1) '_' colorNames{1+c1} '.csv']);
            % Save this cell into a .csv file (one for each contrast)
            subfunction_cell2csv(dataCell, fileName);
        end
    end % loop over colors
    % Group comparison of bilateral correlation succesful!
    groupOK = true;
    save(fullfile(job.parent_results_dir{1},'groupOK.mat'),'groupOK');
    fprintf('Group comparison of bilateral correlation succesful!\n');
end % force or groupOK
end % pat_group_corr_run

function dataCell = subfunction_full_group_data(c1, subjectName, pairedSeedsNames, groupCorrData, groupCorrDataDiff, groupCorrDataRaw, groupID, groupCorrIdx)
% Organize all correlation data in a big cell for group analysis
% Rows = Subjects * Seed Pairs
nRows = size(subjectName,1)*size(subjectName{1},1);
% Columns:
% 1.Name 2.SeedName 3.z(r) 4.z'(r) 5.z_raw(r) 6.isTreatment
nCols = 6;
dataCell = cell([nRows nCols]);
iRows = 0;
for iSubjects = 1:size(subjectName,1),
    for iSeedPairs = 1:size(subjectName{1},1)
        iRows = iRows + 1;
        % Subject Name
        if ~isempty(subjectName{groupCorrIdx{iSeedPairs, c1}(iSubjects, 1)}{iSeedPairs,1})
            dataCell{iRows,1} = subjectName{groupCorrIdx{iSeedPairs, c1}(iSubjects, 1)}{iSeedPairs,1};
            % Replace , for _ (not good for .csv files...)
            dataCell{iRows,1} = regexprep(dataCell{iRows,1},',','_');
        else
            dataCell{iRows,1} = '';
        end
        % Seed pair name
        if ~isempty(pairedSeedsNames{groupCorrIdx{iSeedPairs, c1}(iSubjects, 1)}{iSeedPairs,1})
            dataCell{iRows,2} = pairedSeedsNames{groupCorrIdx{iSeedPairs, c1}(iSubjects, 1)}{iSeedPairs,1};
        else
            dataCell{iRows,2} = '';
        end
        % Bilateral correlation measure
        if ~isempty(groupCorrData{iSeedPairs,c1})
            dataCell{iRows,3} = groupCorrData{iSeedPairs,c1}(groupCorrIdx{iSeedPairs, c1}(iSubjects, 1));
        else
            dataCell{iRows,3} = '';
        end
        % Bilateral correlation measure from 1st deerivative
        if ~isempty(groupCorrDataDiff{iSeedPairs,c1})
            dataCell{iRows,4} = groupCorrDataDiff{iSeedPairs,c1}(groupCorrIdx{iSeedPairs, c1}(iSubjects, 1));
        else
            dataCell{iRows,4} = '';
        end
        % Bilateral correlation measure from raw data
        if ~isempty(groupCorrDataRaw{iSeedPairs,c1})
            dataCell{iRows,5} = groupCorrDataRaw{iSeedPairs,c1}(groupCorrIdx{iSeedPairs, c1}(iSubjects, 1));
        else
            dataCell{iRows,5} = '';
        end
        % 1 if measure belongs to treatment group, 0 if control
        if ~isempty(groupID{groupCorrIdx{iSeedPairs, c1}(iSubjects, 1)}{iSeedPairs,1})
            dataCell{iRows,6} = double(groupID{groupCorrIdx{iSeedPairs, c1}(iSubjects, 1)}{iSeedPairs,1});
        else
            dataCell{iRows,6} = '';
        end
    end
end
if nCols == 6,
    % Append header
    hdr = {'Subject Name' 'Seed Pairs' 'z(r)' 'z(r'')' 'z(r_raw)' 'Ctrl=0; LPS=1'};
    dataCell = [hdr; dataCell];
end
end % subfunction_full_group_data

function subfunction_cell2csv(dataCell, fileName)
% Create .csv file from cell array
fid=fopen(fileName,'wt');
[nRows,nCols]=size(dataCell);

for iRows=1:nRows
    for iCols = 1:nCols-1
        if ~isnumeric(dataCell{iRows, iCols})
            fprintf(fid,'%s,',dataCell{iRows,iCols});
        else
            fprintf(fid,'%f,',dataCell{iRows,iCols});
        end
    end
    if ~isnumeric(dataCell{iRows, end})
        fprintf(fid,'%s\n',dataCell{iRows,end});
    else
        fprintf(fid,'%f\n',dataCell{iRows,end});
    end
end

fclose(fid);
end % subfunction_cell2csv

function [job, PAT, e, y, eTotal, yTotal, statTest, meanCorr, stdCorr, groupCorrData] = subfunction_group_corr_test_unpaired(job, PAT, c1, groupCorrData, statTest, meanCorr, stdCorr, eTotal, yTotal, isTreatment)
% Do a separate paired t-test for each seed data
for iSeeds = 1:size(job.paired_seeds, 1)
    % Average of control group
    meanCorr{iSeeds,c1}(1) = nanmean(groupCorrData{iSeeds,c1}(~isTreatment));
    % Standard deviation of control group
    stdCorr{iSeeds,c1}(1) = nanstd(groupCorrData{iSeeds,c1}(~isTreatment));
    % Average of treatment group
    meanCorr{iSeeds,c1}(2) = nanmean(groupCorrData{iSeeds,c1}(isTreatment));
    % Standard deviation of treatment group
    stdCorr{iSeeds,c1}(2) = nanstd(groupCorrData{iSeeds,c1}(isTreatment));
    
    if isfield(job.optStat.remOutlier, 'remOutOn')
        nStdDev = job.optStat.remOutlier.remOutOn.stdDevVal;
        outliers = zeros(size(isTreatment));
        % Outliers of control group
        outliers(~isTreatment) = abs(groupCorrData{iSeeds,c1}(~isTreatment) - meanCorr{iSeeds,c1}(1)) > nStdDev*stdCorr{iSeeds,c1}(1);
        if any(outliers(~isTreatment))
        	groupCorrData{iSeeds,c1}(~isTreatment & outliers) = NaN;
        end
        % Outliers of treatment group
        outliers(isTreatment) = abs(groupCorrData{iSeeds,c1}(isTreatment) - meanCorr{iSeeds,c1}(2)) > nStdDev*stdCorr{iSeeds,c1}(2);
        if any(outliers(~isTreatment))
            groupCorrData{iSeeds,c1}(isTreatment & outliers) = NaN;
        end
    end
    
    % Used to plot bar graphs with errorbars
    y(iSeeds,:) = meanCorr{iSeeds,c1};
    e(iSeeds,:) = stdCorr{iSeeds,c1};
    
    % Unpaired-sample t-test
    if job.optStat.ttest1
        if isempty(groupCorrData{iSeeds,c1}(~isTreatment)) || isempty(groupCorrData{iSeeds,c1}(isTreatment))
            statTest(1).t(1).H{iSeeds,c1} = false;
            statTest(1).t(1).P{iSeeds,c1} = NaN;
            statTest(1).t(1).CI{iSeeds,c1} = NaN;
            statTest(1).t(1).STATS{iSeeds,c1} = NaN;
            statTest(1).t(1).id = 'Empty group';
        else
            [statTest(1).t(1).H{iSeeds,c1}, statTest(1).t(1).P{iSeeds,c1}, ...
                statTest(1).t(1).CI{iSeeds,c1}, statTest(1).t(1).STATS{iSeeds,c1}] ...
                = ttest2(...
                groupCorrData{iSeeds,c1}(~isTreatment), groupCorrData{iSeeds,c1}(isTreatment),...
                job.optStat.alpha,'both');
            statTest(1).t(1).id = 'Unpaired-sample t-test';
        end
    end % t-test
    
    % Wilcoxon rank sum test
    if job.optStat.wilcoxon1
        ctrlGroup = groupCorrData{iSeeds,c1}(~isTreatment);
        % ignore NaN values
        ctrlGroup = ctrlGroup(~isnan(ctrlGroup));
        treatmentGroup = groupCorrData{iSeeds,c1}(isTreatment);
        % ignore NaN values
        treatmentGroup = treatmentGroup(~isnan(treatmentGroup));
        if isempty(ctrlGroup) || isempty(treatmentGroup)
            statTest(1).w(1).H{iSeeds,c1} = false;
            statTest(1).w(1).P{iSeeds,c1} = NaN;
            statTest(1).w(1).CI{iSeeds,c1} = NaN;
            statTest(1).w(1).STATS{iSeeds,c1} = NaN;
            statTest(1).w(1).id = 'Empty group';
        else
            % Perform such test
            [statTest(1).w(1).P{iSeeds,c1}, statTest(1).w(1).H{iSeeds,c1},...
                statTest(1).w(1).STATS{iSeeds,c1}] = ranksum...
                (ctrlGroup, treatmentGroup, 'alpha', job.optStat.alpha);
            statTest(1).w(1).id = 'Wilcoxon rank sum test';
        end
    end % Wilcoxon test
    
end % paired-seeds loop

if job.optStat.ttest1
    % FDR-corrected p-value (q)
    if job.optStat.multComp == 2
        FDRpValue = pat_fdr(cell2mat(statTest(1).t(1).P(:,c1)));
        for iSeeds = 1:size(job.paired_seeds, 1)
            statTest(1).t(1).P{iSeeds,c1} = FDRpValue(iSeeds);
            if statTest(1).t(1).P{iSeeds,c1} < job.optStat.alpha
                statTest(1).t(1).H{iSeeds,c1} = true;
            else
                statTest(1).t(1).H{iSeeds,c1} = false;
            end
        end
        statTest(1).t(1).id = [statTest(1).t(1).id ' FDR adjusted'];
    end
end

if job.optStat.wilcoxon1
    % FDR-corrected p-value (q)
    if job.optStat.multComp == 2
        FDRpValue = pat_fdr(cell2mat(statTest(1).w(1).P(:,c1)));
        for iSeeds = 1:size(job.paired_seeds, 1)
            statTest(1).w(1).P{iSeeds,c1} = FDRpValue(iSeeds);
            if statTest(1).w(1).P{iSeeds,c1} < job.optStat.alpha
                statTest(1).w(1).H{iSeeds,c1} = true;
            else
                statTest(1).w(1).H{iSeeds,c1} = false;
            end
        end
        statTest(1).w(1).id = [statTest(1).w(1).id ' FDR adjusted'];
    end
end

% Show standard error bars instead of standard deviation
if job.optFig.stderror
    sampleSize = ones(size(e));
    % First column: Control group
    sampleSize(:,1) = sampleSize(:,1) .* numel(ctrlGroup);
    % Second column: Treatment group
    sampleSize(:,2) = sampleSize(:,2) .* numel(treatmentGroup);
    % std error bars: sigma/sqrt(N)
    e = e ./ sqrt(sampleSize);
end

% Save total data for plotting later
yTotal{c1} = y;
eTotal{c1} = e;

if exist(PAT.fcPAT.corr(1).fnameGroup,'file')
    % Append results to .mat file
    save(PAT.fcPAT.corr(1).fnameGroup,'groupCorrData', 'isTreatment',...
        'meanCorr','stdCorr','statTest','yTotal','eTotal','-append');
else
    % Write results to .mat file
    save(PAT.fcPAT.corr(1).fnameGroup,'groupCorrData', 'isTreatment',...
        'meanCorr','stdCorr','statTest','yTotal','eTotal');
end


end % subfunction_group_corr_test_unpaired

function [job, PAT, eDiff, yDiff, eTotalDiff, yTotalDiff, statTestDiff, meanCorrDiff, stdCorrDiff, groupCorrDataDiff] = subfunction_group_corr_test_diff_unpaired(job, PAT, c1, groupCorrDataDiff, statTestDiff, meanCorrDiff, stdCorrDiff, eTotalDiff, yTotalDiff, isTreatment)
% empty outputs
eDiff = [];
yDiff = [];

if isfield (job.optStat,'derivative')
    if job.optStat.derivative
        for iSeeds = 1:size(job.paired_seeds, 1)
            % Average of control group
            meanCorrDiff{iSeeds,c1}(1) = nanmean(groupCorrDataDiff{iSeeds,c1}(~isTreatment));
            % Average of treatment group
            meanCorrDiff{iSeeds,c1}(2) = nanmean(groupCorrDataDiff{iSeeds,c1}(isTreatment));
            % Standard deviation of control group
            stdCorrDiff{iSeeds,c1}(1) = nanstd(groupCorrDataDiff{iSeeds,c1}(~isTreatment));
            % Standard deviation oftreatment group
            stdCorrDiff{iSeeds,c1}(2) = nanstd(groupCorrDataDiff{iSeeds,c1}(isTreatment));
            
            if isfield(job.optStat.remOutlier, 'remOutOn')
                nStdDev = job.optStat.remOutlier.remOutOn.stdDevVal;
                outliers = zeros(size(isTreatment));
                % Outliers of control group
                outliers(~isTreatment) = abs(groupCorrDataDiff{iSeeds,c1}(~isTreatment) - meanCorrDiff{iSeeds,c1}(1)) > nStdDev*stdCorrDiff{iSeeds,c1}(1);
                if any(outliers(~isTreatment))
                    groupCorrDataDiff{iSeeds,c1}(~isTreatment & outliers) = NaN;
                end
                % Outliers of treatment group
                outliers(isTreatment) = abs(groupCorrDataDiff{iSeeds,c1}(isTreatment) - meanCorrDiff{iSeeds,c1}(2)) > nStdDev*stdCorrDiff{iSeeds,c1}(2);
                if any(outliers(~isTreatment))
                    groupCorrDataDiff{iSeeds,c1}(isTreatment & outliers) = NaN;
                end
            end
            
            % Used to plot bar graphs with errorbars
            yDiff(iSeeds,:) = meanCorrDiff{iSeeds,c1};
            eDiff(iSeeds,:) = stdCorrDiff{iSeeds,c1};
            
            % Paired-sample t-test
            if job.optStat.ttest1
                if isempty(groupCorrDataDiff{iSeeds,c1}(~isTreatment)) || isempty(groupCorrDataDiff{iSeeds,c1}(isTreatment))
                    statTestDiff(1).t(1).H{iSeeds,c1} = false;
                    statTestDiff(1).t(1).P{iSeeds,c1} = NaN;
                    statTestDiff(1).t(1).CI{iSeeds,c1} = NaN;
                    statTestDiff(1).t(1).STATS{iSeeds,c1} = NaN;
                    statTestDiff(1).t(1).id = 'Empty group';
                else
                    [statTestDiff(1).t(1).H{iSeeds,c1}, statTestDiff(1).t(1).P{iSeeds,c1}, ...
                        statTestDiff(1).t(1).CI{iSeeds,c1}, statTestDiff(1).t(1).STATS{iSeeds,c1}] ...
                        = ttest2(...
                        groupCorrDataDiff{iSeeds,c1}(~isTreatment), groupCorrDataDiff{iSeeds,c1}(isTreatment),...
                        job.optStat.alpha,'both');
                    statTestDiff(1).t(1).id = 'Unpaired-sample t-test(1st derivative)';
                end
            end % t-test
            
            % Wilcoxon rank sum test
            if job.optStat.wilcoxon1
                ctrlGroupDiff = groupCorrDataDiff{iSeeds,c1}(~isTreatment);
                % ignore NaN values
                ctrlGroupDiff = ctrlGroupDiff(~isnan(ctrlGroupDiff));
                treatmentGroupDiff = groupCorrDataDiff{iSeeds,c1}(isTreatment);
                % ignore NaN values
                treatmentGroupDiff = treatmentGroupDiff(~isnan(treatmentGroupDiff));
                if isempty(ctrlGroupDiff) || isempty(treatmentGroupDiff)
                    statTestDiff(1).w(1).H{iSeeds,c1} = false;
                    statTestDiff(1).w(1).P{iSeeds,c1} = NaN;
                    statTestDiff(1).w(1).CI{iSeeds,c1} = NaN;
                    statTestDiff(1).w(1).STATS{iSeeds,c1} = NaN;
                    statTestDiff(1).w(1).id = 'Empty group';
                else
                    % Perform such test
                    [statTestDiff(1).w(1).P{iSeeds,c1}, statTestDiff(1).w(1).H{iSeeds,c1},...
                        statTestDiff(1).w(1).STATS{iSeeds,c1}] = ranksum...
                        (ctrlGroupDiff, treatmentGroupDiff, 'alpha', job.optStat.alpha);
                    statTestDiff(1).w(1).id = 'Wilcoxon rank sum test(1st derivative)';
                end
            end % Wilcoxon test
            
        end % paired-seeds loop
        
        if job.optStat.ttest1
            % FDR-corrected p-value (q)
            if job.optStat.multComp == 2
                FDRpValue = pat_fdr(cell2mat(statTestDiff(1).t(1).P(:,c1)));
                for iSeeds = 1:size(job.paired_seeds, 1)
                    statTestDiff(1).t(1).P{iSeeds,c1} = FDRpValue(iSeeds);
                    if statTestDiff(1).t(1).P{iSeeds,c1} < job.optStat.alpha
                        statTestDiff(1).t(1).H{iSeeds,c1} = true;
                    else
                        statTestDiff(1).t(1).H{iSeeds,c1} = false;
                    end
                end
                statTestDiff(1).t(1).id = [statTestDiff(1).t(1).id ' FDR adjusted'];
            end
        end
        
        if job.optStat.wilcoxon1
            % FDR-corrected p-value (q)
            if job.optStat.multComp == 2
                FDRpValue = pat_fdr(cell2mat(statTestDiff(1).w(1).P(:,c1)));
                for iSeeds = 1:size(job.paired_seeds, 1)
                    statTestDiff(1).w(1).P{iSeeds,c1} = FDRpValue(iSeeds);
                    if statTestDiff(1).w(1).P{iSeeds,c1} < job.optStat.alpha
                        statTestDiff(1).w(1).H{iSeeds,c1} = true;
                    else
                        statTestDiff(1).w(1).H{iSeeds,c1} = false;
                    end
                end
                statTestDiff(1).w(1).id = [statTestDiff(1).w(1).id ' FDR adjusted'];
            end
        end
        
        % Show standard error bars instead of standard deviation
        if job.optFig.stderror
            sampleSizeDiff = ones(size(eDiff));
            % First column: Control group
            sampleSizeDiff(:,1) = sampleSizeDiff(:,1) .* numel(ctrlGroupDiff);
            % Second column: Treatment group
            sampleSizeDiff(:,2) = sampleSizeDiff(:,2) .* numel(treatmentGroupDiff);
            % std error bars: sigma/sqrt(N)
            eDiff = eDiff ./ sqrt(sampleSizeDiff);
        end
        
        % Save total data for plotting later
        yTotalDiff{c1} = yDiff;
        eTotalDiff{c1} = eDiff;
        
        if exist(PAT.fcPAT.corr(1).fnameGroupDiff,'file')
            % Append results to .mat file
            save(PAT.fcPAT.corr(1).fnameGroupDiff,'groupCorrDataDiff','isTreatment',...
                'meanCorrDiff','stdCorrDiff','statTestDiff','yTotalDiff','eTotalDiff',...
                '-append');
        else
            % Save results to .mat file
            save(PAT.fcPAT.corr(1).fnameGroupDiff,'groupCorrDataDiff','isTreatment',...
                'meanCorrDiff','stdCorrDiff','statTestDiff','yTotalDiff','eTotalDiff');
        end
    end
end % derivative
end % subfunction_group_corr_test_diff_unpaired

function [job, PAT, eRaw, yRaw, eTotalRaw, yTotalRaw, statTestRaw, meanCorrRaw, stdCorrRaw] = subfunction_group_corr_test_raw_unpaired(job, PAT, c1, groupCorrDataRaw, statTestRaw, meanCorrRaw, stdCorrRaw, eTotalRaw, yTotalRaw, isTreatment)
% empty outputs
eRaw = [];
yRaw = [];

if isfield (job,'rawData')
    if job.optStat.rawData
        for iSeeds = 1:size(job.paired_seeds, 1)
            % Average of control group
            meanCorrRaw{iSeeds,c1}(1) = nanmean(groupCorrDataRaw{iSeeds,c1}(~isTreatment));
            % Average of treatment group
            meanCorrRaw{iSeeds,c1}(2) = nanmean(groupCorrDataRaw{iSeeds,c1}(isTreatment));
            % Standard deviation of control group
            stdCorrRaw{iSeeds,c1}(1) = nanstd(groupCorrDataRaw{iSeeds,c1}(~isTreatment));
            % Standard deviation oftreatment group
            stdCorrRaw{iSeeds,c1}(2) = nanstd(groupCorrDataRaw{iSeeds,c1}(isTreatment));
            
            % Used to plot bar graphs with errorbars
            yRaw(iSeeds,:) = meanCorrRaw{iSeeds,c1};
            eRaw(iSeeds,:) = stdCorrRaw{iSeeds,c1};
            
            % Paired-sample t-test
            if job.optStat.ttest1
                if isempty(groupCorrDataRaw{iSeeds,c1}(~isTreatment)) || isempty(groupCorrDataRaw{iSeeds,c1}(isTreatment))
                    statTestRaw(1).t(1).H{iSeeds,c1} = false;
                    statTestRaw(1).t(1).P{iSeeds,c1} = NaN;
                    statTestRaw(1).t(1).CI{iSeeds,c1} = NaN;
                    statTestRaw(1).t(1).STATS{iSeeds,c1} = NaN;
                    statTestRaw(1).t(1).id = 'Empty group';
                else
                    [statTestRaw(1).t(1).H{iSeeds,c1}, statTestRaw(1).t(1).P{iSeeds,c1}, ...
                        statTestRaw(1).t(1).CI{iSeeds,c1}, statTestRaw(1).t(1).STATS{iSeeds,c1}] ...
                        = ttest2(...
                        groupCorrDataRaw{iSeeds,c1}(~isTreatment), groupCorrDataRaw{iSeeds,c1}(isTreatment),...
                        job.optStat.alpha,'both');
                    statTestRaw(1).t(1).id = 'Unpaired-sample t-test(raw data)';
                end
            end % t-test
            
            % Wilcoxon rank sum test
            if job.optStat.wilcoxon1
                ctrlGroupRaw = groupCorrDataRaw{iSeeds,c1}(~isTreatment);
                % ignore NaN values
                ctrlGroupRaw = ctrlGroupRaw(~isnan(ctrlGroupRaw));
                treatmentGroupRaw = groupCorrDataRaw{iSeeds,c1}(isTreatment);
                % ignore NaN values
                treatmentGroupRaw = treatmentGroupRaw(~isnan(treatmentGroupRaw));
                if isempty(ctrlGroupRaw) || isempty(treatmentGroupRaw)
                    statTestRaw(1).w(1).H{iSeeds,c1} = false;
                    statTestRaw(1).w(1).P{iSeeds,c1} = NaN;
                    statTestRaw(1).w(1).CI{iSeeds,c1} = NaN;
                    statTestRaw(1).w(1).STATS{iSeeds,c1} = NaN;
                    statTestRaw(1).w(1).id = 'Empty group';
                else
                    % Perform such test
                    [statTestRaw(1).w(1).P{iSeeds,c1}, statTestRaw(1).w(1).H{iSeeds,c1},...
                        statTestRaw(1).w(1).STATS{iSeeds,c1}] = ranksum...
                        (ctrlGroupRaw, treatmentGroupRaw, 'alpha', job.optStat.alpha);
                    statTestRaw(1).w(1).id = 'Wilcoxon rank sum test(raw data)';
                end
            end % Wilcoxon test
            
        end % paired-seeds loop
        if job.optStat.ttest1
            % FDR-corrected p-value (q)
            if job.optStat.multComp == 2
                FDRpValue = pat_fdr(cell2mat(statTestRaw(1).t(1).P(:,c1)));
                for iSeeds = 1:size(job.paired_seeds, 1)
                    statTestRaw(1).t(1).P{iSeeds,c1} = FDRpValue(iSeeds);
                    if statTestRaw(1).t(1).P{iSeeds,c1} < job.optStat.alpha
                        statTestRaw(1).t(1).H{iSeeds,c1} = true;
                    else
                        statTestRaw(1).t(1).H{iSeeds,c1} = false;
                    end
                end
                statTestRaw(1).t(1).id = [statTestRaw(1).t(1).id ' FDR adjusted'];
            end
        end
        
        if job.optStat.wilcoxon1
            % FDR-corrected p-value (q)
            if job.optStat.multComp == 2
                FDRpValue = pat_fdr(cell2mat(statTestRaw(1).w(1).P(:,c1)));
                for iSeeds = 1:size(job.paired_seeds, 1)
                    statTestRaw(1).w(1).P{iSeeds,c1} = FDRpValue(iSeeds);
                    if statTestRaw(1).w(1).P{iSeeds,c1} < job.optStat.alpha
                        statTestRaw(1).w(1).H{iSeeds,c1} = true;
                    else
                        statTestRaw(1).w(1).H{iSeeds,c1} = false;
                    end
                end
                statTestRaw(1).w(1).id = [statTestRaw(1).w(1).id ' FDR adjusted'];
            end
        end
        
        % Show standard error bars instead of standard deviation
        if job.optFig.stderror
            sampleSizeRaw = ones(size(eRaw));
            % First column: Control group
            sampleSizeRaw(:,1) = sampleSizeRaw(:,1) .* numel(ctrlGroupRaw);
            % Second column: Treatment group
            sampleSizeRaw(:,2) = sampleSizeRaw(:,2) .* numel(treatmentGroupRaw);
            % std error bars: sigma/sqrt(N)
            eRaw = eRaw ./ sqrt(sampleSizeRaw);
        end
        
        % Save total data for plotting later
        yTotalRaw{c1} = yRaw;
        eTotalRaw{c1} = eRaw;
        
        if exist(PAT.fcPAT.corr(1).fnameGroupRaw, 'file')
            % Append results to .mat file
            save(PAT.fcPAT.corr(1).fnameGroupRaw,'groupCorrDataRaw','isTreatment',...
                'meanCorrRaw','stdCorrRaw','statTestRaw', 'yTotalRaw', 'eTotalRaw',...
                '-append');
        else
            % Save results in .mat file
            save(PAT.fcPAT.corr(1).fnameGroupRaw,'groupCorrDataRaw','isTreatment',...
                'meanCorrRaw','stdCorrRaw','statTestRaw', 'yTotalRaw', 'eTotalRaw');
        end
    end
end % raw data
end % subfunction_group_corr_test_raw_unpaired

function subfunction_plot_group_corr_test(job, PAT, c1, e, y, statTest)
% Plots statistical analysis group results
colorNames      = fieldnames(PAT.color);
% Positioning factor for the * mark, depends on max data value at the given seed
starPosFactor   = 1.05;
% Font Sizes
axisFontSize    = 12;
starFontSize    = 22;
axMargin        = 0.5;

    
if job.optStat.ttest1
    % Display a graph with ROI labels
    if job.generate_figures
        % Display plots on new figure
        h = figure; set(gcf,'color','w')
        % Specify window units
        set(h, 'units', 'inches')
        % Change figure and paper size
        set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Custom bar graphs with error bars (1st arg: error)
        barwitherr(e, y)
        % Display colormap according to the contrast
        switch(c1)
            case 1
                % HbT contrast
                colormap([0.5 0.5 0.5; 1 1 1]);
            case 2
                % SO2 contrast
                colormap([0.25 0.25 0.25; 1 1 1]);
            case 3
                % B-mode contrast
                colormap([0 0 0; 1 1 1]);
            case 4
                % HbO contrast
                colormap([1 0 0; 1 1 1]);
            case 5
                % HbR contrast
                colormap([0 0 1; 1 1 1]);
            otherwise
                colormap(gray)
        end
        switch job.optStat.multComp
            case 0 % None
                corrName = '';
            case 1 % Bonferroni
                corrName = 'Bonferroni';
            case 2 % FDR
                corrName = 'FDR';
            otherwise
                % Do nothing
        end
        title(sprintf('C%d(%s). T-test (*p<%.2g) %s',...
            c1,colorNames{1+c1},job.optStat.alpha,corrName),'interpreter','none','FontSize',job.optFig.titleFontSize)
        set(gca,'FontSize',axisFontSize)
        ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
        set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
        if isfield(job.optFig.legends, 'legendShow')
            legend(job.ID,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
        end
        set(gca, 'xLim', [axMargin size(y,1) + axMargin]);
        if isfield(job.optFig.yLimits, 'yLimManual')
            set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
        end
        % Show a * when a significant difference is found.

        for iSeeds = 1:size(job.paired_seeds, 1)
%             % FDR-corrected p-value (q)
%             if job.optStat.multComp == 2
%                 if pat_fdr(statTest(1).t(1).P{iSeeds,c1}) < job.pValue
%                     % Significant difference
%                     statTest(1).t(1).H{iSeeds,c1} = true;
%                 else
%                     % Non significant difference
%                     statTest(1).t(1).H{iSeeds,c1} = false;
%                 end
%             end
            if isnan(statTest(1).t(1).H{iSeeds,c1})
                statTest(1).t(1).H{iSeeds,c1} = false;
            end
            if statTest(1).t(1).H{iSeeds,c1}
                if max(y(iSeeds,:))>=0
                    yPos = starPosFactor*(max(y(iSeeds,:)) + max(e(iSeeds,:)));
                else
                    yPos = starPosFactor*(min(y(iSeeds,:)) - max(e(iSeeds,:)));
                end
                xPos = iSeeds;
                text(xPos, yPos, '*', 'FontSize', starFontSize, 'FontWeight', 'b');
            end
        end
        if job.save_figures
            newName = sprintf('groupCorr_Ttest_C%d_(%s)',c1,colorNames{1+c1});
            switch job.optStat.multComp
                case 0 % None
                    %Do nothing
                case 1 % Bonferroni
                    newName = [newName '_Bonferroni'];
                case 2 % FDR
                    newName = [newName '_FDR'];
                otherwise
                    % Do nothing
            end
            % Save as EPS
            % spm_figure('Print', 'Graphics', fullfile(job.parent_results_dir{1}, newName));
            % Save as PNG
            print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
            % Save as a figure
            saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
            % Return the property to its default
            set(h, 'units', 'pixels')
            close(h)
        end
    end % end generate figures
end

if job.optStat.wilcoxon1
    % Display a graph with ROI labels
    if job.generate_figures
        % Display plots on new figure
        h = figure; set(gcf,'color','w')
        % Specify window units
        set(h, 'units', 'inches')
        % Change figure and paper size
        set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Custom bar graphs with error bars (1st arg: error)
        barwitherr(e, y)
        % Display colormap according to the contrast
        switch(c1)
            case 1
                % HbT contrast
                colormap([0.5 0.5 0.5; 1 1 1]);
            case 2
                % SO2 contrast
                colormap([0.25 0.25 0.25; 1 1 1]);
            case 3
                % B-mode contrast
                colormap([0 0 0; 1 1 1]);
            case 4
                % HbO contrast
                colormap([1 0 0; 1 1 1]);
            case 5
                % HbR contrast
                colormap([0 0 1; 1 1 1]);
            otherwise
                colormap(gray)
        end
        switch job.optStat.multComp
            case 0 % None
                corrName = '';
            case 1 % Bonferroni
                corrName = 'Bonferroni';
            case 2 % FDR
                corrName = 'FDR';
            otherwise
                % Do nothing
        end
        title(sprintf('C%d(%s). Wilcoxon *(p<%.2g) %s',...
            c1,colorNames{1+c1},job.optStat.alpha,corrName),'interpreter','none','FontSize',job.optFig.titleFontSize)
        set(gca,'FontSize',axisFontSize)
        ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
        set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
        if isfield(job.optFig.legends, 'legendShow')
            legend(job.ID,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
        end
        set(gca, 'xLim', [axMargin size(y,1) + axMargin]);
        if isfield(job.optFig.yLimits, 'yLimManual')
            set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
        end
        % Show a * when a significant difference is found.
        for iSeeds = 1:size(job.paired_seeds, 1)
%             % FDR-corrected p-value (q)
%             if job.optStat.multComp == 2
%                 if pat_fdr(statTest(1).w(1).P{iSeeds,c1}) < job.pValue
%                     % Significant difference
%                     statTest(1).w(1).H{iSeeds,c1} = true;
%                 else
%                     % Non significant difference
%                     statTest(1).w(1).H{iSeeds,c1} = false;
%                 end
%             end
            if isnan(statTest(1).w(1).H{iSeeds,c1})
                statTest(1).w(1).H{iSeeds,c1} = false;
            end
            if statTest(1).w(1).H{iSeeds,c1}
                if max(y(iSeeds,:))>=0
                    yPos = starPosFactor*(max(y(iSeeds,:)) + max(e(iSeeds,:)));
                else
                    yPos = starPosFactor*(min(y(iSeeds,:)) - max(e(iSeeds,:)));
                end
                xPos = iSeeds;
                text(xPos, yPos,'*', 'FontSize', starFontSize, 'FontWeight', 'b');
            end
        end
        if job.save_figures
            newName = sprintf('groupCorr_Wtest_C%d_(%s)',c1,colorNames{1+c1});
            switch job.optStat.multComp
                case 0 % None
                    %Do nothing
                case 1 % Bonferroni
                    newName = [newName '_Bonferroni'];
                case 2 % FDR
                    newName = [newName '_FDR'];
                otherwise
                    % Do nothing
            end
            % Save as EPS
            % spm_figure('Print', 'Graphics', fullfile(job.parent_results_dir{1},newName));
            % Save as PNG
            print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
            % Save as a figure
            saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
            % Return the property to its default
            set(h, 'units', 'pixels')
            close(h)
        end
    end % End generate figures
end
end % subfunction_plot_group_corr_test

function subfunction_plot_group_corr_test_diff(job, PAT, c1, eDiff, yDiff, statTestDiff)
if isfield (job.optStat,'derivative')
    if job.optStat.derivative
        % Plots statistical analysis group results
        colorNames = fieldnames(PAT.color);
        % Positioning factor for the * mark, depends on max data value at the given seed
        starPosFactor   = 1.05;
        % Font Sizes
        axisFontSize    = 12;
        starFontSize    = 22;
        axMargin        = 0.5;
        
        if job.optStat.ttest1
            % Display a graph with ROI labels
            if job.generate_figures
                % Display plots on new figure
                h = figure; set(gcf,'color','w')
                % Specify window units
                set(h, 'units', 'inches')
                % Change figure and paper size
                set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                % Custom bar graphs with error bars (1st arg: error)
                barwitherr(eDiff, yDiff)
                % Display colormap according to the contrast
                switch(c1)
                    case 1
                        % HbT contrast
                        colormap([0.5 0.5 0.5; 1 1 1]);
                    case 2
                        % SO2 contrast
                        colormap([0.25 0.25 0.25; 1 1 1]);
                    case 3
                        % B-mode contrast
                        colormap([0 0 0; 1 1 1]);
                    case 4
                        % HbO contrast
                        colormap([1 0 0; 1 1 1]);
                    case 5
                        % HbR contrast
                        colormap([0 0 1; 1 1 1]);
                    otherwise
                        colormap(gray)
                end
                switch job.optStat.multComp
                    case 0 % None
                        corrName = '';
                    case 1 % Bonferroni
                        corrName = 'Bonferroni';
                    case 2 % FDR
                        corrName = 'FDR';
                    otherwise
                        % Do nothing
                end
                title(sprintf('C%d(%s) Diff. T-test (*p<%.2g) %s',...
                    c1,colorNames{1+c1},job.optStat.alpha,corrName),'interpreter','none','FontSize',job.optFig.titleFontSize)
                set(gca,'FontSize',axisFontSize)
                ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
                set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
                if isfield(job.optFig.legends, 'legendShow')
                    legend(job.ID,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
                end
                set(gca, 'xLim', [axMargin size(yDiff,1) + axMargin]);
                if isfield(job.optFig.yLimits, 'yLimManual')
                    set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
                end
                % Show a * when a significant difference is found.
                for iSeeds = 1:size(job.paired_seeds, 1)
%                     % FDR-corrected p-value (q)
%                     if job.optStat.multComp == 2
%                         if pat_fdr(statTestDiff(1).t(1).P{iSeeds,c1}) < job.pValue
%                             % Significant difference
%                             statTestDiff(1).t(1).H{iSeeds,c1} = true;
%                         else
%                             % Non significant difference
%                             statTestDiff(1).t(1).H{iSeeds,c1} = false;
%                         end
%                     end
                    if statTestDiff(1).t(1).H{iSeeds,c1}
                        if max(yDiff(iSeeds,:))>=0
                            yPos = starPosFactor*(max(yDiff(iSeeds,:)) + max(eDiff(iSeeds,:)));
                        else
                            yPos = starPosFactor*(min(yDiff(iSeeds,:)) - max(eDiff(iSeeds,:)));
                        end
                        xPos = iSeeds;
                        text(xPos, yPos, '*', 'FontSize', starFontSize, 'FontWeight', 'b');
                    end
                end
                if job.save_figures
                    newName = sprintf('groupCorr_Ttest_C%d_(%s)_diff',c1,colorNames{1+c1});
                    switch job.optStat.multComp
                        case 0 % None
                            %Do nothing
                        case 1 % Bonferroni
                            newName = [newName '_Bonferroni'];
                        case 2 % FDR
                            newName = [newName '_FDR'];
                        otherwise
                            % Do nothing
                    end
                    % Save as EPS
                    % spm_figure('Print', 'Graphics', fullfile(job.parent_results_dir{1}, newName));
                    % Save as PNG
                    print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
                    % Save as a figure
                    saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
                    % Return the property to its default
                    set(h, 'units', 'pixels')
                    close(h)
                end
            end % end generate figures
        end
        
        if job.optStat.wilcoxon1
            % Display a graph with ROI labels
            if job.generate_figures
                % Display plots on new figure
                h = figure; set(gcf,'color','w')
                % Specify window units
                set(h, 'units', 'inches')
                % Change figure and paper size
                set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                % Custom bar graphs with error bars (1st arg: error)
                barwitherr(eDiff, yDiff)
                % Display colormap according to the contrast
                switch(c1)
                    case 1
                        % HbT contrast
                        colormap([0.5 0.5 0.5; 1 1 1]);
                    case 2
                        % SO2 contrast
                        colormap([0.25 0.25 0.25; 1 1 1]);
                    case 3
                        % B-mode contrast
                        colormap([0 0 0; 1 1 1]);
                    case 4
                        % HbO contrast
                        colormap([1 0 0; 1 1 1]);
                    case 5
                        % HbR contrast
                        colormap([0 0 1; 1 1 1]);
                    otherwise
                        colormap(gray)
                end
                 switch job.optStat.multComp
                    case 0 % None
                        corrName = '';
                    case 1 % Bonferroni
                        corrName = 'Bonferroni';
                    case 2 % FDR
                        corrName = 'FDR';
                    otherwise
                        % Do nothing
                end
                title(sprintf('C%d(%s) Diff. Wilcoxon (*p<%.2g) %s',...
                    c1,colorNames{1+c1},job.optStat.alpha,corrName),'interpreter','none','FontSize',job.optFig.titleFontSize)
                set(gca,'FontSize',axisFontSize)
                ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
                set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
                if isfield(job.optFig.legends, 'legendShow')
                    legend(job.ID,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
                end
                set(gca, 'xLim', [axMargin size(yDiff,1) + axMargin]);
                if isfield(job.optFig.yLimits, 'yLimManual')
                    set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
                end
                % Show a * when a significant difference is found.
                for iSeeds = 1:size(job.paired_seeds, 1)
%                     % FDR-corrected p-value (q)
%                     if job.optStat.multComp == 2
%                         if pat_fdr(statTestDiff(1).w(1).P{iSeeds,c1}) < job.pValue
%                             % Significant difference
%                             statTestDiff(1).w(1).H{iSeeds,c1} = true;
%                         else
%                             % Non significant difference
%                             statTestDiff(1).w(1).H{iSeeds,c1} = false;
%                         end
%                     end
                    if statTestDiff(1).w(1).H{iSeeds,c1}
                        if max(yDiff(iSeeds,:))>=0
                            yPos = starPosFactor*(max(yDiff(iSeeds,:)) + max(eDiff(iSeeds,:)));
                        else
                            yPos = starPosFactor*(min(yDiff(iSeeds,:)) - max(eDiff(iSeeds,:)));
                        end
                        xPos = iSeeds;
                        text(xPos, yPos,'*', 'FontSize', starFontSize, 'FontWeight', 'b');
                    end
                end
                if job.save_figures
                    newName = sprintf('groupCorr_Wtest_C%d_(%s)_diff',c1,colorNames{1+c1});
                    switch job.optStat.multComp
                        case 0 % None
                            %Do nothing
                        case 1 % Bonferroni
                            newName = [newName '_Bonferroni'];
                        case 2 % FDR
                            newName = [newName '_FDR'];
                        otherwise
                            % Do nothing
                    end
                    % Save as EPS
                    % spm_figure('Print', 'Graphics', fullfile(job.parent_results_dir{1},newName));
                    % Save as PNG
                    print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
                    % Save as a figure
                    saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
                    % Return the property to its default
                    set(h, 'units', 'pixels')
                    close(h)
                end
            end % End generate figures
        end % Wilcoxon
    end
end % derivative
end % subfunction_plot_group_corr_test_diff

function subfunction_plot_group_corr_test_raw(job, PAT, c1, eRaw, yRaw, statTestRaw)
if isfield (job,'rawData')
    if job.optStat.rawData
        % Plots statistical analysis group results
        colorNames = fieldnames(PAT.color);
        % Positioning factor for the * mark, depends on max data value at the given seed
        starPosFactor   = 1.05;
        % Font Sizes
        axisFontSize    = 12;
        starFontSize    = 22;
        axMargin        = 0.5;
        
        if job.optStat.ttest1
            % Display a graph with ROI labels
            if job.generate_figures
                % Display plots on new figure
                h = figure; set(gcf,'color','w')
                % Specify window units
                set(h, 'units', 'inches')
                % Change figure and paper size
                set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                % Custom bar graphs with error bars (1st arg: error)
                barwitherr(eRaw, yRaw)
                % Display colormap according to the contrast
                switch(c1)
                    case 1
                        % HbT contrast
                        colormap([0.5 0.5 0.5; 1 1 1]);
                    case 2
                        % SO2 contrast
                        colormap([0.25 0.25 0.25; 1 1 1]);
                    case 3
                        % B-mode contrast
                        colormap([0 0 0; 1 1 1]);
                    case 4
                        % HbO contrast
                        colormap([1 0 0; 1 1 1]);
                    case 5
                        % HbR contrast
                        colormap([0 0 1; 1 1 1]);
                    otherwise
                        colormap(gray)
                end
                switch job.optStat.multComp
                    case 0 % None
                        corrName = '';
                    case 1 % Bonferroni
                        corrName = 'Bonferroni';
                    case 2 % FDR
                        corrName = 'FDR';
                    otherwise
                        % Do nothing
                end
                title(sprintf('C%d(%s) Raw T-test (*p<%.2g) %s',...
                    c1,colorNames{1+c1},job.optStat.alpha,corrName),'interpreter','none','FontSize',job.optFig.titleFontSize)
                set(gca,'FontSize',axisFontSize)
                ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
                set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
                if isfield(job.optFig.legends, 'legendShow')
                    legend(job.ID,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
                end
                set(gca, 'xLim', [axMargin size(yRaw,1) + axMargin]);
                if isfield(job.optFig.yLimits, 'yLimManual')
                    set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
                end
                % Show a * when a significant difference is found.
                for iSeeds = 1:size(job.paired_seeds, 1)
%                     % FDR-corrected p-value (q)
%                     if job.optStat.multComp == 2
%                         if pat_fdr(statTestRaw(1).t(1).H{iSeeds,c1}) < job.pValue
%                             % Significant difference
%                             statTestRaw(1).t(1).H{iSeeds,c1} = true;
%                         else
%                             % Non significant difference
%                             statTestRaw(1).t(1).H{iSeeds,c1} = false;
%                         end
%                     end
                    if statTestRaw(1).t(1).H{iSeeds,c1}
                        if max(yRaw(iSeeds,:))>=0
                            yPos = starPosFactor*(max(yRaw(iSeeds,:)) + max(eRaw(iSeeds,:)));
                        else
                            yPos = starPosFactor*(min(yRaw(iSeeds,:)) - max(eRaw(iSeeds,:)));
                        end
                        xPos = iSeeds;
                        text(xPos, yPos, '*', 'FontSize', starFontSize, 'FontWeight', 'b');
                    end
                end
                if job.save_figures
                    newName = sprintf('groupCorr_Ttest_C%d_(%s)_raw',c1,colorNames{1+c1});
                    switch job.optStat.multComp
                        case 0 % None
                            %Do nothing
                        case 1 % Bonferroni
                            newName = [newName '_Bonferroni'];
                        case 2 % FDR
                            newName = [newName '_FDR'];
                        otherwise
                            % Do nothing
                    end
                    % Save as EPS
                    % spm_figure('Print', 'Graphics', fullfile(job.parent_results_dir{1}, newName));
                    % Save as PNG
                    print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
                    % Save as a figure
                    saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
                    % Return the property to its default
                    set(h, 'units', 'pixels')
                    close(h)
                end
            end % end generate figures
        end
        
        if job.optStat.wilcoxon1
            % Display a graph with ROI labels
            if job.generate_figures
                % Display plots on new figure
                h = figure; set(gcf,'color','w')
                % Specify window units
                set(h, 'units', 'inches')
                % Change figure and paper size
                set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
                % Custom bar graphs with error bars (1st arg: error)
                barwitherr(eRaw, yRaw)
                % Display colormap according to the contrast
                switch(c1)
                    case 1
                        % HbT contrast
                        colormap([0.5 0.5 0.5; 1 1 1]);
                    case 2
                        % SO2 contrast
                        colormap([0.25 0.25 0.25; 1 1 1]);
                    case 3
                        % B-mode contrast
                        colormap([0 0 0; 1 1 1]);
                    case 4
                        % HbO contrast
                        colormap([1 0 0; 1 1 1]);
                    case 5
                        % HbR contrast
                        colormap([0 0 1; 1 1 1]);
                    otherwise
                        colormap(gray)
                end
                switch job.optStat.multComp
                    case 0 % None
                        corrName = '';
                    case 1 % Bonferroni
                        corrName = 'Bonferroni';
                    case 2 % FDR
                        corrName = 'FDR';
                    otherwise
                        % Do nothing
                end
                title(sprintf('C%d(%s) Raw Wilcoxon (*p<%.2g) %s',...
                    c1,colorNames{1+c1},job.optStat.alpha,corrName),'interpreter','none','FontSize',job.optFig.titleFontSize)
                set(gca,'FontSize',axisFontSize)
                ylabel('Functional correlation z(r)','FontSize',job.optFig.yLabelFontSize)
                set(gca,'XTickLabel',job.optFig.xAxisLabels,'FontWeight', 'b','FontSize',job.optFig.xLabelFontSize)
                if isfield(job.optFig.legends, 'legendShow')
                    legend(job.ID,'FontSize',job.optFig.legends.legendShow.legendFontSize,'location',job.optFig.legends.legendShow.legendLocation)
                end
                set(gca, 'xLim', [axMargin size(yRaw,1) + axMargin]);
                if isfield(job.optFig.yLimits, 'yLimManual')
                    set(gca, 'ylim', job.optFig.yLimits.yLimManual.yLimValue)
                end
                % Show a * when a significant difference is found.
                for iSeeds = 1:size(job.paired_seeds, 1)
%                     % FDR-corrected p-value (q)
%                     if job.optStat.multComp == 2
%                         if pat_fdr(statTestRaw(1).w(1).H{iSeeds,c1}) < job.pValue
%                             % Significant difference
%                             statTestRaw(1).w(1).H{iSeeds,c1} = true;
%                         else
%                             % Non significant difference
%                             statTestRaw(1).w(1).H{iSeeds,c1} = false;
%                         end
%                     end
                    if statTestRaw(1).w(1).H{iSeeds,c1}
                        if max(yRaw(iSeeds,:))>=0
                            yPos = starPosFactor*(max(yRaw(iSeeds,:)) + max(eRaw(iSeeds,:)));
                        else
                            yPos = starPosFactor*(min(yRaw(iSeeds,:)) - max(eRaw(iSeeds,:)));
                        end
                        xPos = iSeeds;
                        text(xPos, yPos,'*', 'FontSize', starFontSize, 'FontWeight', 'b');
                    end
                end
                if job.save_figures
                    newName = sprintf('groupCorr_Wtest_C%d_(%s)_raw',c1,colorNames{1+c1});
                    switch job.optStat.multComp
                        case 0 % None
                            %Do nothing
                        case 1 % Bonferroni
                            newName = [newName '_Bonferroni'];
                        case 2 % FDR
                            newName = [newName '_FDR'];
                        otherwise
                            % Do nothing
                    end
                    % Save as EPS
                    % spm_figure('Print', 'Graphics', fullfile(job.parent_results_dir{1},newName));
                    % Save as PNG
                    print(h, '-dpng', fullfile(job.parent_results_dir{1},newName), sprintf('-r%d',job.optFig.figRes));
                    % Save as a figure
                    saveas(h, fullfile(job.parent_results_dir{1},newName), 'fig');
                    % Return the property to its default
                    set(h, 'units', 'pixels')
                    close(h)
                end
            end % End generate figures
        end % Wilcoxon
    end
end % raw data
end % subfunction_plot_group_corr_test_raw

% EOF
