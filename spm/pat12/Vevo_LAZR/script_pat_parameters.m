%% script_pat_parameters
clear; clc;
fprintf('Acquisition parameters\n')
job.output_dir{1} = 'F:\Edgar\Data\PAT_Results_20130517\';
job.CSVfname{1} = 'pat_acq_params.csv';

% job.PATmat = {  'E:\Edgar\Data\PAT_Results\2012-09-07-14-48-55_ctl02\seedRadius14\BPF\SNR_test\PAT.mat';
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-16-25_toe04\seedRadius10\SNR_test\PAT.mat';
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\seedRadius10\SNR_test\PAT.mat';
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-21-53_ctl01\seedRadius10\SNR_test\PAT.mat';
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-04_toe08\seedRadius10\SNR_test\PAT.mat';
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\seedRadius10\SNR_test\PAT.mat'
%                 'E:\Edgar\Data\PAT_Results\2012-09-07-10-40-07_toe10\seedRadius14\BPF\PAT.mat'
%                 'E:\Edgar\Data\PAT_Results\2012-09-07-11-04-40_toe04\seedRadius14\BPF\PAT.mat'
%                 'E:\Edgar\Data\PAT_Results\2012-09-07-12-10-31_ctl01\seedRadius14\BPF\PAT.mat'
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-17-27_toe05\seedRadius10\PAT.mat'
%                 'E:\Edgar\Data\PAT_Results\2012-11-09-16-20-12_toe03\seedRadius10\PAT.mat'};

job.PATmat = {  
                'E:\Edgar\Data\PAT_Results\2012-09-07-14-48-55_ctl02\seedRadius14\BPF\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-16-25_toe04\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-21-53_ctl01\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-04_toe08\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\seedRadius10\SNR_test\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-09-07-10-40-07_toe10\seedRadius14\BPF\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-09-07-11-04-40_toe04\seedRadius14\BPF\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-09-07-12-10-31_ctl01\seedRadius14\BPF\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-17-27_toe05\seedRadius10\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-20-12_toe03\seedRadius10\PAT.mat'    
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DD_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DI_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DJ_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS3\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DA_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DB_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DC_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DD_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DE_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DF_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DG_OS\ROI\PAT.mat';
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DH_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DI_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DJ_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DK_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DL_OS\PAT.mat'
                };
% PAT copy/overwrite method
job.PATmatCopyChoice = pat_PATmatCopyChoice_cfg('persistence_test');

%% Main loop
for c1=1:1
    [PAT PATmat dir_patmat]= pat_get_PATmat(job,1);
    fileNameTXT = fullfile(PAT.output_dir, 'bModeframeData.txt');
    % Extract frame rate
    fid = fopen(fileNameTXT);
    data = textscan(fid, '%s %d: %s %d, %s = %f, %s %d', 'HeaderLines', 8, 'CollectOutput', true);
    TR = median(diff(data{1,6})) / 1000;    % TR in seconds, data{1,6} in ms
    fprintf('Frame rate = %0.2f fps\n', 1/TR);
    fclose(fid);
    for scanIdx = 1:length(job.PATmat)
        clear ROI
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        disp(TR)
        % First row
        if scanIdx == 1,
            save_data = fullfile(job.output_dir{1},job.CSVfname{c1});
            fid = fopen(save_data, 'w');
            fprintf(fid, 'Scan ID,');
            fieldNames = fieldnames(PAT.PAparam);
            for iParam = 1:numel(fieldNames)
                fprintf(fid, '%s,', fieldNames{iParam});
            end % ROIs loop
            fprintf(fid, 'TR\n');
        end
        % scan name
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        fprintf(fid, '%s,',scanName);
        for iParam = 1:numel(fieldNames)
            % parameters retrieving
            if numel(PAT.PAparam.(fieldNames{iParam})) == 1
                fprintf(fid, '%6.4f,', PAT.PAparam.(fieldNames{iParam}));
            else
                fprintf(fid, 'NaN,');
            end
        end % ROIs loop
        fprintf(fid, '%6.4f\n', TR);
    end % scans loop
    % close .CSV file
    fclose(fid);
end % colors loop


% EOF
