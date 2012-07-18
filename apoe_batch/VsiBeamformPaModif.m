function [handles, BfData] = VsiBeamformPaModif(handles,fnameBase, StartFrame, EndFrame)

% VsiBeamformPa.m
% Copyright VisualSonics 1999-2010
% A. Needles
% Revision 1.0: Dec. 7, 2010.
% A script to open unbeamformed IQ data on the Vevo 2100 and reconstruct and
% display a PA image

% close all
% clear all

% Set up file name
% fnameBase = 'LZ250 pa mode full width IQ.iq';
% fnameBase = '2012-07-04-13-53-49_post_nanostepper_1-2012-06-05-10-11-24_1.iq';

fname = [fnameBase '.pamode'];
fnameXml = [fnameBase '.xml'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Beamforming Settings - these paramters need to be set manually
Beamform= 1; % This can be turned off (set = 0) if you just want to open a file and look at the data without beamforming

% This determines how many quadrants are used for full-width
ApertureStart = 0; % zero-based
ApertureEnd = 255; % zero-based

% This determines how many quadrants are used for half-width (uncomment)
%ApertureStart = 64; % zero-based
%ApertureEnd = 191; % zero-based

% Size of aperture to use for beamforming
NoElem=64;

% Set the region of the dataset to beamform (for speed)
StartLine = 0.0; % as a fractional percentage of total
EndLine = 1.0;  % as a fractional percentage of total
StartSample = 0.01; % as a fractional percentage of total
EndSample = 1.0; % as a fractional percentage of total
% StartSample = 0; % as a fractional percentage of total
% EndSample = 0.99; % as a fractional percentage of total

%contants
ct = 1540; %m/s
cl = 2340; %m/s

% MS250/LZ250 settings
a = 0.25e-3; %m - lens thickness
pitch = 90e-6; %m


% Display Options, 0 = OFF, 1 = ON
ShowIQ = 0;
ShowReorderedIQ = 0;
ShowBeamformedIQ = 1;
DR = -60; % Dynamic Range in dB 
%%%%%%%%%%%%%%%%%%%%%%%%%%

% These parameters need to be set manually for opening the file
% StartFrame = 1; 
% EndFrame = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXmlModif(fnameXml, '.pamode');
samples = param.PaNumSamples;
lines = param.PaNumLines;
DepthOffset = param.PaDepthOffset; %mm
Depth =  param.PaDepth; %mm
Width = pitch*lines*1e3; %mm
fs = param.BmodeRxFrequency; %Hz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Paramters not yet in the xml file but should be added - DO NOT CHANGE
NumPulses = 1; 
Quad2x = 'true';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is to strip the header data in the files - DO NOT CHANGE
size = 2; % bytes
file_header = 40; % bytes
line_header = 4; % bytes
frame_header = 56; % bytes  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup the Rx frequency
f_rf = fs; % reconstruct to the original Rx freq in the param file
if Quad2x(1) == 't'
    fs = fs*2; % actual Rx freq is double because of Quad 2x
    IntFac = 16;
else
    IntFac = 16;
end
fs_int = fs*IntFac;
FineDelayInc = 1/IntFac;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup the Rx axes
DepthAxis = [DepthOffset:(Depth-DepthOffset)/(samples-1):Depth];
WidthAxis = [0:Width/((lines/NumPulses)-1):Width];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup the time and frequency vectors
t = [0:1/fs_int:((samples*IntFac)-1)/fs_int];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    
% This is all for opening and analyzing the file
for iframe = StartFrame:EndFrame
    fid = fopen(fname,'r');
         
    % Initialize data
    Idata = zeros(samples, lines*NumPulses);
    Qdata = zeros(samples, lines*NumPulses);
    Idata_int = zeros(samples*IntFac, lines*NumPulses);
    Qdata_int = zeros(samples*IntFac, lines*NumPulses);
    Idata_en = zeros(samples*IntFac, lines, NumPulses);
    Qdata_en = zeros(samples*IntFac, lines, NumPulses);
    RfData = zeros(samples*IntFac, lines, NumPulses);
    
    header = file_header + frame_header*iframe + (size*samples*lines*2 + lines*line_header)*(iframe-1);
    for i=1:lines*NumPulses
        fseek(fid, header + (size*samples*2 + line_header)*(i-1),-1);
        fseek(fid, line_header, 'cof');
        [Qdata(:,i),count]=fread(fid, samples, 'int16', size);
        fseek(fid, header + (size*samples*2 + line_header)*(i-1) + size,-1);
        fseek(fid, line_header, 'cof');
        [Idata(:,i),count]=fread(fid, samples, 'int16', size);
    end
    fclose(fid);
    
    %interpolate the data
    for i=1:lines*NumPulses
        Idata_int(:, i) = interp(Idata(:,i), IntFac);
        Qdata_int(:, i) = interp(Qdata(:,i), IntFac);
	end
    
    % Multiply by a complex exponential to reconstruct RF
    CompExp = transpose(exp(sqrt(-1)*2*pi*f_rf*t));
    
    % Parse the data into ensembles and generate RF
    for i=1:NumPulses:lines*NumPulses
        for j=1:NumPulses
            Idata_en(:, floor(i/NumPulses), j) = Idata_int(:,i-1+j);
            Qdata_en(:, floor(i/NumPulses), j) = Qdata_int(:,i-1+j);
            
            RfData(:, floor(i/NumPulses), j) = complex(Qdata_en(:, floor(i/NumPulses), j), Idata_en(:, floor(i/NumPulses), j)).*CompExp;
        end
	end
end

% Display unordered IQ data by channel
if ShowIQ == 1
    figure
    
    ChAxis=zeros(1,length(Idata(1,:)));
	for k=ApertureStart:ApertureStart+length(Idata(1,:))-1
        ChAxis(k-ApertureStart+1) = k;
	end
    
    MaxVal = max(max((Idata.^2 + Qdata.^2)));
    imagesc(ChAxis, DepthAxis, 10.*log10((Idata.^2 + Qdata.^2)/MaxVal), [DR 0]);
        
    colormap(gray)
	colorbar
    xlabel('Channel No.')
	ylabel('Depth (mm)')

end

% Reorder channels by element
QdataReorder = zeros(samples, lines);
IdataReorder = zeros(samples, lines);
[IdataReorder, QdataReorder] = VsiReorderChannels(Idata, Qdata, ApertureStart, ApertureEnd, samples, lines);

if ShowReorderedIQ == 1
	figure
	MaxVal = max(max((IdataReorder.^2 + QdataReorder.^2)));
	imagesc(WidthAxis, DepthAxis, 10.*log10((IdataReorder.^2 + QdataReorder.^2)/MaxVal), [DR 0]);
	colormap('gray')
	colorbar
	axis equal
	axis tight
    xlabel('Width (mm)')
	ylabel('Depth (mm)')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Now do the beamforming %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Beamform == 1
    
    % Initialization
    QdataReorderInt = zeros(samples*IntFac, lines);
    IdataReorderInt = zeros(samples*IntFac, lines);
    RfData = zeros(samples*IntFac, lines);
    BfData = zeros(samples, lines);
	PlanarDelayed = zeros(samples, lines);
    count = 0;
	
	% Interpolate
	for i=1:lines
        QIdataReorderInt(:,i) = interp(QdataReorder(:,i), IntFac);
        IdataReorderInt(:,i) = interp(IdataReorder(:,i), IntFac);
        
        % Reconstruct the RF
        RfData(:,i) = complex(QIdataReorderInt(:,i), IdataReorderInt(:,i)).*exp(-sqrt(-1)*2*pi*f_rf*transpose(t));
    end
	
% This is code that calculates the delay table - could be implememneted with some changes to the script for optimization
%     TotalDelay = zeros(samples, EndLine-StartLine+1);
%     
%     for row=1:samples
%        
%         LineRange = StartLine:EndLine-1;
%         
%                     
%         SampleDepth = DepthOffset*1e-3 + row*ct/fs;
%         
%         ISum = 0;
%         QSum = 0;
%         CountSum = 0;
%         j=sqrt(-1);
%         
%         for k=-NoElem/2:(NoElem/2)-1
%             PitchOff=(k+0.5)*pitch;
%                         
%                            
%             DelayDistance = sqrt(PitchOff^2 + (SampleDepth+a)^2); %m
%             DelaySamp = (DelayDistance - (SampleDepth+a))*fs/ct;
%             
%             %Find coarse delay
%             CoarseDelay = floor(DelaySamp) + row;
%             
%             %Find fine delay
%             DelaySampFrac = DelaySamp - floor(DelaySamp);
%             FineDelay = round(DelaySampFrac/FineDelayInc);
%             
%             % Store a table with all the delays
%             TotalDelay(row, k + (NoElem/2) + 1) = (CoarseDelay-1)*IntFac + 1 + FineDelay
%         end
%                        
%        
% 	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for row=floor(StartSample*samples):floor(EndSample*samples)
        LineRange = floor(StartLine*lines)+1:floor(EndLine*lines)-1;
                
        for LineIndex = LineRange
            
            SampleDepth = DepthOffset*1e-3 + row*ct/fs;
            
            ElemSum = 0;
            CountSum = 0;
            j=sqrt(-1);
            
	           
            for k=-NoElem/2:(NoElem/2)-1
                PitchOff=(k+0.5)*pitch;
                           
                ElementPos = (LineIndex-1/2)*(pitch) + PitchOff;
                
                if ElementPos >= 0 && ElementPos <= (lines-1)*pitch
                    
                    DelayDistance = sqrt(PitchOff^2 + (SampleDepth+a)^2); %m
                    DelaySamp = (DelayDistance - (SampleDepth+a))*fs/ct;
                                        
                    
                    %Find coarse delay
                    CoarseDelay = floor(DelaySamp) + row;
                    
                    %Find fine delay
                    DelaySampFrac = DelaySamp - floor(DelaySamp);
                    FineDelay = round(DelaySampFrac/FineDelayInc);
                    
                                   
                    if ((CoarseDelay-1)*IntFac + 1 + FineDelay <= samples*IntFac)
                        
                        ElemSum = ElemSum + (RfData((CoarseDelay-1)*IntFac + 1 + FineDelay,k+LineIndex+1));
                        CountSum = CountSum + 1;
                    end
                end
            end
            
            BfData(row,LineIndex) = ElemSum/CountSum;
      
                       
        end
	end
	
	% Display Beamformed IQ data
    if ShowBeamformedIQ == 1
        
		        
%         MaxVal = max(max(abs(BfData(:,:))));
%         image_data = 20.*log10((abs(BfData(:,:))/MaxVal)) + 255;
%         image(WidthAxis, DepthAxis,image_data);
        
        MaxVal = max(max(abs(BfData(:,:))));
        image_finale = 20.*log10((abs(BfData(:,:))/MaxVal));
%         image_finale = abs(BfData(:,:));

        image_finale = image_finale + (-DR);
        image_finale(find(image_finale < 10)) = 0;
        image_finale(find(image_finale > -DR)) = -DR;
        image_finale = image_finale/max(image_finale(:))*128;
        image_finale = image_finale + 129;
        
%         figure;plot(image_finale(:));
%         axes(handles.axes2);
% %         imagesc(WidthAxis, DepthAxis, image_finale, [DR 0]);
%         image(WidthAxis, DepthAxis, image_finale);
%       
%         axis equal 
%         axis tight
%         xlabel('Width (mm)')
% 		ylabel('Depth (mm)')
% % 		colormap(gray);
%         colorbar
% %  		colormap(handles.acq.cmap);
% % 		colorbar

    end
end