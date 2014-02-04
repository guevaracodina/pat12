%% script_global_signal_regression
% Simulation time
tf = 300;
% Acquisition period
TR = 1.4011;
% Time vector
t = 0:TR:tf;
% Amplitude of ROI
A = 1;
% Amplitude of global signal
B = 1;
% Offset of ROI signal
DCroi = 0*A;
% Offset of global signal
DCglobal = 0*B;
% frequency of ROI fluctuations
fROI = 0.05;
% frequency of global fluctuations
fGlobal = 0.02;
% random global signal phase
a = -pi; b = pi;
randPhase = a + (b-a).*rand(1,1);
% Noise percentage
noisePer = 0.2*A;
% ROI noisy time course
roi = DCroi + A*sin(2*pi*fROI*t + randPhase) + noisePer*randn(size(t));
% Global signal noisy time course
gSignal = DCglobal + B*sin(2*pi*fGlobal*t + randPhase) + noisePer*randn(size(t));
% measured roi time course
measRoi = roi + gSignal;

%% Global signal regression
ROIdir = 'F:\Edgar\Data\PAT_Results\PAS2013\regressionTest';
% Initialize single voxel
measRoi4d = zeros([1 1 1 numel(measRoi)]);
% Single frame dimensions: [nDepth nWidth 1]
volMeasRoi.dim = [1 1 1];
% Data type
volMeasRoi.dt = [spm_type('float64') spm_platform('bigend')];
% Plane info
volMeasRoi.pinfo = ones(3,1);
% Final Affine transformation matrix: 
volMeasRoi.mat = eye(4);
% Create a single voxel 4-D series
measRoi4d(1,1,1,:) = measRoi;
clc;
fprintf('Saving measured signal as NIfTI\n')
volMeasRoi = pat_create_vol_4D(fullfile(ROIdir,'measRoi.nii'), volMeasRoi, measRoi4d);

%% Creating nifti files to be able to use SPM later
% --------------------------
% 4-D series
clear SPM
SPM.xY.VY = spm_vol(fullfile(ROIdir,'measRoi.nii'));
regressedROI = zeros([1 1 1 numel(measRoi)]);
fnameNIFTI = fullfile(ROIdir,'measRoiRegress.nii');
dim = [1 1 1];
% Create a single voxel 4-D series
regressedROI4d(1,1,1,:) = zeros(size(measRoi));
% Create volume header structure
volROI = SPM.xY.VY;
for iPlanes = 1:numel(volROI)
    volROI(iPlanes).dim = dim;
    volROI(iPlanes).fname = fnameNIFTI;
    volROI(iPlanes).mat = [ 1 0 0 0;
        0 1 0 0;
        0 0 1 0;
        0 0 0 1];
end
% --------------------------
% end of nifti processing

%% Constructing inputs
% required for GLM analysis within the SPM framework
% All regressors are identified here, lets take the mean global signal just to
% test
SPM.xX.name = cellstr(['Global Brain Signal']);
SPM.xX.X = gSignal';        % Regression is along first dimension. For one regressor it is a column vector.

% A revoir
SPM.xX.iG = [];
SPM.xX.iH = [];
SPM.xX.iC = 1:size(SPM.xX,2);   % Indices of regressors of interest
SPM.xX.iB = [];                 % Indices of confound regressors
SPM.xGX.rg = [];                % Raw globals, need to check this //EGC

SPM.xVi.Vi = {speye(size(SPM.xX.X,1))}; % Time correlation

% Directory to save SPM and NIfTI files
SPM.swd = ROIdir;
if ~exist(SPM.swd,'dir'),mkdir(SPM.swd); end


%% GLM is performed here
cd(ROIdir)
% GLM is performed here
SPM = spm_spm(SPM);
% Subtract global brain signal from ROI time courses
betaVol = spm_vol(fullfile(SPM.swd,SPM.Vbeta.fname));
beta = spm_read_vols(betaVol);
regressedROI = measRoi - beta * gSignal;
% Create a single voxel 4-D series
regressedROI4d(1,1,1,:) = regressedROI;
fprintf('Saving regressed signal as NIfTI\n')
pat_create_vol_4D(fnameNIFTI, volROI, regressedROI4d);
% 
% rROI = spm_read_vols(volROI);
% 
% oROI = spm_read_vols(volMeasRoi);


%% Display figures
h = figure; set(h,'color','w')
subplot(231)
plot(t,roi,'k-')
xlim([t(1) tf])
xlabel('t[s]')
title('Underlying ROI time course \bf\it{r}')

subplot(232)
plot(t,gSignal,'k-')
xlim([t(1) tf])
xlabel('t[s]')
title('Global signal time course \bf\it{g}')

subplot(233)
plot(t,measRoi,'k-')
xlim([t(1) tf])
xlabel('t[s]')
title('Measured ROI time course \bf\it{y = r + g}')

subplot(234)
plot(t,regressedROI,'k-')
xlim([t(1) tf])
xlabel('t[s]')
title('Regressed ROI time course \bf\it{y''}')

subplot(235)
plot(t,(regressedROI - measRoi)./(sqrt (mean (measRoi .^2) )),'k-')
xlim([t(1) tf])
xlabel('t[s]')
ylabel('Relative Error [%]')
title('Error in regression \bf\it{(y''-r)/<r>}')

%% Print figure
set(h, 'units', 'inches')
figSize = [0.1 0.1 8 5];
set(h, 'Position', figSize); set(h, 'PaperPosition', figSize);
newName = 'PAS2013_regression';
print(h, '-dpng', fullfile(ROIdir,newName), sprintf('-r%d',300));
% Save as a figure
saveas(h, fullfile(ROIdir,newName), 'fig');
close(h);

% EOF
