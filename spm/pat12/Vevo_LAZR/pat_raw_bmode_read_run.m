function out = pat_raw_bmode_read_run(job)
% Batch function to import .raw.bmode files into NIfTI files.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
fprintf('Work in progress...\nEGC\n')
out.PATmat = job.PATmat;
return
% ------------------------------------------------------------------------------
% Add Vevo LAZR related functions
addpath(['.',filesep,'Vevo_LAZR/'])
try
    for scanIdx = 1:length(job.PATmat)
        tic
        % Load PAT.mat information
        [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
%         % Set save structure and associated directory
%         clear PAT
%         PAT.input_dir = job.input_dir{scanIdx};
%         % Current input dir
%         filesdir = job.input_dir{scanIdx};
        % Extract only raw.bmode files
        files = dir(fullfile(PAT.input_dir,'*.raw.bmode'));
%         dirlen = size(job.input_data_topdir{1},2);
%         [pathstr, ~] = fileparts(filesdir);
%         % Current output dir
%         PAT.output_dir = fullfile(job.output_dir{1},pathstr(dirlen+1:end));
%         if ~exist(PAT.output_dir,'dir'),mkdir(PAT.output_dir); end
%         % current PAT structure
%         PATmat = fullfile(PAT.output_dir,'PAT.mat');
        % Preallocate cell with filenames
        PAT.bmode_nifti_files = cell(length(files),2);
        PAT.bmode_nifti_files_affine_matrix = cell(length(files),2);
        % Directory with .BMP images
        bmp_dir = fullfile(dir_patmat,'Bmode_images');
        if ~exist(bmp_dir,'dir'),mkdir(bmp_dir); end
        for fileIdx = 1:length(files)
            
%             [bmode_nifti_filename affine_mat_filename PAT.PAparam] = pat_raw2nifti_bmode(...
%                 fullfile(filesdir,files(fileIdx).name), PAT.output_dir);
%             PAT.bmode_nifti_files{fileIdx,1} = bmode_nifti_filename{1};
%             PAT.bmode_nifti_files{fileIdx,2} = bmode_nifti_filename{2};
%             PAT.bmode_nifti_files_affine_matrix{fileIdx,1} = affine_mat_filename{1};
%             PAT.bmode_nifti_files_affine_matrix{fileIdx,2} =
%             affine_mat_filename{2};
        end % files loop
        % raw.pamode extraction done!
        PAT.jobsdone.extract_rawBmode = true;
        save(PATmat,'PAT');
        out.PATmat{scanIdx} = PATmat;
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        fprintf('Subject %d of %d complete\n', scanIdx, length(job.input_dir));
    end % scans loop
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    out.PATmat{scanIdx} = PATmat;
end
end

% EOF
