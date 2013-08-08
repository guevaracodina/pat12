%% script_pat_SNR_test
clear; clc;
fprintf('SNR comparison among ROIs\n')
job.output_dir{1} = 'F:\Edgar\Data\PAT_Results_20130517\RS\SNR\';
job.CSVfname{1} = 'SNR_ROIs_HbT.csv';
job.CSVfname{2} = 'SNR_ROIs_SO2.csv';
% List of PAT structures
job.PATmatLPS = {
                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                 };
job.PATmatCtrl = {
                  'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-12-10-31_ctl01\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-14-48-55_ctl02\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-18-31_ctl03\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DI_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DJ_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS3\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E10_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E11_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E12_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E13_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  };
job.PATmatNaCl = {
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\corrMap\hbo_hbr\PAT.mat'
                  };
% Full list
job.PATmat = [job.PATmatLPS; job.PATmatCtrl; job.PATmatNaCl ];
% PAT copy/overwrite method
job.PATmatCopyChoice = pat_PATmatCopyChoice_cfg('SNR_test');
% index of starting ROI
startROI = 5;
%% Main loop
for c1=1:2
    for scanIdx = 1:length(job.PATmat)
        clear ROI
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        % First row
        if scanIdx == 1,
            save_data = fullfile(job.output_dir{1},job.CSVfname{c1});
            fid = fopen(save_data, 'w');
            fprintf(fid, 'Scan ID,');
            for iROI = startROI:numel(PAT.ROI.ROIname)
                fprintf(fid, '%s,', PAT.ROI.ROIname{iROI});
            end % ROIs loop
            fprintf(fid, '\n');
        end
        % scan name
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        fprintf('%s TR = %0.4fs\n',scanName, PAT.fcPAT.filtNdown.TR)
        fprintf(fid, '%s,',scanName);
        % Begin in ROI No. 5
        for iROI = startROI:numel(PAT.ROI.ROIname)
            load(PAT.ROI.ROIfname)
            % SNR computation ROI 19 is noise
            SNR = mean(ROI{iROI}{c1}) ./ std(ROI{iROI}{c1});
            fprintf(fid, '%6.4f,',SNR);
        end % ROIs loop
        fprintf(fid, '\n');
    end % scans loop
    % close .CSV file
    fclose(fid);
end % colors loop
fprintf('SNR extraction done!\n');
% EOF

%% Plot
fontSize = 12;
% SO2
y1 = [12.90424848;  8.971846667;    9.68816875];
e1 = [0.751309477;  0.348593512;    0.359192513];
h = figure; set(h, 'color', 'w')
subplot(121)
pat_barwitherr(e1, y1);
set(gca,'FontSize',fontSize)
ylabel('<SNR>','FontSize',fontSize);
set(gca, 'xTickLabel',{'LPS' 'Ctrl' 'NaCl'},'FontSize',fontSize)
title('SO_2','FontSize',fontSize)

% HbT
y2 = [53.12018788;	32.53904167;    75.76210417];
e2 = [10.42317194;  3.118121174;    13.33722642];
subplot(122)
pat_barwitherr(e2, y2);
title('HbT','FontSize',fontSize)
set(gca, 'xTickLabel',{'LPS' 'Ctrl' 'NaCl'},'FontSize',fontSize)
