function out = pat_brainmask_run(job)
% Manual segmentation of the brain to provide a mask for resting-state
% functional connectivity mapping with photoacoustic tomography (fcPAT)
% analysis. User should only select those pixels belonging to the brain.
% SYNTAX:
% out = pat_brainmask_run(job)
% INPUTS:
% job
% OUTPUTS:
% out       Structure containing the names of PAT matrices
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------

% Add Vevo LAZR related functions
addpath(['.',filesep,'Vevo_LAZR/'])

for scanIdx = 1:length(job.PATmat)
    try
        tic
        % Load PAT.mat information
        [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
        if ~isfield(PAT, 'jobsdone')
            PAT.jobsdone = struct([]);
        end
        if ~isfield(PAT, 'fcPAT')
            % Create fcPAT field to contain the whole structure of fcPAT utilities
            PAT.fcPAT = struct([]);
            PAT.fcPAT(1).mask = struct([]);
            PAT.fcPAT(1).LPF  = struct([]);
            PAT.fcPAT(1).filtNdown = struct([]);
            PAT.fcPAT(1).SPM = struct([]);
            PAT.fcPAT(1).corr = struct([]);
        end
        if ~isfield(PAT.jobsdone,'maskOK') || job.force_redo
            % Read anatomical NIFTI file
            vol = spm_vol(PAT.res.file_anat);
            im_anat = spm_read_vols(vol);
            
            % 2-Afficher et utiliser imroi pour que l'usager puisse manuellement
            % identifier la zone d'intérêt contenant le cerveau (on click un
            % polygone)
            
            % Display anatomical image on SPM graphics window
            spm_figure('GetWin', 'Graphics');
            spm_figure('Clear', 'Graphics');
            
            % Start interactive ROI tool to choose spline brain mask
            % ------------------------------------------------------------------
            BW_mask = pat_roi_spline(im_anat);
            % ------------------------------------------------------------------
            
            % Display masked image on SPM graphics window
            minVal = min(im_anat(:));
            maxVal = max(im_anat(:));
            imagesc(PAT.PAparam.DepthAxis, PAT.PAparam.WidthAxis, im_anat .* BW_mask, [minVal maxVal]);
            axis image
            set(gca,'FontSize',12);
            xlabel('Width [mm]','FontSize',14);
            ylabel('Depth [mm]','FontSize',14);
            title(['Mask for subject ' dir_patmat],'FontSize',14)
            
            % 3-Sauver en sortie une image nifti qui s'appelle brainmask.nii qui
            % vaut 1 dans le cerveau et 0 en dehors.
            
            % Create filename according the existing nomenclature at scan level
            brainMaskName = fullfile(dir_patmat, 'brainmask.nii');
            
            % Create and write a 1-slice NIFTI file in the scan folder
            pat_create_vol(brainMaskName, vol(1).dim, vol(1).dt,...
                vol(1).pinfo, vol(1).mat, 1, BW_mask);

            if isempty(PAT.fcPAT.mask)
                % To avoid emptyDotAssignment we create a field
                PAT.fcPAT.mask = struct('fname', []);
            end
            
            % Identifier dans PAT le nom du fichier masque
            PAT.fcPAT.mask.fname = brainMaskName;
            % Mask created succesfully!
            PAT.jobsdone.maskOK = true;
            save(PATmat,'PAT');
        end
        out.PATmat{scanIdx} = PATmat;
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        fprintf('Subject %d of %d complete\n', scanIdx, length(job.PATmat));
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
    end % End try
end % End scans loop
end % End function

% EOF
