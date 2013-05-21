%% script_pat_SNR_test
clear; clc;
fprintf('SNR comparison among ROIs\n')
job.output_dir{1} = 'E:\Edgar\Data\PAT_Results\';
job.CSVfname{1} = 'SNR_ROIs_HbT.csv';
job.CSVfname{2} = 'SNR_ROIs_SO2.csv';
job.PATmat = {  'E:\Edgar\Data\PAT_Results\2012-09-07-14-48-55_ctl02\seedRadius14\BPF\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-16-25_toe04\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-21-53_ctl01\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-04_toe08\seedRadius10\SNR_test\PAT.mat';
                'E:\Edgar\Data\PAT_Results\2012-11-09-16-23-51_toe09\seedRadius10\SNR_test\PAT.mat'};
% PAT copy/overwrite method
job.PATmatCopyChoice = pat_PATmatCopyChoice_cfg('SNR_test');

%% Main loop
for c1=1:2
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
            for iROI=1:numel(PAT.ROI.ROIname)-1
                fprintf(fid, '%s,', PAT.ROI.ROIname{iROI});
            end % ROIs loop
            fprintf(fid, '\n');
        end
        % scan name
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        fprintf(fid, '%s,',scanName);
        for iROI=1:numel(PAT.ROI.ROIname)-1
            load(PAT.ROI.ROIfname)
            % SNR computation
            SNR = mean(ROI{iROI}{c1}) ./ std(ROI{19}{c1});
            fprintf(fid, '%6.4f,',SNR);
        end % ROIs loop
        fprintf(fid, '\n');
    end % scans loop
    % close .CSV file
    fclose(fid);
end % colors loop


% EOF
