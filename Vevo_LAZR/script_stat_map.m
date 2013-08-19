%% script_stat_map
%% Read files
% Get anatomical image
anatVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment\',...
    'normalization_AVG_scale.nii'));
anatomical          = spm_read_vols(anatVol);


% Read brain mask
maskVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment',...
    'brain_mask.nii'));
brainMask           = logical(spm_read_vols(maskVol));

% Get functional images from ctrl group
ctrlVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment\SO2\Ctrl',...
    'Ctrl_ROI05_SO2_stack.img'));
ctrl                = 1 + spm_read_vols(ctrlVol);
% Mask out non-brain elements
ctrl(~repmat(brainMask,[1 1 size(ctrl,3)])) =  nan;
% Get functional images from LPS group
LPSVol              = spm_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment\SO2\LPS',...
    'LPS_ROI05_SO2_stack.img'));
LPS                 = 1 + spm_read_vols(LPSVol);
% Mask out non-brain elements
LPS(~repmat(brainMask,[1 1 size(LPS,3)])) =  nan;

%% Fisher's transform
zctrl = pat_fisherz(ctrl);
zLPS = pat_fisherz(LPS);

%% standardization by mean & std
meanctrl = nanmean(zctrl(:));
stdctrl = nanstd(zctrl(:));

meanLPS = nanmean(zLPS(:));
stdLPS = nanstd(zctrl(:));

zctrl = (zctrl - meanctrl) ./ stdctrl;
zLPS = (zLPS - meanLPS) ./ stdLPS;

%% t-test statistics across the scans
hMap = zeros([size(zLPS,1) size(zLPS,2)]);
pMap = zeros([size(zLPS,1) size(zLPS,2)]);
alphaVal = 0.05;
pat_text_waitbar(0, 'Please wait...');
for iRows = 1:size(zLPS,1)
    for iCols = 1:size(zLPS,2)
        [hMap(iRows, iCols) pMap(iRows, iCols)] = ttest2(squeeze(zctrl(iRows, iCols, :)), squeeze(zLPS(iRows, iCols, :)), alphaVal, 'both', 'unequal');
    end
    pat_text_waitbar(iRows/size(zLPS,1), sprintf('Processing t-test %d from %d', iRows, size(zLPS,1)));
end
pat_text_waitbar('Clear');

%% FDR-correction
pMapFDR = pat_fdr(pMap(:));
pMapFDR = reshape(pMapFDR, size(pMap));

%% Apply threshold
pMapAlpha = nan(size(pMap));
pMapFDRalpha = pMapAlpha;
pMapAlpha(pMap <= alphaVal) = pMap(pMap <= alphaVal);
pMapFDRalpha(pMapFDR <= alphaVal) = pMapFDR(pMapFDR <= alphaVal);

%% Display p-maps
figure; imagesc(-log(pMapAlpha)); title('uncorrected p-values'); colorbar
figure; imagesc(-log(pMapFDRalpha)); title('FDR adjusted p-values'); colorbar

%% fit Fisher's to a gaussian
% f = fittype('A * exp( -(x-mu)^2 / (2*sigma^2) )');

%% Create nifti
hdr = pat_create_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment\',...
    'ROI05_SO2_pMap_alpha.nii'), anatVol.dim, [64 0], anatVol.pinfo, anatVol.mat, 1, pMapAlpha);
hdr = pat_create_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment\',...
    'ROI05_SO2_pMap_alpha_FDR.nii'), anatVol.dim, [64 0], anatVol.pinfo, anatVol.mat, 1, pMapFDRalpha);

% EOF
