function PATmat = pat_PATmat_cfg(varargin)
% Configuration file GUI to select PAT matrix
% SYNTAX
% PATmat = pat_PATmat_cfg(minPAT, helpText)
% INPUTS
% [minPAT]      Minimum number of PAT matrices
% [helpText]    Text to display as help
% OUTPUT
% PATmat        cfg_files object for use in Matlab batch structure
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% Optional inputs handling
% ------------------------------------------------------------------------------
% only want true optional input at most
numvarargs              = length(varargin);
if numvarargs > 2
    error('pat_PATmat_cfg:TooManyInputs', ...
        'Requires at most two optional inputs');
end
% set defaults for optional inputs
optargs                 = {1 'Select PATmat dependency if available. Otherwise, for each subject, select PAT.mat.'};
% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs)   = varargin;
% Place optional args in memorable variable names
[minPAT helpText]       = optargs{:};
% ------------------------------------------------------------------------------

PATmat                  = cfg_files;        % Select PAT.mat for this subject 
PATmat.name             = 'Select PAT.mat'; % The displayed name
PATmat.tag              = 'PATmat';         % file names
PATmat.filter           = 'mat';
PATmat.ufilter          = '^PAT.mat$';    
PATmat.num              = [minPAT Inf];     % Number of inputs required 
PATmat.help             = {helpText}';      % help text displayed

% EOF
