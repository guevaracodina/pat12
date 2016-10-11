function [FrameOrder, FrameEcgPer] = VsiEkvOrderFrames(ImageTime, ECG_Peak, Resp_Peak, Resp, PhysioTime)

% ImageTime: actual time
% PhysioTime: time at each physio data point

iCount = 1;
good = [];

% Threshold: between 0 and 1
% Indicates the percentage of data that will be defined as "good"
thres = 0.40;

% Calculate the "good" data:
% Want to use the data in between the respiration peaks (less movement)
for (i = 1:length(Resp_Peak)-1)
    
    % Calculate the point exactly between the respiration peaks
    avg(i) = (Resp_Peak(i) + Resp_Peak(i+1)) / 2;
    
    % Calculate limits on either side of these points based on threshold
    b(i) = (Resp_Peak(i+1) - avg(i))*(thres) + avg(i);
    x = (avg(i) - Resp_Peak(i))*(thres);
    a(i) = avg(i) - x;
    
    % Save the "good" data
    good = [good find(PhysioTime > a(i) & PhysioTime < b(i))];
    
end

% Second threshold
% Only accept data within mean plus/minus 0.25 standard deviations
% Change value when necessary
av = mean(Resp(good));
sd = std(Resp(good));

topcutoff = av + (0.25*sd);
bottomcutoff = av - (0.25*sd);

% Same thresholding as above
for i = 1:length(ImageTime)
    %idx = previous peak to the frame
    idx = find(Resp_Peak < ImageTime(i), 1, 'last');
    
    if (isempty(idx))
        continue;
    end
    
    avg(i) = (Resp_Peak(idx) + Resp_Peak(idx+1)) / 2;
    
    b(i) = (Resp_Peak(idx+1) - avg(i))*(thres) + avg(i);
    x = (avg(i) - Resp_Peak(idx))*(thres);
    a(i) = avg(i) - x;
    
    if (ImageTime(i) < a(i) || ImageTime(i) > b(i))
        continue;
    end
    
    idx = find(PhysioTime > ImageTime(i), 1, 'first');
    x = Resp(idx);
    
    % Check if data is outside of second threshold
    if (x > topcutoff || x < bottomcutoff)
        continue;
    end
    
    idx = find(ECG_Peak < ImageTime(i), 1, 'last');
    
    if (isempty(idx) || idx == length(ECG_Peak) || idx == 1)
        continue;
    end
    
    CardiacImgIdx(iCount) = i; %#ok<AGROW>
    CardiacPos(iCount) = (ECG_Peak(idx+1) - ImageTime(i)) / (ECG_Peak(idx+1) - ECG_Peak(idx)); %#ok<AGROW>
    
    iCount = iCount + 1;
end

[FrameEcgPer, Order] = sort(CardiacPos);
FrameOrder = CardiacImgIdx(Order);
end

