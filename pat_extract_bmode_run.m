function out = pat_extract_bmode_run(job)
% Batch function to import *.raw/iq.bmode files into NIfTI files.
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

addpath(['.',filesep,'Vevo_LAZR/'])

if pat_isVEVOraw(job)
    % Runs *.raw.pamode module
    out = pat_raw_bmode_read_run(job);
else
    % Runs *.iq.pamode module
    PATmat=job.PATmat;
    % Loop over acquisitions
    for scanIdx=1:size(PATmat,1)
        try
            load(PATmat{scanIdx});
            % Only take b-mode images associated with PAT nifti files
            PAT.bmode_nifti_files=cell(1,length(PAT.nifti_files));
            for fileIdx=1:length(PAT.nifti_files)
                [d,f,e]=fileparts(PAT.nifti_files{fileIdx});
                files{fileIdx}=[f,'.iq.bmode'];
            end
            
            for fileIdx=1:length(PAT.nifti_files)
                % Beamform image and save as Nifti in results dir
                stripped_filename=files{fileIdx}(1:end-6);
                [bmode_img, pixel_width, pixel_height, depth_offset]=bmode_reconstruct_rf(fullfile(PAT.input_dir,stripped_filename));
                
                nifti_filename=fullfile(PAT.output_dir,[stripped_filename,'.bmode.nii']);
                dim = [size(bmode_img,1), size(bmode_img,2), 1];
                dt = [spm_type('float64') spm_platform('bigend')];
                pinfo = ones(3,1);
                % Affine transformation matrix: Scaling
                matScaling = eye(4);
                matScaling(1,1) = pixel_height;
                matScaling(2,2) = pixel_width;
                % Affine transformation matrix: Rotation
                matRotation = eye(4);
                matRotation(1,1) = 0;
                matRotation(1,2) = 1;
                matRotation(2,1) = -1;
                matRotation(2,2) = 0;
                % Affine transformation matrix: Translation
                matTranslation = eye(4);
                matTranslation(1,4) = depth_offset;
                % Final Affine transformation matrix:
                mat = matRotation * matTranslation * matScaling ;
                % Save all frames temporally to use lambda as time
                for istack=1:size(bmode_img,3)
                    hdr = pat_create_vol(nifti_filename, dim, dt, pinfo, mat,istack,squeeze(bmode_img));
                end
                PAT.bmode_nifti_files{fileIdx}=nifti_filename;
            end
            PAT.jobsdone.extract_bmode=1;
            save(PATmat{scanIdx},'PAT');
            out.PATmat{scanIdx} = PATmat{scanIdx};
        catch exception
            disp(exception.identifier)
            disp(exception.stack(1))
            out.PATmat{scanIdx} = PATmat{scanIdx};
        end
    end
end
end

function [bmode_img, pixel_width, pixel_height, BmodeDepthOffset] = bmode_reconstruct_rf(fnameBase)

% VsiBModeReconstructRF.m
% A script to open IQ files from B-Mode data export on the Vevo 2100
% and reconstruct the RF signal
% Authors: A. Needles, J. Mehi
% Copyright VisualSonics 1999-2010
% Revision: 1.0 June 28 2010
% Revision: 1.1 July 22 2010: for software version 1.2 or higher

set(0,'defaultTextUnits','Normalized');
% specify frame number here ------------------
frameNumber= 1;
% ------------------------------------------
[Idata,Qdata,param] = VsiBModeIQ(fnameBase, '.bmode', frameNumber);
% ------------------------------------------

BmodeNumSamples = param.BmodeNumSamples;
BmodeNumFocalZones = param.BmodeNumFocalZones;
BmodeNumLines = param.BmodeNumLines;
BmodeDepthOffset = param.BmodeDepthOffset;
BmodeDepth = param.BmodeDepth;
BmodeWidth = param.BmodeWidth;
BmodeQuad2x = param.BmodeQuad2x;
BmodeRxFrequency = param.BmodeRxFrequency; %Hz
BmodeTxFrequency = param.BmodeTxFrequency; %Hz

