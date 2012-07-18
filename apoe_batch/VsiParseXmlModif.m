% VsiParseXml.m
% Copyright VisualSonics 1999-2010
% A. Needles, J. Mehi, G. Sundar
% Revision: 1.3 Dec 7 2010
% A function to parse xml parameter files from IQ data export on the Vevo 2100
% and read selected parameters

function [ReturnParam] = ParseXml_allModes(filename, ModeName)

try
   xDoc = xmlread(filename);
catch
   error('Failed to read XML file %s.',filename);
end

AllParameters = xDoc.getElementsByTagName('parameter');

switch ModeName
    case '.bmode'
        RxFreqModeName = 'B-Mode';
 for k = 0:AllParameters.getLength-1
    node = AllParameters.item(k);
    switch char(node.getAttribute('name'));        
    case 'B-Mode/Samples';
        javaNsamples = node.getAttribute('value');
        BmodeNumSamples = str2num(char(javaNsamples));       
    case 'B-Mode/Lines';
        javaNlines = node.getAttribute('value');
        BmodeNumLines = str2num(char(javaNlines));        
    case 'B-Mode/Depth-Offset';
        javaDepthOffset = node.getAttribute('value');
        BmodeDepthOffset = str2num(char(javaDepthOffset));        
    case 'B-Mode/Depth';
        javaDepth = node.getAttribute('value');
        BmodeDepth = str2num(char(javaDepth));       
    case 'B-Mode/Width';
        javaWidth = node.getAttribute('value');
        BmodeWidth = str2num(char(javaWidth));       
    case 'B-Mode/RX-Frequency'
        javaRxFrequency = node.getAttribute('value');
        BmodeRxFrequency = str2num(char(javaRxFrequency));       
    case 'B-Mode/TX-Frequency'
        javaTxFrequency = node.getAttribute('value');
        BmodeTxFrequency = str2num(char(javaTxFrequency));       
    case 'Power-Mode/RX-Frequency'
        javaRxFrequency = node.getAttribute('value');
        BmodeRxFrequency = str2num(char(javaRxFrequency));        
    case 'B-Mode/Quad-2X';
        javaQuad2x = node.getAttribute('value');
        BmodeQuad2x = char(javaQuad2x);       
    case 'B-Mode/Focal-Zones-Count';
        javaNumFocalZones = node.getAttribute('value');
        BmodeNumFocalZones = str2num(char(javaNumFocalZones));  
    case 'B-Mode/Y-Offset'
        javaYOffset = node.getAttribute('value');
        BmodeYOffset = str2num(char(javaYOffset));   
    case 'B-Mode/V-Offset'
        javaVOffset = node.getAttribute('value');
        BmodeVOffset = str2num(char(javaVOffset));   
    end
 end
ReturnParam = struct('BmodeNumSamples', BmodeNumSamples, 'BmodeNumLines', BmodeNumLines, 'BmodeDepthOffset', BmodeDepthOffset,...
    'BmodeDepth', BmodeDepth,'BmodeWidth', BmodeWidth, 'BmodeRxFrequency', BmodeRxFrequency, 'BmodeTxFrequency', BmodeTxFrequency,...
    'BmodeQuad2x', BmodeQuad2x, 'BmodeNumFocalZones', BmodeNumFocalZones, 'BmodeYOffset', BmodeYOffset, 'BmodeVOffset', BmodeVOffset);

    case '.color'
            RxFreqModeName = 'Color-Mode';  Quad2x = 'null'; FocalZones = 1;

