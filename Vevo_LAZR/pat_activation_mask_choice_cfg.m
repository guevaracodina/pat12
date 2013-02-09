function activMask_choice = pat_activation_mask_choice_cfg(include_th_side)
% Configuration file to choose whether to mask by an activation mask
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
no_mask                 = cfg_branch;
no_mask.tag             = 'no_mask';
no_mask.name            = 'No activation mask';
no_mask.val             = {};
no_mask.help            = {'No activation mask'};

mask_image              = cfg_files;
mask_image.name         = 'Activation mask';
mask_image.tag          = 'mask_image';
mask_image.filter       = 'any';
mask_image.ufilter      = '.*';
mask_image.val{1}       = {''};
mask_image.num          = [0 Inf];
mask_image.help         = {'Select a .fig image of an activation.'}';

threshold               = cfg_entry;
threshold.name          = 'Threshold';
threshold.tag           = 'threshold';
threshold.strtype       = 'r';
threshold.val{1}        = 2;
threshold.num           = [1 1];
threshold.help          = {'Threshold to apply on activation image. If negative, and'
    'option to include both activations and deactivations is set to No,'
    'then pixels with values less than this negative threshold will be kept.'};

two_sided               = cfg_menu;
two_sided.tag           = 'two_sided';
two_sided.name          = 'Include both activations (above threshold) and deactivations (below negative threshold)';
two_sided.labels        = {'Yes','No'};
two_sided.values        = {true, false};
two_sided.val           = {true};
two_sided.help          = {'Include both activations (above threshold) and deactivations (below negative threshold)'};

activMask               = cfg_branch;
activMask.tag           = 'activMask';
activMask.name          = 'Use activation mask';
if include_th_side
    activMask.val       = {mask_image, threshold two_sided};
else
    activMask.val       = {mask_image};
end
activMask.help          = {'Use activation mask'};

activMask_choice        = cfg_choice;
activMask_choice.name   = 'Choose whether to mask by an activation mask';
activMask_choice.tag    = 'activMask_choice';
activMask_choice.values = {no_mask, activMask};
activMask_choice.val    = {no_mask};
activMask_choice.help   = {'Choose whether to mask by an activation mask'}';

% EOF
