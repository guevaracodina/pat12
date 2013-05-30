function bpf        = pat_bpf_cfg(choose_on, freq, order, type, varargin)
% Configuration unit for band-pass filter in Matlab batch gui.
% SYNTAX
% bpf               = pat_bpf_cfg(choose_on, freq, order, type, [Rp Rs])
% INPUTS
% choose_on         Determines if filter is enabled (1) or not (0)
% freq              2-element vector with the cut-off frequencies
% order             integer defining the order of the filter
% type              @butter, @cheby1, @cheby2, @ellip
% [Rp Rs]           OPTIONAL: 2-element vector with Rp dB of ripple in the passband,
%                   and a stopband Rs dB down from the peak value in the passband.
% OUTPUT
% bpf               Executable branch passed to graphical interface
%                   configuration function
%_______________________________________________________________________________
% Copyright (C) 2010 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% only want 1 optional input at most
numVarArgs = length(varargin);
if numVarArgs > 1
    error('pat12:pat_bpf_cfg:TooManyInputs', ...
        'requires at most 1 optional input: [Rp Rs]');
end

% set defaults for optional inputs ()
optArgs = {[.5 80]};

% now put these defaults into the optArgs cell array,
% and overwrite the ones specified in varargin.
optArgs(1:numVarArgs) = varargin;
% or ...
% [optargs{1:numvarargs}] = varargin{:};

% Place optional args in memorable variable names
[Rp_Rs] = optArgs{:};
Rp = Rp_Rs(1); Rs = Rp_Rs(2); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Band-pass frequencies
bpf_freq            = cfg_entry; 
bpf_freq.tag        = 'bpf_freq';       
bpf_freq.name       = 'Cutoff frequencies for BPF';
bpf_freq.strtype    = 'r';
bpf_freq.num        = [1 2];     
bpf_freq.val        = {freq};
bpf_freq.help       = {'Enter band-pass frequencies in Hz for bandpass filter.'};

% Filter order
bpf_order           = cfg_entry; 
bpf_order.tag       = 'bpf_order';       
bpf_order.name      = 'Order of BPF';
bpf_order.strtype   = 'r';
bpf_order.num       = [1 1];     
bpf_order.val       = {order};
bpf_order.help      = {'Enter order of bandpass filter (preferred value = 4).'};

% Filter implementation
bpf_type            = cfg_menu;
bpf_type.tag        = 'bpf_type';
bpf_type.name       = 'Type of band-pass filter';
bpf_type.labels     = {'Butterworth', 'Chebyshev I', 'Chebyshev II', 'Elliptic'};
bpf_type.values     = {'butter', 'cheby1', 'cheby2', 'ellip'};
bpf_type.val        = {type};
bpf_type.help       = {'Type of filter design'};

% Chebyshev I filter
% R = 0.5 dB of peak-to-peak ripple in the passband
bpf_Rp              = cfg_entry;
bpf_Rp.tag          = 'bpf_Rp';
bpf_Rp.name         = 'Passband Ripple';
bpf_Rp.strtype      = 'r';
bpf_Rp.num          = [1 1];
bpf_Rp.val          = {Rp};
bpf_Rp.help         = {'Elliptic / Chebyshev I filter: R = 0.5 dB of peak-to-peak ripple in the passband'};

% Chebyshev II filter option
% stopband ripple R = 80 dB down from the peak passband value
bpf_Rs              = cfg_entry;
bpf_Rs.tag          = 'bpf_Rs';
bpf_Rs.name         = 'Stopband ripple';
bpf_Rs.strtype      = 'r';
bpf_Rs.num          = [1 1];
bpf_Rs.val          = {Rs};
bpf_Rs.help         = {'Elliptic / Chebyshev II filter: stopband ripple R = 80 dB down from the peak passband value'};

% Rp dB of ripple in the passband, and a stopband Rs dB down from the peak value
% in the passband
bpf_R               = cfg_entry;
bpf_R.tag           = 'bpf_R';
bpf_R.name          = 'Pass/Stop Ripple';
bpf_R.strtype       = 'r';
bpf_R.num           = [1 2];
bpf_R.val           = {[Rp Rs]};
bpf_R.help          = {'Valid only for Elliptic filter, [Rp Rs] = [0.1 80] dB are respectively passband and stopband ripples.'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bpf_On              = cfg_branch;
bpf_On.tag          = 'bpf_On';
bpf_On.name         = 'Enable BP filter';
bpf_On.val          = {bpf_freq, bpf_order, bpf_type, bpf_Rp, bpf_Rs}; 
bpf_On.help         = {'Band-pass filter.'};

bpf_Off             = cfg_branch;
bpf_Off.tag         = 'bpf_Off';
bpf_Off.name        = 'BP filter off';
bpf_Off.val         = {}; 
bpf_Off.help        = {'Band-pass filter turned off.'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bpf                 = cfg_choice;
bpf.tag             = 'bpf';
bpf.name            = 'Band Pass Filter';
bpf.values          = {bpf_On bpf_Off};
if choose_on
    bpf.val         = {bpf_On};
else
    bpf.val         = {bpf_Off};
end
bpf.help            = {'Choose whether to include a Band-Pass Filter. Parameters are: order (e.g. 4) and frequency (e.g. [0.009 0.08] Hz)'}';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% EOF
