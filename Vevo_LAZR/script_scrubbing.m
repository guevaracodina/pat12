%%
% PA color
c1 = 2;
load('F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\PAT.mat')
% FD threshold
job.FDthreshold = 0.0008;
job.DVARSthreshold = 3000;
% Get radius from the batch interface
skulltop2base = 6.425; % mm
biparietalDiameter = 9.785; % mm
radius = mean([skulltop2base biparietalDiameter])/2; % mm
% Compute Framewise displacement (FD)
Q = load (PAT.motion_parameters.fnameMAT);
Q = Q.Q;
FD = pat_compute_FD(Q, radius);
% Temporary selection
FD = FD(1:217);

% Compute DVARS measure
load('E:\Edgar\Data\PAT_Results\2012-11-09-16-21-53_ctl01\seedRadius10\GLMfcPAT_LVregressor\PAT.mat')
% Manually found indices 194:199, 213
DVARS = pat_compute_DVARS(PAT, c1);

%%
h = figure; 
subplot(311)
plot(FD)
hold on
plot([1 numel(FD)], [job.FDthreshold job.FDthreshold], 'r:')
axis tight

h2 = figure; 
subplot(311)
plot(DVARS)
hold on
plot([1 numel(DVARS)], [job.DVARSthreshold job.DVARSthreshold], 'r:')
axis tight

% Masks creation
FDmask = FD >= job.FDthreshold;
DVARSmask = DVARS >= job.DVARSthreshold;

figure(h); subplot(312)
imagesc(FDmask'); colormap(gray); axis tight
figure(h2); subplot(312)
imagesc(DVARSmask'); colormap(gray); axis tight

% Augmented temporal mask by also marking the frames 1 back and 2 forward from
% any marked frames

% Find indices
idxL = find(FDmask(2:end));
idxR = find(FDmask(1:end-1));
FDmask(idxL-1) = true;
FDmask(idxR+1) = true;

figure(h); subplot(313)
imagesc(FDmask'); colormap(gray); axis tight

% Find indices
idxL = find(DVARSmask(2:end));
idxR = find(DVARSmask(1:end-1));
DVARSmask(idxL-1) = true;
DVARSmask(idxR+1) = true;

figure(h2); subplot(313)
imagesc(DVARSmask'); colormap(gray); axis tight

% Create temporal masking, conservatively choosing the intersection (AND) of the
% two temporal masks to generate a final temporal mask
temporalMask = FDmask & DVARSmask;

figure; 
subplot(311); imagesc(FDmask'); colormap(gray); axis tight
subplot(312); imagesc(DVARSmask'); colormap(gray); axis tight
subplot(313); imagesc(temporalMask'); colormap(gray); axis tight

%% save figures

