function cfg = cfg_pat_processing
% Master file that collects all PAT processing
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2011 Laboratoire d'Imagerie Optique et Moleculaire

% F Lesage
% $Id$

rev = '$Rev$'; %#ok

% Sets up the different modules, each module will have its own menu in the
% batch interface so that they will be organized logically

%% Modules to perform pre-processing of oct data
preproc        = cfg_repeat; % A repeat collects a variable number of items from its .values field in its .val field
preproc.name   = 'Preprocessing';
preproc.tag    = 'preproc';
preproc.values = {pat_extract_tiff_cfg}; % Config files for all preprocessing modules
preproc.forcestruct = true; % There is a speciality in cfg_repeat harvest behaviour that makes a difference depending on the number of elements in values. forcestruct == true forces the repeat to behave as if there are more than one distinct values, even if there is only one.
preproc.help   = {'All functions used for data preprocessing are collected in this module'};

%% Modules to perform pre-processing of oct data
proc        = cfg_repeat; % A repeat collects a variable number of items from its .values field in its .val field
proc.name   = 'Processing';
proc.tag    = 'proc';
proc.values = {pat_pca_cfg pat_choose_pc_cfg pat_ica_cfg pat_reg_cfg pat_simu_montecarlo_cfg pat_kwave_cfg pat_GLM_on_ROI_cfg}; % Config files for all preprocessing modules
proc.forcestruct = true; % There is a speciality in cfg_repeat harvest behaviour that makes a difference depending on the number of elements in values. forcestruct == true forces the repeat to behave as if there are more than one distinct values, even if there is only one.
proc.help   = {'All functions used for data per-se processing are collected in this module'};

postproc        = cfg_repeat; % A repeat collects a variable number of items from its .values field in its .val field
postproc.name   = 'Post-Processing';
postproc.tag    = 'postproc';
postproc.values = {pat_ica_figures_cfg}; % Config files for all preprocessing modules
postproc.forcestruct = true; % There is a speciality in cfg_repeat harvest behaviour that makes a difference depending on the number of elements in values. forcestruct == true forces the repeat to behave as if there are more than one distinct values, even if there is only one.
postproc.help   = {'All functions used to generate images and results'};


%% Collect above Collections
cfg        = cfg_repeat;
cfg.name   = 'PAT';
cfg.tag    = 'cfg_pat';
cfg.values = {preproc proc postproc}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {'Full photoacoustic processing pipeline'};