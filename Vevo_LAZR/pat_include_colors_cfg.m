function IC             = pat_include_colors_cfg(HbT, SO2, varargin)
% Graphical interface configuration function to include colors in current batch.
% This code is part of a batch job configuration system for MATLAB. See help
% matlabbatch for a general overview.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% Optional inputs handling
% ------------------------------------------------------------------------------
% only want true optional input at most
numvarargs              = length(varargin);
if numvarargs > 1
    error('pat_include_colors_cfg:TooManyInputs', ...
        'Requires at most one optional input');
end
% set defaults for optional inputs
optargs                 = {false};
% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs)   = varargin;
% Place optional args in memorable variable names
[Bmode]                 = optargs{:};
% ------------------------------------------------------------------------------

include_HbT             = cfg_menu;
include_HbT.tag         = 'include_HbT';
include_HbT.name        = 'Include HbT';
include_HbT.labels      = {'Yes','No'};
include_HbT.values      = {true,false};
include_HbT.val         = {HbT};
include_HbT.help        = {'Include HbT.'}';

include_SO2             = cfg_menu;
include_SO2.tag         = 'include_SO2';
include_SO2.name        = 'Include SO2';
include_SO2.labels      = {'Yes','No'};
include_SO2.values      = {true,false};
include_SO2.val         = {SO2};
include_SO2.help        = {'Include SO2.'}';

include_Bmode           = cfg_menu;
include_Bmode.tag       = 'include_Bmode';
include_Bmode.name      = 'Include Bmode';
include_Bmode.labels    = {'Yes','No'};
include_Bmode.values    = {true,false};
include_Bmode.val       = {Bmode};
include_Bmode.help      = {'Include Bmode.'}';

IC                      = cfg_branch;
IC.name                 = 'Include colors';
IC.tag                  = 'IC';
IC.val                  = {include_HbT include_SO2 include_Bmode}; 
IC.help                 = {'Choose colors to include.'};

% EOF
