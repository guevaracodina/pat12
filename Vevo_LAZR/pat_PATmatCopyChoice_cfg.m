function PATmatCopyChoice = pat_PATmatCopyChoice_cfg(dir_name)
% Configuration file for GUI to choose creation/overwrite of PAT structure
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________
PATmatOverwrite         = cfg_branch;
PATmatOverwrite.tag     = 'PATmatOverwrite';
PATmatOverwrite.name    = 'Overwrite PAT.mat structure'; 
PATmatOverwrite.help    = {'Will not copy PAT structure.'
            'This will write over the previous PAT.mat'}';

NewPATdir               = cfg_entry;
NewPATdir.name          = 'New directory for PAT.mat';
NewPATdir.tag           = 'NewPATdir';       
NewPATdir.strtype       = 's';
NewPATdir.val{1}        = dir_name; 
NewPATdir.num           = [1 Inf];     
NewPATdir.help          = {'Directory for PAT.mat.'}'; 

PATmatCopy              = cfg_branch;
PATmatCopy.tag          = 'PATmatCopy';
PATmatCopy.name         = 'Create new directory and copy PAT structure there'; 
PATmatCopy.val          = {NewPATdir};
PATmatCopy.help         = {'Create new directory and copy PAT structure there.'}';
        
%Common to most modules: for creating a new directory and copying PAT.mat
PATmatCopyChoice        = cfg_choice;
PATmatCopyChoice.name   = 'Choose PAT copy method';
PATmatCopyChoice.tag    = 'PATmatCopyChoice';
PATmatCopyChoice.values = {PATmatOverwrite PATmatCopy}; 
PATmatCopyChoice.val    = {PATmatOverwrite}; 
PATmatCopyChoice.help   = {'Choose whether to overwrite the PAT.mat structure'
            'or to create a new directory'
            'and copy the PAT.mat structure there'}'; 
        
% EOF
        
