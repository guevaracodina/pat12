function [generate_figures save_figures] = pat_generate_figures_cfg
% Configuration file with options to show/print figures in the current batch job
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
generate_figures        = cfg_menu;
generate_figures.tag    = 'generate_figures';
generate_figures.name   = 'Show figures';
generate_figures.labels = {'Yes','No'};
generate_figures.values = {true, false};
generate_figures.val    = {false};
generate_figures.help   = {'Show figures. When selecting this option, the figures will stay opened after the code has completed.'}';

save_figures            = cfg_menu;
save_figures.tag        = 'save_figures';
save_figures.name       = 'Save figures';
save_figures.labels     = {'Yes','No'};
save_figures.values     = {true, false};
save_figures.val        = {false};
save_figures.help       = {'Save figures.'}';

% EOF
