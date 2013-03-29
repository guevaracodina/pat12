function out = pat_isVEVOraw(job)
% Tells if job (or input dir) contains *.raw.pamode/*.raw.bmode VEVO LAZR files
% SYNTAX
% out       = pat_isVEVOraw(job)
% INPUT
% job       Matlab batch job, could also be a directory
% OUTPUT
% out       True if folder/PAT structure contains *.raw.pamode VEVO files
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

try
    if isstruct(job)
        if isfield(job,'input_dir')
            % Check only first directory
            filesDir = job.input_dir{1};
            filesList = dir(fullfile(filesDir,'*.raw.*mode'));
            if ~isempty(filesList)
                out = true;
                return
            else
                out = false;
            end
        elseif isfield(job,'PATmat')
            % Load first PAT.mat information
            [PAT, ~, ~] = pat_get_PATmat(job,1);
            % Check PAT structure to see if it has references to *.raw.pamode
            if isfield(PAT,'input_dir')
                filesDir = PAT.input_dir;
                filesList = dir(fullfile(filesDir,'*.raw.*mode'));
                if ~isempty(filesList)
                    out = true;
                    return
                else
                    out = false;
                end
            end % PAT.input_dir
        else
            out = false;
        end % input_dir
    elseif isdir(job)
        % Check raw files in directory used as input argument
        filesList = dir(fullfile(job,'*.raw.*mode'));
        if ~isempty(filesList)
            out = true;
            return
        else
            out = false;
        end
    else
        out = false;
    end % is job structure?
catch exception
    out = false;
    disp(exception.identifier)
    disp(exception.stack(1))
end % try
end % pat_isVEVOraw

% EOF
