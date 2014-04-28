%% Creates a NIfTI file containing a given structure
% Brain atlas file
labelsFile = 'E:\Edgar\PAT_mice\Atlas\c57_fixed_labels_resized.nii';
% Choose a structure;
chosenROIlabel = 'left_corpus_callosum';

%% Process
% Get full path
[pathName, fileName, ext] = fileparts(labelsFile);
% Read segmented atlas file
Vlabels = spm_vol(labelsFile);
% Segment image containing all brain atlas labels
labels = spm_read_vols(Vlabels);
% Get brain atlas labels
BS = pat_brain_atlas_labels;
% label index
chosenROI = getfield(BS, chosenROIlabel);
% copy volume to target V
V = Vlabels;
% change target file name
V.fname = fullfile(pathName, [chosenROIlabel ext]);
% change description
V.descrip = chosenROIlabel;
% Choose only those voxels belonging to the ROI
ROI = labels .* (labels == chosenROI);
% Write volume to disk
spm_write_vol(V, ROI);

% EOF
