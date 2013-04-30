function r = pat_fisherz_inv(z)
% This function performs the inverse of a fisher Z-transform of vector Z
% and ouput a transformed vector R in the limit [-1;+1].
% see fisherz.m for the r to z transform
% SYNTAX
% r = inv_fisherz(z)
% INPUTS
% z     The Fisher's z-transfom of r
% OUTPUTS
% r     Pearson's correlation coefficient r
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
r = (exp(2*z)-1) ./ (exp(2*z)+1);

% EOF

