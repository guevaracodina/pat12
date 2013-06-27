% Oxygen surge PAT strutures
PATmat = {
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-16-25_toe04\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-17-27_toe05\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-18-31_ctl03_OS1\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-18-31_ctl03_OS2\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-20-12_toe03\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-21-53_ctl01\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-23-04_toe08\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-23-51_toe09\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DA_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DB_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DC_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DD_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DE_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DF_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DG_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DH_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DI_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DJ_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DK_OS\PAT.mat'
  'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DL_OS\PAT.mat'};

%% Display TR
clc
for scanIdx = 1: numel(PATmat)
    load(PATmat{scanIdx});
    [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
    scanName = splitStr{end-1};
    TR = pat_get_TR(PAT);
    fprintf('%s TR = %0.2f s.\n', scanName, TR);
end
    
% EOF
