function [X, freq] = pat_positiveFFT(x, Fs)
% this is a custom function that helps in plotting positive spectrum
% SYNTAX
% [X, freq]             = pat_positiveFFT(x, Fs)
% INPUTS
% x                     is the signal that is to be transformed
% Fs                    is the sampling rate
% OUTPUTS
% X                     is the transformed signal
% freq                  is the frequency vector
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

N       = length(x);    % get the number of points
k       = 0:N-1;        % create a vector from 0 to N-1
T       = N/Fs;         % get the frequency interval
freq    = k/T;          % create the frequency range
X       = fft(x)/N;     % normalize the data

%only want the first half of the FFT, since it is redundant
cutOff  = ceil(N/2);

%take only the first half of the spectrum
X       = X(1:cutOff);
freq    = freq(1:cutOff);

% EOF
