function [handles] = PreprocessData(handles, fnameBase, n_frames)


fnameXml = [fnameBase '.xml'];
param = VsiParseXmlModif(fnameXml, '.pamode');

% 1st frame
frameNumber = 1;
[handles, Bmode_abs_data] = VsiBModeReconstructRFModif(handles, fnameBase, frameNumber);
[handles, PAmode_BfData] = VsiBeamformPaModif(handles, fnameBase, frameNumber, frameNumber);

Bmode_data = zeros(size(Bmode_abs_data,1), size(Bmode_abs_data,2), n_frames);
PAmode_data = zeros(size(PAmode_BfData,1), size(PAmode_BfData,2), n_frames);

Bmode_data(:,:,1) = Bmode_abs_data(:,:);
PAmode_data(:,:,1) = PAmode_BfData(:,:);

for iFrame = 2:n_frames
    [handles, image_finale_Bmode] = VsiBModeReconstructRFModif(handles,fnameBase, iFrame);
    [handles, image_finale_PAmode] = VsiBeamformPaModif(handles,fnameBase, iFrame, iFrame);
   
    Bmode_data(:,:,iFrame) = image_finale_Bmode(:,:);
    PAmode_data(:,:,iFrame) = image_finale_PAmode(:,:);
end

% Processing params
processing_param.TimeStampData = handles.acq.TimeStampData;
processing_param.n_frames = handles.acq.n_frames;

save_filename = strcat([fnameBase '.mat']);
save(save_filename,'Bmode_data','PAmode_data','param','processing_param');

