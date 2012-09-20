% VsiPwDopplerIQdataExample.m
% A script to open IQ files from Pw-Mode data 
% Authors: A. Needles, J. Mehi, G. Sundar 
% Copyright VisualSonics 1999-2011
% Revision: 1.1 June 28 2010
% Revision: 1.2 Feb. 8 2011

% specify filename here ------------------
fnameBase= 'PWDOPPLER_IQ.iq';
gain = -0.82;
 % ------------------------------------------
[Idata,Qdata,param,numFrames] = VsiPwIQ(fnameBase, '.pw');
fname = [fnameBase '.pw'];
Nsamples = param.PwNsamples; 
TxPrf = param.PwTxPrf;
SpectralSize = param.PwSpectralSize;
SpectralSpacing = param.PwSpectralSpacing;
fs = param.PwRxFrequency; 
% ------------------------------------------

j= sqrt(-1); 

s=zeros(1,Nsamples);
totalSamples = numFrames*Nsamples;
NP=SpectralSize;     % No. of points for FFT
OL=SpectralSpacing;      % No. points for overlapped windows
W=hamming(NP);     % FFT window
delta_f=TxPrf/(NP-1);       % Frequency step [kHz]
f=(-TxPrf/2:delta_f:TxPrf/2);       % Frequency axis [kHz]

ds=Idata+j.*Qdata;    % Complex Doppler signal
stepSize = OL;
k=1;
i=1;    

while (i+NP-1) < totalSamples;
    dss = ds(i:i+NP-1).*W';
    DS = abs(fft(dss));
    DS = fftshift(DS);   
    DS = log10(DS);
    maxDS = max(DS);
    DS = DS/maxDS;    
    TS(:,k)=DS';
    k=k+1;
    i = i+stepSize;  
end
[Row,Col]=size(TS);

figure(1)
subplot(2,1,1), plot(Idata), title('In-phase Component'), grid on
subplot(2,1,2), plot(Qdata), title('Quadrature Component'), grid on
figure(2)
imagesc([1:Col],f,TS), colormap(gray), brighten(gain), colorbar
set(gca,'Ydir','normal')
title('PW Doppler Spectrum reconstructed in Matlab (dB)'), 
xlabel('Time Index'), ylabel('-Freq. (kHz)')