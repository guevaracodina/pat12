function PAT = pat_create_anatomical_file(PAT)
% Creates anatomical file from first image of B-mode file.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% Local function to extract the first frame of the B-mode image and resize it to
% the dimensions of PA images, save it as anatomical.nii file
idxBmode = regexp(PAT.color.eng, PAT.color.Bmode);
volBmode = spm_vol(PAT.nifti_files{1,idxBmode});
im_anat = spm_read_vols(volBmode);
% Quick dirty way to have only the 1st image
im_anat = squeeze(im_anat(:,:,1,1));
% HbT image
idxPAmode = regexp(PAT.color.eng, PAT.color.HbT);
volPAmode = spm_vol(PAT.nifti_files{1,idxPAmode});
if ~isempty(volPAmode)
    im_PA = spm_read_vols(volPAmode);
    % Quick dirty way to have only the 1st image
    im_PA = squeeze(im_PA(:,:,1,1));
else
    % Take B-mode image
    volPAmode = volBmode;
    im_PA = im_anat;
end


% Do not resize, keep original dimensions
% if size(im_anat,1)~= size(im_PA,1)|| size(im_anat,2)~= size(im_PA,2)
%     im_anat = pat_imresize(im_anat, [size(im_PA,1) size(im_PA,2)]);
% end

% Create filename according the existing nomenclature at scan level
PAT.res.file_anat = fullfile(PAT.output_dir, 'anatomical.nii');
% Create and write a NIFTI file in the scan folder
% Save B-mode image
pat_create_vol(PAT.res.file_anat, volBmode(1).dim, volBmode(1).dt,...
    volBmode(1).pinfo, volBmode(1).mat, 1, im_anat);
% Save PA HbT image
% pat_create_vol(PAT.res.file_anat, volPAmode(1).dim, volPAmode(1).dt,...
%     volPAmode(1).pinfo, volPAmode(1).mat, 1, im_PA);
end

% EOF
