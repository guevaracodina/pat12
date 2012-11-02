function z = fisherz(r)
% This function performs a Fisher's z-transform of Pearson's correlation
% coefficient r . This function is used to map the correlations distribution in
% [-1;+1] into a near gaussian population. The correlation coefficient need to
% be transformed to the normal distribution by Fisher's z transform before
% performing the random effect t-tests. The inverse operation is done by
% function inv_fisherz.m
% SYNTAX
% z = fisherz(r)
% INPUTS
% r     Pearson's correlation coefficient r
% OUTPUTS
% z     The Fisher's z-transfom of r
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
z = 0.5*log( (1+r)./(1-r) );
