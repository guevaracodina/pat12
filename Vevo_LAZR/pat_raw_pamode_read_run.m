function out = pat_raw_pamode_read_run(job)
% Batch function to import .raw.pamode files into NIfTI files.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% % out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------

% Add Vevo LAZR related functions
addpath(['.',filesep,'Vevo_LAZR/'])
try
    for scanIdx = 1:length(job.input_dir)
        tic
        % Set save structure and associated directory
        clear PAT
        PAT.input_dir = job.input_dir{scanIdx};
        if ~isfield(PAT, 'jobsdone')
            PAT.jobsdone = struct([]);
        end
        % Current input dir
        filesdir = job.input_dir{scanIdx};
        % Extract only raw.pamode files
        files = dir(fullfile(filesdir,'*.raw.pamode'));
        dirlen = size(job.input_data_topdir{1},2);
        [pathstr, ~] = fileparts(filesdir);
        % Current output dir
        PAT.output_dir = fullfile(job.output_dir{1},pathstr(dirlen+1:end));
        if ~exist(PAT.output_dir,'dir'),mkdir(PAT.output_dir); end
        % current PAT structure
        PATmat = fullfile(PAT.output_dir,'PAT.mat');
        
        % Color names
        str_HbT         = 'T';
        str_SO2         = 'S'; 
        str_Bmode       = 'B';
        str_color       = [str_HbT str_SO2 str_Bmode];
        PAT.color.eng   = str_color;
        PAT.color.HbT   = str_HbT;
        PAT.color.SO2   = str_SO2;
        PAT.color.Bmode = str_Bmode;
    
        % Preallocate cell with filenames
        PAT.nifti_files = cell(length(files),length(PAT.color.eng));
        PAT.nifti_files_affine_matrix = cell(length(files),length(PAT.color.eng));
        for fileIdx = 1:length(files)
            [nifti_filename affine_mat_filename PAT.PAparam] = pat_raw2nifti(...
                fullfile(filesdir,files(fileIdx).name), PAT.output_dir);
            % HbT
            PAT.nifti_files{fileIdx,1} = nifti_filename{1};
            % SO2
            PAT.nifti_files{fileIdx,2} = nifti_filename{2};
            % HbT
            PAT.nifti_files_affine_matrix{fileIdx,1} = affine_mat_filename{1};
            % SO2
            PAT.nifti_files_affine_matrix{fileIdx,2} = affine_mat_filename{2};
        end % files loop
        % Create anatomical file from HbT data 
        % (it should be done from B-mode data, but it's not yet available)
        PAT = local_create_anatomical_file(PAT);
        % raw.pamode extraction done!
        PAT.jobsdone(1).extract_rawPAmode = true;
        save(PATmat,'PAT');
        out.PATmat{scanIdx} = PATmat;
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        fprintf('Subject %d of %d complete\n', scanIdx, length(job.input_dir));
    end % scans loop
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    out.PATmat{scanIdx} = PATmat;
end % End Try
end % End function

function PAT = local_create_anatomical_file(PAT)
% Local function to extract the first frame of the image
vol = spm_vol(PAT.nifti_files{1,1});
im_anat = spm_read_vols(vol);
% Quick dirty way to have only the 1st image
im_anat = squeeze(im_anat(:,:,1,1));
% Create filename according the existing nomenclature at scan level
PAT.res.file_anat = fullfile(PAT.output_dir, 'anatomical.nii');
% Create and write a NIFTI file in the scan folder
pat_create_vol(PAT.res.file_anat, vol(1).dim, vol(1).dt,...
    vol(1).pinfo, vol(1).mat, 1, im_anat);
end
% EOF
