function pat_save_figs(job, h, varargin)
% Saves figures as PNG and FIG files.
% SYNTAX
% pat_save_figs(job, h, figSuffix, scanIdx, c1, r1, figsFolder)
% INPUTS
% job           Matlab batch job structure
% h             Figure handle
% figSuffix     String with the suffix to append to each file
% scanIdx       Integer with scan index
% c1            Integer with color index
% r1            Integer with ROI/seed index
% figsFolder    String with folder name where the figures will be saved
% OUTPUT
% none
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 5
    error('pat_save_figs:TooManyInputs', ...
        'requires at most 5 optional inputs: figSuffix, scanIdx, c1, r1, figsFolder');
end

% set defaults for optional inputs ()
optArgs = {'plot', 1, 1, 1, 'figsFolder'};

% now put these defaults into the optArgs cell array,
% and overwrite the ones specified in varargin.
optArgs(1:numVarArgs) = varargin;
% or ...
% [optargs{1:numvarargs}] = varargin{:};

% Place optional args in memorable variable names
[figSuffix, scanIdx, c1, r1, figsFolder] = optArgs{:};

try
    if job.save_figures
        % ---------------------- Saving plots --------------------------
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        colorNames = fieldnames(PAT.color);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        newName = [sprintf('%s_C%d(%s)_R%02d',scanName,c1,colorNames{c1+1},r1) '_fig_' figSuffix];
        if isfield(job.PATmatCopyChoice,'PATmatCopy')
            dir_filtfig = fullfile(dir_patmat,strcat('fig_',job.PATmatCopyChoice.PATmatCopy.NewPATdir));
        else
            dir_filtfig = fullfile(dir_patmat, figsFolder);
        end
        if ~exist(dir_filtfig,'dir'), mkdir(dir_filtfig); end
        % Save as PNG
        print(h, '-dpng', fullfile(dir_filtfig,newName), sprintf('-r%d',job.figRes));
        % Save as a figure
        saveas(h, fullfile(dir_filtfig,newName), 'fig');
        % Return the property to its default
        set(h, 'units', 'pixels')
        close(h)
        % ------------------------------------------------------------------
    end % Save figures
end

% EOF