for k = 0:AllParameters.getLength-1
    node = AllParameters.item(k); 
    switch char(node.getAttribute('name'));       
    case 'Color-Mode/Samples';
        javaNsamples = node.getAttribute('value');
        ColorNumSamples = str2num(char(javaNsamples));
    case 'Color-Mode/Lines';
        javaNlines = node.getAttribute('value');
        ColorNumLines = str2num(char(javaNlines));     
    case 'Color-Mode/Depth-Offset';
        javaDepthOffset = node.getAttribute('value');
        ColorDepthOffset = str2num(char(javaDepthOffset));       
    case 'Color-Mode/TX-Frequency'
        javaTxFrequency = node.getAttribute('value');
        ColorTxFrequency = str2num(char(javaTxFrequency));        
    case 'Color-Mode/RX-Frequency'
        javaRxFrequency = node.getAttribute('value');
        ColorRxFrequency = str2num(char(javaRxFrequency));        
    case 'Color-Mode/Ensemble-n';
        javaEnsemble_n = node.getAttribute('value');
        ColorNumEnsemble = str2num(char(javaEnsemble_n));      
    case 'Color-Mode/Ensemble-Extra';
        javaEnsembleExtra = node.getAttribute('value');
        ColorEnsembleExtra = str2num(char(javaEnsembleExtra));        
    case 'Color-Mode/Lines-Extra-Blank';
        javaLinesExtra = node.getAttribute('value');
        ColorLinesExtra = str2num(char(javaLinesExtra));   
    case 'Color-Mode/Steering-Angle';
        javaSteeringAngle = node.getAttribute('value');
        ColorSteeringAngle = str2num(char(javaSteeringAngle));   
    case 'B-Mode/Samples';
        javaNsamples = node.getAttribute('value');
        BmodeNumSamples = str2num(char(javaNsamples));       
    case 'B-Mode/Lines';
        javaNlines = node.getAttribute('value');
        BmodeNumLines = str2num(char(javaNlines));        
    case 'B-Mode/Depth-Offset';
        javaDepthOffset = node.getAttribute('value');
        BmodeDepthOffset = str2num(char(javaDepthOffset));        
    case 'B-Mode/Depth';
        javaDepth = node.getAttribute('value');
        BmodeDepth = str2num(char(javaDepth));       
    case 'B-Mode/Width';
        javaWidth = node.getAttribute('value');
        BmodeWidth = str2num(char(javaWidth));       
    end
    
end
ReturnParam = struct('ColorNumSamples', ColorNumSamples, 'ColorNumLines', ColorNumLines, 'ColorDepthOffset', ColorDepthOffset, ...
    'ColorRxFrequency', ColorRxFrequency, 'ColorNumEnsemble', ColorNumEnsemble, 'ColorTxFrequency', ColorTxFrequency, ...
    'ColorEnsembleExtra', ColorEnsembleExtra, 'ColorLinesExtra',ColorLinesExtra, 'ColorSteeringAngle',ColorSteeringAngle,...
    'BmodeNumSamples', BmodeNumSamples, 'BmodeNumLines', BmodeNumLines,'BmodeDepthOffset', BmodeDepthOffset,...
    'BmodeDepth', BmodeDepth,'BmodeWidth', BmodeWidth);

 case '.pw'
            RxFreqModeName = 'Pw-Mode';  Quad2x = 'null'; FocalZones = 1; Nlines=1;

