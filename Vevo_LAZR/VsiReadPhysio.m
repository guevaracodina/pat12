function [Physio] = VsiReadPhysio(baseFolder, baseFilename)
% Gets the physio data returned as a structure:
%   Physio.ECG  - ECG signal
%   Physio.Resp - Respiration signal
%   Physio.Temp - Temperature signal
%   Physio.BP   - Blood pressure
%   Physio.Timestamp - Timestamp in (ms)

Physio = struct('ECG', {}, 'Resp', {}, 'Temp', {}, 'BP', {}, 'Timestamp', []);

fname  = [baseFolder '\' baseFilename '.raw.physio'];
fid = -1;

try
    % Locate file
    tmp = dir(fname);
    if (isempty(tmp))
        error('Could not find file: %s', fname);
    end

    % Open file
    fid = fopen(fname,'r');
    if (-1 == fid)
        error('Could not open file: %s', fname);
    end

    file_header = 40; % Bytes

    fseek(fid, 4, 'bof');
    dwNumFrames = fread(fid, 1, 'uint32');
    
    Physio(1).ECG  = cell(1, 1);
    Physio(1).Resp = cell(1, 1);
    Physio(1).Temp = cell(1, 1);
    Physio(1).BP   = cell(1, 1);
    Physio(1).Timestamp = zeros(1, dwNumFrames);   
    
    fseek(fid, file_header, 'bof');
    Physio(1).Timestamp = zeros(1, dwNumFrames);
    for i = 1:dwNumFrames
        fseek(fid, 4, 'cof');
        Physio.Timestamp(i) = fread(fid, 1, 'double');
        fseek(fid, 8, 'cof');
        dwPacketSize = fread(fid, 1, 'uint32');
        fseek(fid, 32, 'cof');
        
        numElements = dwPacketSize / 8;
        
        Physio.ECG{i} = fread(fid, numElements, 'short');
        Physio.Resp{i} = fread(fid, numElements, 'short');
        Physio.Temp{i} = fread(fid, numElements, 'short');
        Physio.BP{i} = fread(fid, numElements, 'short');
    end
    fclose(fid);
catch err
    if (-1 ~= fid)
        fclose(fid);
    end
    rethrow(err);
end

end

