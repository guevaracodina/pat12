%% script_pat_parameters
clear; clc;
fprintf('Acquisition parameters\n')
job.output_dir{1} = 'E:\Edgar\Data\PAT_Results\';
job.CSVfname{1} = 'pat_acq_params.csv';
% job.CSVfname{2} = 'SNR_ROIs_SO2.csv';
job.PATmat = {  'E:\Edgar\Data\PAT_Results\2012-09-07-14-48-55_ctl02\seedRadius14\BPF\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-16-25_toe04\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-21-53_ctl01\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-04_toe08\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\seedRadius10\SNR_test\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-09-07-10-40-07_toe10\seedRadius14\BPF\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-09-07-11-04-40_toe04\seedRadius14\BPF\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-09-07-12-10-31_ctl01\seedRadius14\BPF\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-17-27_toe05\seedRadius10\PAT.mat'
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-20-12_toe03\seedRadius10\PAT.mat'};
% PAT copy/overwrite method
job.PATmatCopyChoice = pat_PATmatCopyChoice_cfg('SNR_test');

%% Main loop
for c1=1:1
    for scanIdx = 1:length(job.PATmat)
        clear ROI
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        disp(PAT.fcPAT.filtNdown.TR)
        % First row
        if scanIdx == 1,
            save_data = fullfile(job.output_dir{1},job.CSVfname{c1});
            fid = fopen(save_data, 'w');
            fprintf(fid, 'Scan ID,');
            fieldNames = fieldnames(PAT.PAparam);
            for iROI=1:numel(fieldNames)
                fprintf(fid, '%s,', fieldNames{iROI});
            end % ROIs loop
            fprintf(fid, 'TR\n');
        end
        % scan name
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        fprintf(fid, '%s,',scanName);
        for iROI=1:numel(fieldNames)
            % parameters retrieving
            if numel(PAT.PAparam.(fieldNames{iROI})) == 1
                fprintf(fid, '%6.4f,', PAT.PAparam.(fieldNames{iROI}));
            else
                fprintf(fid, 'NaN,');
            end
        end % ROIs loop
        fprintf(fid, '%6.4f\n', PAT.fcPAT.filtNdown.TR);
    end % scans loop
    % close .CSV file
    fclose(fid);
end % colors loop


% EOF
