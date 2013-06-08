%% script_scrubbing
clc; close all

% Frames augmented in mask
job.framesAugmentedBackward = 1;
job.framesAugmentedForward = 2;
% FD threshold
job.FDthreshold = 0.0008;
% DVARS threshold
job.DVARSthreshold = 3000;
% Intersection of both masks is a more conservative approach
job.intersection = true;
% Get radius from the batch interface
skulltop2base = 6.425; % mm
biparietalDiameter = 9.785; % mm
job.radius = mean([skulltop2base biparietalDiameter])/2; % mm

% Load PAT structure
load('F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\BrainMask\ROI\LPF\ROItimeCourse\BPF\GLMfcPAT\PAT.mat')
% PA color
c1 = 2;

% Load motion parameters Q
Q = load (PAT.motion_parameters.fnameMAT);
Q = Q.Q;
% Compute Framewise displacement (FD)
FD = pat_compute_FD(Q, job.radius);
% Compute DVARS measure
DVARS = pat_compute_DVARS(PAT, c1);

%% Create figure
h = figure; 
subplot(421)
plot(FD)
hold on
plot([1 numel(FD)], [job.FDthreshold job.FDthreshold], 'r:')
axis tight

figure(h); subplot(422)
plot(DVARS)
hold on
plot([1 numel(DVARS)], [job.DVARSthreshold job.DVARSthreshold], 'r:')
axis tight

% Masks creation
FDmask = FD >= job.FDthreshold;
DVARSmask = DVARS >= job.DVARSthreshold;

figure(h); subplot(423)
imagesc(FDmask'); colormap(gray); axis tight
figure(h); subplot(424)
imagesc(DVARSmask'); colormap(gray); axis tight

% Augmented temporal mask by also marking the frames 1 back and 2 forward from
% any marked frames
% Find indices
idxL = find(FDmask(2:end));
idxR = find(FDmask(1:end-1));
% Augment mask
FDmask(idxL - job.framesAugmentedBackward:idxL) = true;
FDmask(idxR:idxR + job.framesAugmentedForward) = true;

figure(h); subplot(425)
imagesc(FDmask'); colormap(gray); axis tight

% Find indices
idxL = find(DVARSmask(2:end));
idxR = find(DVARSmask(1:end-1));
% Augment mask
DVARSmask(idxL - job.framesAugmentedBackward:idxL) = true;
DVARSmask(idxR:idxR + job.framesAugmentedForward) = true;

figure(h); subplot(426)
imagesc(DVARSmask'); colormap(gray); axis tight

% Create temporal masking, conservatively choosing the intersection (AND) of the
% two temporal masks to generate a final temporal mask
if job.intersection
    temporalMask = FDmask & DVARSmask;
else
    temporalMask = FDmask | DVARSmask;
end

figure(h); subplot(414); imagesc(temporalMask'); colormap(gray); axis tight

%% save figures

