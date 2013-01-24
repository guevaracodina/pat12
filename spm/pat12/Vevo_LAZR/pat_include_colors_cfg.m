function IC             = pat_include_colors_cfg(OD,HbO,HbR,HbT,Flow,varargin)
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
% only want 1 optional input at most
numvarargs              = length(varargin);
if numvarargs > 1
    error('pat_include_colors_cfg:TooManyInputs', ...
        'Requires at most 1 optional inputs');
end
% set defaults for optional inputs
optargs                 = {0};
% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs)   = varargin;
% Place optional args in memorable variable names
[CMRO2]                 = optargs{:};
% ------------------------------------------------------------------------------

include_flow            = cfg_menu;
include_flow.tag        = 'include_flow';
include_flow.name       = 'Include flow';
include_flow.labels     = {'Yes','No'};
include_flow.values     = {1,0};
include_flow.val        = {Flow};
include_flow.help       = {'Include flow.'}';

include_HbT             = cfg_menu;
include_HbT.tag         = 'include_HbT';
include_HbT.name        = 'Include HbT';
include_HbT.labels      = {'Yes','No'};
include_HbT.values      = {1,0};
include_HbT.val         = {HbT};
include_HbT.help        = {'Include HbT.'}';

include_OD              = cfg_menu;
include_OD.tag          = 'include_OD';
include_OD.name         = 'Include optical intensity';
include_OD.labels       = {'Yes','No'};
include_OD.values       = {1,0};
include_OD.val          = {OD};
include_OD.help         = {'If the optical intensity images (Green, Red, Yellow) have not been deleted'
    'previously, choose whether to generate movies for these colors.'}';

include_HbO             = cfg_menu;
include_HbO.tag         = 'include_HbO';
include_HbO.name        = 'Include HbO';
include_HbO.labels      = {'Yes','No'};
include_HbO.values      = {1,0};
include_HbO.val         = {HbO};
include_HbO.help        = {'Include HbO.'}';

include_HbR             = cfg_menu;
include_HbR.tag         = 'include_HbR';
include_HbR.name        = 'Include HbR';
include_HbR.labels      = {'Yes','No'};
include_HbR.values      = {1,0};
include_HbR.val         = {HbR};
include_HbR.help        = {'Include HbR.'}';

include_CMRO2           = cfg_menu;
include_CMRO2.tag       = 'include_CMRO2';
include_CMRO2.name      = 'Include CMRO2';
include_CMRO2.labels    = {'Yes','No'};
include_CMRO2.values    = {1,0};
include_CMRO2.val       = {CMRO2};
include_CMRO2.help      = {'Include CMRO2.'}';

IC                      = cfg_branch;
IC.name                 = 'Include colors';
IC.tag                  = 'IC';
IC.val                  = {include_OD include_HbO include_HbR include_HbT...
                        include_flow include_CMRO2}; 
IC.help                 = {'Choose colors to include.'};

% EOF