for k = 0:AllParameters.getLength-1
    node = AllParameters.item(k); 
    switch char(node.getAttribute('name'));       
    case 'Pw-Mode/Samples';
        javaNsamples = node.getAttribute('value');
        PwNsamples = str2num(char(javaNsamples));
    case 'Pw-Mode/TX-Frequency'
        javaTxFrequency = node.getAttribute('value');
        PwTxFrequency = str2num(char(javaTxFrequency));        
    case 'Pw-Mode/RX-Frequency'
        javaRxFrequency = node.getAttribute('value');
        PwRxFrequency = str2num(char(javaRxFrequency));        
    case 'Pw-Mode/Steering-Angle';
        javaSteeringAngle = node.getAttribute('value');
        PwSteeringAngle = str2num(char(javaSteeringAngle));   
    case 'Pw-Mode/TX-PRF';
        javaTxPrf = node.getAttribute('value');
        PwTxPrf = str2num(char(javaTxPrf));   
    case 'Pw-Mode/Spectral-Size';
        javaSpectralSize = node.getAttribute('value');
        PwSpectralSize = str2num(char(javaSpectralSize));   
    case 'Pw-Mode/Spectral-Spacing';
        javaSpectralSpacing = node.getAttribute('value');
        PwSpectralSpacing = str2num(char(javaSpectralSpacing));   
    case 'Pw-Mode/Display-Gain';
        javaDisplayGain = node.getAttribute('value');
        PwDisplayGain = str2num(char(javaDisplayGain));   
    case 'Pw-Mode/Display-Range';
        javaDisplayRange = node.getAttribute('value');
        PwDisplayRange = str2num(char(javaDisplayRange));   
    case 'Pw-Mode/Y-Offset';
        javaYOffset = node.getAttribute('value');
        PwYOffset = str2num(char(javaYOffset));   
    case 'Pw-Mode/V-Offset';
        javaVOffset = node.getAttribute('value');
        PwVOffset = str2num(char(javaVOffset));   
    end
        
end

ReturnParam = struct('PwNsamples', PwNsamples, 'PwRxFrequency', PwRxFrequency, ...
    'PwTxPrf',PwTxPrf, 'PwSpectralSize',PwSpectralSize,...
    'PwSpectralSpacing',PwSpectralSpacing,'PwDisplayGain',PwDisplayGain,'PwDisplayRange'...
    ,PwDisplayRange,'PwYOffset',PwYOffset,'PwVOffset',PwVOffset);

case '.pamode'

for k = 0:AllParameters.getLength-1
    node = AllParameters.item(k); 
    switch char(node.getAttribute('name'));       
    case 'Pa-Mode/Samples';
        javaNsamples = node.getAttribute('value');
        PaNumSamples = str2num(char(javaNsamples));
    case 'Pa-Mode/Lines';
        javaNlines = node.getAttribute('value');
        PaNumLines = str2num(char(javaNlines));     
    case 'Pa-Mode/Depth-Offset';
        javaDepthOffset = node.getAttribute('value');
        PaDepthOffset = str2num(char(javaDepthOffset));
    case 'Pa-Mode/Depth';
        javaDepth = node.getAttribute('value');
        PaDepth = str2num(char(javaDepth));       
    case 'Pa-Mode/Width';
        javaWidth = node.getAttribute('value');
        PaWidth = str2num(char(javaWidth));          
    case 'B-Mode/Samples';
        javaNsamples = node.getAttribute('value');
        BmodeNumSamples = str2num(char(javaNsamples));       
    case 'B-Mode/Lines';
        javaNlines = node.getAttribute('value');
        BmodeNumLines = str2num(char(javaNlines));        
    case 'B-Mode/Depth-Offset';
        javaDepthOffset = node.getAttribute('value');
        BmodeDepthOffset = str2num(char(javaDepthOffset));        
    case 'B-Mode/Depth';
        javaDepth = node.getAttribute('value');
        BmodeDepth = str2num(char(javaDepth));       
    case 'B-Mode/Width';
        javaWidth = node.getAttribute('value');
        BmodeWidth = str2num(char(javaWidth));
    case 'B-Mode/RX-Frequency'
        javaRxFrequency = node.getAttribute('value');
        BmodeRxFrequency = str2num(char(javaRxFrequency)); 
    case 'Pa-Mode/Acquisition-Mode'
        javaMode = node.getAttribute('value');
        PaMode = char(javaMode); 
    case 'Pa-Mode/Wavelength-1-Enable'
        javaWavelength1Enable = node.getAttribute('value');
        PaWavelength1Enable = str2num(char(javaWavelength1Enable)); 
    case 'Pa-Mode/Wavelength-1'
        javaWavelength1 = node.getAttribute('value');
        PaWavelength1 = str2num(char(javaWavelength1));
    case 'Pa-Mode/Wavelength-2-Enable'
        javaWavelength2Enable = node.getAttribute('value');
        PaWavelength2Enable = str2num(char(javaWavelength2Enable)); 
    case 'Pa-Mode/Wavelength-2'
        javaWavelength2 = node.getAttribute('value');
        PaWavelength2 = str2num(char(javaWavelength2));
    case 'Pa-Mode/Wavelength-3-Enable'
        javaWavelength3Enable = node.getAttribute('value');
        PaWavelength3Enable = str2num(char(javaWavelength3Enable)); 
    case 'Pa-Mode/Wavelength-3'
        javaWavelength3 = node.getAttribute('value');
        PaWavelength3 = str2num(char(javaWavelength3));
    case 'Pa-Mode/Wavelength-4-Enable'
        javaWavelength4Enable = node.getAttribute('value');
        PaWavelength4Enable = str2num(char(javaWavelength4Enable)); 
    case 'Pa-Mode/Wavelength-4'
        javaWavelength4 = node.getAttribute('value');
        PaWavelength4 = str2num(char(javaWavelength4));
    case 'Pa-Mode/Wavelength-5-Enable'
        javaWavelength5Enable = node.getAttribute('value');
        PaWavelength5Enable = str2num(char(javaWavelength5Enable)); 
    case 'Pa-Mode/Wavelength-5'
        javaWavelength5 = node.getAttribute('value');
        PaWavelength5 = str2num(char(javaWavelength5));
    end
    
