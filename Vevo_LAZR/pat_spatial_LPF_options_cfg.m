function spatial_LPF = pat_spatial_LPF_options_cfg
% Configuration parameters of the gaussian kernel.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

spatial_LPF_radius          = cfg_entry;
spatial_LPF_radius.name     = 'Spatial LPF radius';
spatial_LPF_radius.tag      = 'spatial_LPF_radius';
spatial_LPF_radius.strtype  = 'r';
spatial_LPF_radius.num      = [1 1];
spatial_LPF_radius.val      = {10};
spatial_LPF_radius.help     = {'Enter radius of spatial low pass filter in pixels.'
    'In practice, a radius of 1 gives a weight of 0.4 to the central pixel, of 0.1 to the 4 nearest'
    'and the remainder to the next 8 pixels.'}';

spatial_LPF_On              = cfg_branch;
spatial_LPF_On.tag          = 'spatial_LPF_On';
spatial_LPF_On.name         = 'Spatial Low-Pass filter on';
spatial_LPF_On.val          = {spatial_LPF_radius};
spatial_LPF_On.help         = {'Spatial Low-Pass filter On.'};

spatial_LPF_Off             = cfg_branch;
spatial_LPF_Off.tag         = 'spatial_LPF_Off';
spatial_LPF_Off.name        = 'Spatial Low-Pass filter off';
spatial_LPF_Off.val         = {};
spatial_LPF_Off.help        = {'Spatial low pass filter turned off.'};

spatial_LPF                 = cfg_choice;
spatial_LPF.tag             = 'spatial_LPF';
spatial_LPF.name            = 'Spatial Low-Pass Filter';
spatial_LPF.values          = {spatial_LPF_On spatial_LPF_Off};
spatial_LPF.val             = {spatial_LPF_Off};
spatial_LPF.help            = {'Choose whether to include a spatial Low Pass Filter on the data prior to running the fcPAT utilities.'}';

% EOF
