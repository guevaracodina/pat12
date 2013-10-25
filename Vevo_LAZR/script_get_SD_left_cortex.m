%% script_get_SD_left_cortex 
% compute standard deviations of so2 values in left cortex, used for figure 2
% plos one
%% PAT matrices
clear
% Color SO2, c1=2
c1 = 2;
% ROI Left Cortex = 11
r1 = 11;
% Control group
job.PATmatCtrl = {  
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\newROIs\PAT.mat'
                };

% LPS group
job.PATmatLPS = {
%                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\newROIs\PAT.mat'
%                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\newROIs\PAT.mat'
%                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\newROIs\PAT.mat'
%                 'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\newROIs\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\newROIs\PAT.mat'
                };
%% Compute s.d. and S.E.M.
% NaCl
for iSubject = 1:numel(job.PATmatCtrl)
    load(job.PATmatCtrl{iSubject})
    load(PAT.ROI.ROIfname)
    NaCl.sd(iSubject) = std(pat_raw2so2(ROI{r1}{c1}));
    NaCl.SEM(iSubject) = std(pat_raw2so2(ROI{r1}{c1}))./sqrt(numel(ROI{r1}{c1}));
end
% LPS
for iSubject = 1:numel(job.PATmatLPS)
    load(job.PATmatLPS{iSubject})
    LPS.sd(iSubject) = std(pat_raw2so2(ROI{r1}{c1}));
    LPS.SEM(iSubject) = std(pat_raw2so2(ROI{r1}{c1}))./sqrt(numel(ROI{r1}{c1}));
end

save('F:\Edgar\Data\PAT_Results_20130517\RS\locoregional\LeftCortex\locoregional_SO2_data_SEM.mat',...
    'NaCl', 'LPS')

% EOF

