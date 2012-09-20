% VsiColorFlowIQdataExample.m
% A script to open IQ files from CFI data 
% Authors: A. Needles, J. Mehi  
% Copyright VisualSonics 1999-2010
% Revision: 1.0 June 28 2010

% specify filename here ------------------
 fnameBase= 'MS400 color flow string phantom IQ.iq';
% ------------------------------------------
% specify frame number
frameNum= 1;
% specify whether to read B-Mode data frame interleaved with color flow data
readBmodeData= 'y';
% ------------------------------------------
% read parameter file and color flow IQ data
[Idata,Qdata,param] = VsiCfiIQ(fnameBase, '.color', frameNum);
% ------------------------------------------
ColorNumSamples = param.ColorNumSamples; 
ColorNumLines = param.ColorNumLines; 
ColorDepthOffset = param.ColorDepthOffset; 
ColorNumEnsemble = param.ColorNumEnsemble;
ColorEnsembleExtra = param.ColorEnsembleExtra; 
ColorLinesExtra = param.ColorLinesExtra; 
ColorSteeringAngle = param.ColorSteeringAngle; 
ColorTxFrequency = param.ColorTxFrequency;
% ------------------------------------------
j= sqrt(-1);
NLines= ColorNumLines+ColorLinesExtra; 
Ne= ColorNumEnsemble+ColorEnsembleExtra;  
IQcmplx= Idata+j*Qdata;
R1= zeros(ColorNumSamples,NLines);
R0= zeros(ColorNumSamples,NLines);
b= [1 -1]; % simple first difference filter

% re-order the IQ data and calculate R0 and R1
for n=1:NLines
    s= IQcmplx(:,(n-1)*Ne+(1:Ne));
    s= s.';  
    % filter the IQ data
    s= filter(b,1,s); 
    % zeroeth lag of autocorrelation
    R0(:,n)= sum(s.*conj(s))'; 
    % first lag of autocorrelation
    R1(:,n)= sum([zeros(1,ColorNumSamples);s].*conj([s;zeros(1,ColorNumSamples)]))'; %
end

% process color flow IQ data 
magR0dB= 10*log10(R0);
vel= angle(R1);
vel(find(vel<0))= vel(find(vel<0))+2*pi;  
vel= round(64*vel/2/pi); 
vel(find(vel==64))= 0; 
% remove velocity and power samples which are noisy 
powerThreshold=  90;
powerThresholdMask= find(magR0dB<powerThreshold);
vel(powerThresholdMask)=0;
magR0dB(powerThresholdMask)=0;
figure;   imagesc(vel); title('velocity');
figure;   imagesc(magR0dB); title('power');

if strcmp(readBmodeData,'y')
% ------------------------------------------
% read parameter file, and the B-Mode IQ data which was acquired 
% on a frame interleaved basis with the color flow data
[IdataBmode,QdataBmode,param] = VsiCfiIQ(fnameBase, '.bmode', frameNum);
% ------------------------------------------
BmodeNumSamples = param.BmodeNumSamples; 
BmodeNumLines = param.BmodeNumLines; 
BmodeDepthOffset = param.BmodeDepthOffset; 
BmodeDepth = param.BmodeDepth; 
BmodeWidth = param.BmodeWidth; 
% ------------------------------------------
figure;   imagesc(10*log10(IdataBmode.^2 + QdataBmode.^2)); title('B-Mode');
colormap('gray');
end