end
ReturnParam = struct('PaNumSamples', PaNumSamples, 'PaNumLines', PaNumLines, 'PaDepthOffset', PaDepthOffset, ...
    'PaDepth', PaDepth, 'PaWidth', PaWidth, 'BmodeNumSamples', BmodeNumSamples, 'BmodeNumLines', BmodeNumLines, ...
    'BmodeDepthOffset', BmodeDepthOffset, 'BmodeDepth', BmodeDepth,'BmodeWidth', BmodeWidth, 'BmodeRxFrequency', ...
    BmodeRxFrequency, 'PaMode' ,PaMode,...
    'PaWavelength1Enable', PaWavelength1Enable,...
    'PaWavelength1', PaWavelength1,...
    'PaWavelength2Enable', PaWavelength2Enable,...   
    'PaWavelength2', PaWavelength2,...
    'PaWavelength3Enable', PaWavelength3Enable,...   
    'PaWavelength3', PaWavelength3,...
    'PaWavelength4Enable', PaWavelength4Enable,...   
    'PaWavelength4', PaWavelength4,...
    'PaWavelength5Enable', PaWavelength5Enable,...   
    'PaWavelength5', PaWavelength5);

case '.3dmode'
    
for k = 0:AllParameters.getLength-1
    node = AllParameters.item(k); 
    switch char(node.getAttribute('name'));       
    case '3D-Scan-Distance'
        javaScanDistance = node.getAttribute('value');
        ScanDistance = str2num(char(javaScanDistance));
    case '3D-Step-Size'
        javaStepSize = node.getAttribute('value');
        StepSize = str2num(char(javaStepSize));
    case 'B-Mode/Depth-Offset';
        javaDepthOffset = node.getAttribute('value');
        BmodeDepthOffset = str2num(char(javaDepthOffset));        
    case 'B-Mode/Depth';
        javaDepth = node.getAttribute('value');
        BmodeDepth = str2num(char(javaDepth));  
    case 'B-Mode/Width';
        javaWidth = node.getAttribute('value');
        BmodeWidth = str2num(char(javaWidth)); 
    end  
    
end

ReturnParam = struct('ScanDistance', ScanDistance, 'StepSize', StepSize, 'BmodeDepthOffset', BmodeDepthOffset, 'BmodeDepth', BmodeDepth, 'BmodeWidth', BmodeWidth);

end




