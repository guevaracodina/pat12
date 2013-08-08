function out = pat_change_seeds_size_run(job)
% Changes size of previously stablished seeds
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

% Get radius
radius = job.ManualROIradius;

% job.ManualROIradius is in mm
radiusX         = job.ManualROIradius;
radiusY         = job.ManualROIradius;
        
% Get ROI info
[all_ROIs selected_ROIs] = pat_get_rois(job);
for scanIdx=1:length(job.PATmat)
    try
        %Load PAT.mat information
        [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
        % Read anatomical image
        try
            % vol_anat = spm_vol(PAT.res.file_anat);
            vol_anat = spm_vol(PAT.fcPAT.mask.fname);
        catch
            disp('Could not find anatomical image');
            [t sts] = spm_select(1,'image','Select anatomical image','',dir_patmat,'.*',1);
            PAT.res.file_anat = t;
            vol_anat = spm_vol(PAT.res.file_anat);
        end
        im_anat = spm_read_vols(vol_anat);
        if ~isfield(PAT.jobsdone,'ROIOK') || job.force_redo
            for iSeeds = 1:length(PAT.res.ROI)
                if all_ROIs || sum(r1==selected_ROIs)
                    % Save new ROI radius
                    PAT.res.ROI{iSeeds}.radius = radius;
                    % Save new ROI name
                    PAT.res.ROI{iSeeds}.name = sprintf('%s_r_%02d_pix',PAT.res.ROI{iSeeds}.name, round(job.ManualROIradius/PAT.PAparam.pixWidth));
                    % Circular seed setup
                    t = 0:pi/100:2*pi;
                    % Center of the seed coordinates (NOTE: X and Y are inverted)
                    x0 = PAT.res.ROI{iSeeds}.center(2);
                    y0 = PAT.res.ROI{iSeeds}.center(1);
                    % Get radius in pixels (job.ManualROIradius is in mm)
                    radiusX = job.ManualROIradius/PAT.PAparam.pixWidth;
                    radiusY = job.ManualROIradius/PAT.PAparam.pixDepth;
                    % Parametric function for a circle
                    xi = radiusX * cos(t) + x0;
                    yi = radiusY * sin(t) + y0;
                    % Create ROI/seed mask
                    mask = poly2mask(xi, yi, size(im_anat,1), size(im_anat,2));
                    mask = single(mask);
                    % Backup original ROI filename
                    PAT.res.ROI{iSeeds}.fnameOriginal = PAT.res.ROI{iSeeds}.fname;
                    % New ROI filename
                    [dir1, fil1, ext1] = fileparts(PAT.res.ROI{iSeeds}.fname);
                    % newROIfileName = sprintf('%s_r_%02d_pix',PAT.res.ROI{iSeeds}.fname, radius);
                    newROIfileName = fullfile(dir1, [fil1 '_r_' sprintf('%02dx%02d',round(radiusX),round(radiusY)) '_pix' ext1]);
                    % Save nifti files in ROI sub-folder //EGC
                    [~, fil1] = fileparts(newROIfileName);
                    fname_mask = fullfile(dir_patmat,[fil1 ext1]);
                    PAT.res.ROI{iSeeds}.fname = fname_mask;
                    % Create and write a NIFTI file with ROI mask
                    pat_create_vol(fname_mask, vol_anat(1).dim, vol_anat(1).dt,...
                        vol_anat(1).pinfo, vol_anat(1).mat, 1, mask);
                end
            end
            % ROI creation succesful
            PAT.jobsdone.ROIOK = true;
            save(PATmat,'PAT');
        end
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        fprintf('Scan %s, %d of %d complete\n', splitStr{end-1}, scanIdx, length(job.PATmat));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
    end % End try
end % Scans loop
end % pat_change_seeds_size_run

% EOF

