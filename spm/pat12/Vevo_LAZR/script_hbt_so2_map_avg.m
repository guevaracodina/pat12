%% script_hbt_so2_map_avg - Now computes grand average of both sO2 and HbT
clear all; clc
% color to plot (1=HbT, 2=SO2)
c1 = 2;
% Sham or LPS
isSham = true;
%% PAT matrices
% Sham control (NaCl) group (N=8)
job.PATmatCtrl = {  
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                };

% LPS group (N=8)
job.PATmatLPS = {
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                };
%% Read nifti files
for iSubject = 1:numel(job.PATmatCtrl)
    if isSham
        load(job.PATmatCtrl{iSubject})
    else
        load(job.PATmatLPS{iSubject})
    end
    input_dir = PAT.input_dir;
    % c1= 2 for SO2
    nifti_filename = PAT.nifti_files{c1};
    [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
    scanName = splitStr{end-1};
    if c1 == 1
        % HbT
        output_dir = 'F:\Edgar\Data\PAT_Results_20130517\alignment\Average_Maps\HbT';
    else
        % SO2
        output_dir = 'F:\Edgar\Data\PAT_Results_20130517\alignment\Average_Maps\SO2';
    end
    if isSham
        % NaCl (sham) controls
        output_dir = fullfile(output_dir,'NaCl');
    else
        % LPS
        output_dir = fullfile(output_dir,'LPS');
    end
    if ~exist(output_dir,'dir'),mkdir(output_dir); end
    
    % Functional map
    v = spm_vol(nifti_filename);
    I = spm_read_vols(v);
    % Brain mask
    v = spm_vol(PAT.fcPAT.mask.fname);
    brainMask = spm_read_vols(v);
    % Anatomical brainMask
    v = spm_vol(PAT.res.file_anat);
    anatomical = spm_read_vols(v);
    % Convert to SO2 data
    if c1 == 2
        I = pat_raw2so2(I);
    end
    % load scrubbing info and parameters
    load(PAT.motion_parameters.scrub.fname)
    % Scrub images
    Iscrub = I(:,:,1,scrubMask{c1});
    % Average images along time axis
    Imean = mean(Iscrub,4);
    
    % Save average image
    v = spm_vol(nifti_filename);
    pat_create_vol(fullfile(output_dir,[scanName '_avg.nii']), v(1).dim, v(1).dt,...
    v(1).pinfo, v(1).mat, 1, Imean);
end

% EOF
