function out = pat_extract_raw_run(job)
addpath(['.',filesep,'Vevo_LAZR/'])
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________
try
    for scanIdx=1:length(job.input_dir)
        
        % Set save structure and associated directory
        clear PAT
        PAT.input_dir=job.input_dir{scanIdx}
        filesdir=job.input_dir{scanIdx};
        files=dir(fullfile(filesdir,'*.iq.pamode'));
        
        dirlen=size(job.input_data_topdir{1},2);
        [pathstr, temp]=fileparts(filesdir);
        PAT.output_dir=fullfile(job.output_dir{1},pathstr(dirlen+1:end));
        if ~exist(PAT.output_dir,'dir'),mkdir(PAT.output_dir); end
        PATmat = fullfile(PAT.output_dir,'PAT.mat');
        % 
        PAT.nifti_files=cell(1,length(files));
        for fileIdx=1:length(files)
            % Beamform image and save as Nifti in results dir
            stripped_filename=files(fileIdx).name(1:end-10);
            [tmp, pixel_width, pixel_height, depth_offset]=beamform(fullfile(PAT.input_dir,files(fileIdx).name));
            % Data is filled with zeros, find where they are
            start_index =1;
            end_index=size(tmp,1);
            left_index=1;
            right_index=size(tmp,2);
            for itop=1:size(tmp,1)
                if( sum(tmp(itop,:,1)) > 0)
                    start_index=itop;
                    break;
                end
            end
            for ibot=size(tmp,1):-1:1
                if( sum(tmp(ibot,:,1)) > 0)
                    end_index=ibot;
                    break;
                end
            end
            for ileft=1:size(tmp,2)
                if( sum(tmp(:,ileft,1),1) > 0)
                    left_index=ileft;
                    break;
                end
                        end
            for iright=size(tmp,2):-1:1
                if( sum(tmp(:,iright,1),1) > 0)
                    right_index=iright;
                    break;
                end
            end
            tmp=log(abs(tmp(start_index:end_index,left_index:right_index,:)));
            
            nifti_filename=fullfile(PAT.output_dir,[stripped_filename,'.nii']);
            dim = [size(tmp,1), size(tmp,2), 1];
            dt = [spm_type('float64') spm_platform('bigend')];
            pinfo = ones(3,1);
            % Affine transformation matrix: Scaling
            matScaling = eye(4);
            matScaling(1,1) = pixel_width;
            matScaling(2,2) = pixel_height;
            % Affine transformation matrix: Rotation
            matRotation = eye(4);
            matRotation(1,1) = 0;
            matRotation(1,2) = 1;
            matRotation(2,1) = -1;
            matRotation(2,2) = 0;
            % Affine transformation matrix: Translation
            matTranslation = eye(4);
            matTranslation(2,4) = -depth_offset;
            % Final Affine transformation matrix: 
            mat = matScaling * matRotation * matTranslation;
            % Save all frames temporally to use lambda as time
            for istack=1:size(tmp,3)
                hdr = pat_create_vol(nifti_filename, dim, dt, pinfo, mat,istack,squeeze(tmp(:,:,istack)));
            end
            PAT.nifti_files{fileIdx}=nifti_filename;
        end
        
        
        PAT.jobsdone.extract_raw=1;
        save(PATmat,'PAT');
        out.PATmat{scanIdx} = PATmat;
    end
    
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    out.PATmat{scanIdx} = PATmat;
end
end



function [data, pixel_width, pixel_height, DepthOffset]=beamform(fname)

% Remove pamode extension, add xml
fnameXml = [fname(1:end-7) '.xml'];

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
StartSample = 0.25; % as a fractional percentage of total
EndSample = 0.75; % as a fractional percentage of total

%contants
ct = 1540; %m/s
cl = 2340; %m/s

% MS250/LZ250 settings
a = 0.25e-3; %m - lens thickness
pitch = 90e-6; %m

% MS550/LZ550 settings
% a = 0.25e-3; %m - lens thickness
% pitch = 55e-6; %m

% Display Options, 0 = OFF, 1 = ON
ShowBeamformedIQ = 1;
DR = -60; % Dynamic Range in dB
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXml(fnameXml, '.pamode');
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
%% Get total number of frames
fileInfo = dir(fname);
fileSize = fileInfo.bytes;
% nFrames represents the total of frames SO2 & HbT
nFrames = (fileSize - file_header) ./ ((size*samples*lines*2 + lines*line_header) + frame_header);
% These parameters need to be set manually for opening the file
StartFrame = 1;
EndFrame = nFrames;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Frames loop
fprintf('Reading %d frames from file %s...\n',nFrames, fname);

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
pixel_width=Width/((lines/NumPulses)-1);
pixel_height=(Depth-DepthOffset)/(samples-1);
DepthAxis = [DepthOffset:(Depth-DepthOffset)/(samples-1):Depth];
WidthAxis = [0:Width/((lines/NumPulses)-1):Width];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup the time and frequency vectors
t = [0:1/fs_int:((samples*IntFac)-1)/fs_int];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is all for opening and analyzing the file
data=zeros(numel(DepthAxis),numel(WidthAxis),round(EndFrame-StartFrame+1));
for iframe = StartFrame:EndFrame
    if( mod(iframe,10)==1 )
        fprintf('Processing frame %d of %d...\n',iframe,nFrames);
    end
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
    
    
    
    % Reorder channels by element
    QdataReorder = zeros(samples, lines);
    IdataReorder = zeros(samples, lines);
    [IdataReorder, QdataReorder] = VsiReorderChannels(Idata, Qdata, ApertureStart, ApertureEnd, samples, lines);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Now do the beamforming %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
        fh=figure(301);
        
        MaxVal = max(max(abs(BfData(:,:))));
        imagesc(WidthAxis, DepthAxis, 20.*log10((abs(BfData(:,:))/MaxVal)), [DR 0]);
        
        axis equal
        axis tight
        xlabel('Width (mm)')
        ylabel('Depth (mm)')
        
        colormap(gray)
        colorbar
    end
    
    data(:,:,iframe)=BfData;
end
close(fh);

end