pixel_width=BmodeWidth/(BmodeNumLines-1);
pixel_height=(BmodeDepth-BmodeDepthOffset)/(BmodeNumSamples-1);
% ------------------------------------------
% Setup the Rx frequency
fs= BmodeRxFrequency;
f_rf = fs; % reconstruct to the original Rx freq in the param file
if strcmp(BmodeQuad2x,'true')
    fs = fs*2; % actual Rx freq is double because of Quad 2x
    IntFac = 8;
else
    IntFac = 16;
end
fs_int = fs*IntFac;

% Initialize
IdataInt = zeros(BmodeNumSamples*IntFac, BmodeNumLines);
QdataInt = zeros(BmodeNumSamples*IntFac, BmodeNumLines);
RfData = zeros(BmodeNumSamples*IntFac, BmodeNumLines);
t = [0:1/fs_int:((BmodeNumSamples*IntFac)-1)/fs_int];

% Interpolate I/Q and reconstruct RF
for i=1:BmodeNumLines
    IdataInt(:,i) = interp(Idata(:,i), IntFac);
    QdataInt(:,i) = interp(Qdata(:,i), IntFac);
    % phase term in complex exponential modified for rev. 1.1
    RfData(:,i) = real(complex(IdataInt(:,i), QdataInt(:,i)).*exp(sqrt(-1)*(2*pi*f_rf*t')));
end

if strcmp(BmodeQuad2x,'true')
    RfData= -RfData;
end

% plot B-Mode image and reconstructed RF line
% specify which RF line to plot
% specify range for RF data plot
% RF samples range from 1 to BmodeNumSamples*IntFac
% ------------------------
%sampleWindow= 2000:5000;
% ----------------------------------
%fig1= figure('units','normalized','position',[.01 .55 .4 .35]);
%imagesc(10*log10(Idata.^2 + Qdata.^2));
%title(fnameBase,'interpreter','none');
%colormap('gray'); colorbar

bmode_img=10*log10(Idata.^2 + Qdata.^2);
end


function [Idata,Qdata,param] = VsiBModeIQ(fnameBase, ModeName, iframe)
% Authors: A. Needles, J. Mehi
% Copyright VisualSonics 1999-2010
% Revision: 1.0 June 28 2010

% Set up file names
fname = [fnameBase '.bmode'];
fnameXml = [fnameBase '.xml'];

% Parse the XML parameter file - DO NOT CHANGE
param = VsiParseXml(fnameXml,ModeName);
BmodeNumFocalZones = param.BmodeNumFocalZones;
BmodeNumSamples = param.BmodeNumSamples;
BmodeNumLines = param.BmodeNumLines;

% This is to strip the header data in the files - DO NOT CHANGE
size = 2; % bytes
file_header = 40; % bytes
line_header = 4; % bytes
frame_header = 56; % bytes
Nlines= BmodeNumFocalZones*BmodeNumLines;

fid = fopen(fname,'r');
% Initialize data
Idata = zeros(BmodeNumSamples, Nlines);
Qdata = zeros(BmodeNumSamples, Nlines);
header = file_header + frame_header*iframe + (size*BmodeNumSamples*Nlines*2 + Nlines*line_header)*(iframe-1);
for i=1:Nlines
    fseek(fid, header + (size*BmodeNumSamples*2 + line_header)*(i-1),-1);
    fseek(fid, line_header, 'cof');
    [Qdata(:,i),count]=fread(fid, BmodeNumSamples, 'int16', size);
    fseek(fid, header + (size*BmodeNumSamples*2 + line_header)*(i-1) + size,-1);
    fseek(fid, line_header, 'cof');
    [Idata(:,i),count]=fread(fid, BmodeNumSamples, 'int16', size);
end
fclose(fid);
end

% EOF
