function redo1 = pat_redo_cfg(deflt)
% Configuration file for GUI to choose forced processing.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________
redo1           = cfg_menu;
redo1.tag       = 'force_redo';
redo1.name      = 'Force processing';
redo1.labels    = {'No','Yes'};
redo1.values    = {false,true};
redo1.val       = {deflt};
redo1.help      = {'Force redoing this processing even when it has been done already.'
    'Use option below for treatment of previous ROIs.'}';
% EOF
