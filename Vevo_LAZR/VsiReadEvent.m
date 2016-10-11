function [Event] = VsiReadEvent(baseFolder, baseFilename)
% Gets the event data (timestamps in ms) returned as a structure:
%   Event.ECG  - ECG signal
%   Event.Resp - Respiration signal
%   Event.Systole   - Temperature signal
%   Event.Diastole  - Blood pressure

Event = struct('ECG', {}, 'Resp', [], 'Systole', [], 'Diastole', []);

fname  = [baseFolder '\' baseFilename '.raw.event'];
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

    EventType = cell(1, 4);
    
    file_header = 40; % Bytes
    fseek(fid, file_header, 'bof');
    for i = 1:4
        fseek(fid, 20, 'cof');
        dwPacketSize = fread(fid, 1, 'uint32');
        fseek(fid, 32, 'cof');
        
        numElements = dwPacketSize / 8;
        
        EventType{i} = fread(fid, numElements, 'double');
    end
    fclose(fid);
    
    Event(1).ECG  = EventType{1};
    Event(1).Resp = EventType{2};
    Event(1).Systole  = EventType{3};
    Event(1).Diastole = EventType{4};
catch err
    if (-1 ~= fid)
        fclose(fid);
    end
    rethrow(err);
end

end

